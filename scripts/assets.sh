#!/bin/bash
#
#  vim:ts=2:sw=2:et
#
source scripts/environment.sh || exit 1

annonce "Checking the secrets have been generated"

TOKENS_CSV="${SECRETS_DIR}/secure/tokens.csv"
KUBEAPI_AUTH="${SECRETS_DIR}/secure/auth-policy.json"
ETCD_CSR="${SECRETS_DIR}/secure/etcd-csr.json"
ETCD_CSR_PROXY="${SECRETS_DIR}/common/etcd-proxy-csr.json"
KUBEAPI_CERT_KEY="${SECRETS_DIR}/secure/kubeapi-key.pem"
KUBEAPI_CERT="${SECRETS_DIR}/secure/kubeapi.pem"
KUBEAPI_CSR="${SECRETS_DIR}/secure/kubeapi-csr.json"
ETCD_HOSTS="$(hcltool ${ENVIRONMENT_FILE} | jq -r '[.secure_nodes[]] | join(",")')"
ETCD_CERT_KEY="${SECRETS_DIR}/secure/etcd-key.pem"
ETCD_CERT="${SECRETS_DIR}/secure/etcd.pem"
ETCD_PROXY_CERT_KEY="${SECRETS_DIR}/common/etcd-proxy-key.pem"
ETCD_PROXY_CERT="${SECRETS_DIR}/common/etcd-proxy.pem"
PLATFORM_CA="${SECRETS_DIR}/common/platform_ca.pem"
PLATFORM_CA_KEY="${SECRETS_DIR}/locked/platform_ca_key.pem"
KUBE_AUTH_WEBHOOK="secrets/secure/auth-webhook.yaml"
KUBE_TOKEN_WEBHOOK="secrets/secure/token-webhook.yaml"
CERTITIFATE_COUNTRY=${CERTITIFATE_COUNTRY:-"GB"}
CERTITIFATE_COUNTY=${CERTIFICATE_COUNTY:-"London"}
CERTITIFATE_ORGANIZATION=${CERTIFICATE_ORGANIZATION:-"Kubernetes"}
CERTITIFATE_STATE=${CERTIFICATE_STATE:-"London"}
CERTIFICATE_ALGO=${CERTIFICATE_ALGO:-"rsa"}
CERTIFICATE_SIZE=${CERTIFICATE_SIZE:-"2048"}

make_csr() {
  _OU="$1"
  cat <<EOF
{
  "CN": "${CONFIG_DNS_ZONE_NAME}",
  "hosts": [ "localhost" ],
  "key": {
    "algo": "${CERTIFICATE_ALGO}",
    "size": ${CERTIFICATE_SIZE}
  },
  "names": [
    {
      "C": "${CERTITIFATE_COUNTRY}",
      "L": "${CERTITIFATE_COUNTY}",
      "O": "${CERTITIFATE_ORGANIZATION}",
      "OU": "${_OU}",
      "ST": "${CERTITIFATE_STATE}"
    }
  ]
}
EOF
}

create_directories() {
  mkdir -p ${SECRETS_DIR}/{common,compute,secure,locked,manifests}
}

create_certificates() {
  # step: generate the csr for the platform
  make_csr "etcd"       > ${ETCD_CSR}
  make_csr "etcd-proxy" > ${ETCD_CSR_PROXY}
  make_csr "kubeapi"    > ${KUBEAPI_CSR}

  # step: generate the certificates if required
  annonce "Generating the certificates for the platform"
  if [[ ! -f "${PLATFORM_CA}" ]]; then
    annonce "Generating the Platform CA"
    cfssl gencert -initca ca/ca-csr.json | cfssljson -bare ${SECRETS_DIR}/common/ca >/dev/null || failed "unable to generate the ca"
    mv ${SECRETS_DIR}/common/ca-key.pem ${PLATFORM_CA_KEY}
    mv ${SECRETS_DIR}/common/ca.pem ${PLATFORM_CA}
  fi

  if [[ ! -f "${ETCD_CERT}" ]]; then
    annonce "Generating the Etcd certificates"
    cfssl gencert -ca=${PLATFORM_CA} -ca-key=${PLATFORM_CA_KEY} -hostname=localhost,127.0.0.1,${ETCD_HOSTS},*.${AWS_DEFAULT_REGION}.compute.internal \
      -config=ca/ca-config.json -profile=server ${ETCD_CSR} | cfssljson -bare ${SECRETS_DIR}/secure/etcd >/dev/null || failed "unable to generate the etcd certificate"
  fi

  if [[ ! -f "${ETCD_PROXY_CERT}" ]]; then
    annonce "Generating the Etcd Proxy certificates"
    cfssl gencert -ca=${PLATFORM_CA} -ca-key=${PLATFORM_CA_KEY} -hostname=localhost,127.0.0.1,${ETCD_HOSTS},*.${AWS_DEFAULT_REGION}.compute.internal \
      -config=ca/ca-config.json -profile=server ${ETCD_CSR_PROXY} | cfssljson -bare ${SECRETS_DIR}/common/etcd-proxy >/dev/null || failed "unable to generate the etcd proxy certificate"
  fi

  if [[ ! -f "${KUBEAPI_CERT}" ]]; then
    annonce "Generating the KubeAPI certificates"
    cfssl gencert -ca=${PLATFORM_CA} -ca-key=${PLATFORM_CA_KEY} -hostname=localhost,127.0.0.1,10.200.0.1,kube.${CONFIG_DNS_ZONE_NAME},kube.${CONFIG_PRIVATE_ZONE_NAME} \
      -config=ca/ca-config.json -profile=server ${KUBEAPI_CSR} | cfssljson -bare ${SECRETS_DIR}/secure/kubeapi >/dev/null || failed "unable to generate the kubeapi certificate"
  fi
}

make_kubeconfig() {
  cat <<EOF > ${SECRETS_DIR}/secure/kubeconfig_${1}
apiVersion: v1
kind: Config
clusters:
- cluster:
    insecure-skip-tls-verify: true
  name: default
contexts:
- context:
    user: ${1}
    cluster: default
  name: default
current-context: default
users:
- name: ${1}
  user:
    token: ${2}
EOF
}

create_kubernetes_configs() {
  [[ -e ${TOKENS_CSV} ]] || touch ${TOKENS_CSV}
  for _username in admin controller scheduler kubelet proxy; do
    if ! grep -q "^${_username}" ${TOKENS_CSV}; then
      token="$(generate_password 24)"
      userid="$(uuidgen)"
      echo "${token},${_username},${userid}" >> ${TOKENS_CSV}
      make_kubeconfig "${_username}" "${token}" "${userid}"
    fi
  done
  # step: move the kube config to compute
  mv ${SECRETS_DIR}/secure/kubeconfig_proxy ${SECRETS_DIR}/common
  mv ${SECRETS_DIR}/secure/kubeconfig_kubelet ${SECRETS_DIR}/compute

  # step: copy the admin kubeconfig to $HOME
  mkdir -p ${HOME}/.kube
  [[ -L "${HOME}/.kube/config" ]] || ln -sf ${PWD}/${SECRETS_DIR}/locked/kubeconfig_admin ${HOME}/.kube/config
}

create_kubernetes_auth_policy() {
  if [[ ! -f "${KUBEAPI_AUTH}" ]]; then
    annonce "Generating the Kubernetes authentication policy"
    cat <<EOF > ${KUBEAPI_AUTH}
{ "apiVersion": "abac.authorization.kubernetes.io/v1beta1", "kind": "Policy", "spec": { "user":"*", "nonResourcePath": "*", "readonly": true }}
{ "apiVersion": "abac.authorization.kubernetes.io/v1beta1", "kind": "Policy", "spec": { "user":"admin", "namespace": "*", "resource": "*", "apiGroup": "*" }}
{ "apiVersion": "abac.authorization.kubernetes.io/v1beta1", "kind": "Policy", "spec": { "user":"controller", "namespace": "*", "resource": "*", "apiGroup": "*" }}
{ "apiVersion": "abac.authorization.kubernetes.io/v1beta1", "kind": "Policy", "spec": { "user":"scheduler", "namespace": "*", "resource": "*", "apiGroup": "*" }}
{ "apiVersion": "abac.authorization.kubernetes.io/v1beta1", "kind": "Policy", "spec": { "user":"kubelet", "namespace": "*", "resource": "*", "apiGroup": "*" }}
{ "apiVersion": "abac.authorization.kubernetes.io/v1beta1", "kind": "Policy", "spec": { "user":"proxy", "namespace": "*", "resource": "*", "apiGroup": "*", "readonly": true }}
{ "apiVersion": "abac.authorization.kubernetes.io/v1beta1", "kind": "Policy", "spec": { "user":"system:serviceaccount:kube-system:kubedns","namespace":"*","resource":"*","apiGroup":"*", "readonly": true}}
EOF
  fi
}

create_kube_webhooks() {
  if [[ ! -f ${KUBE_AUTH_WEBHOOK} ]]; then
    annonce "Generting the kube authentication webhook"
cat <<EOF > ${KUBE_AUTH_WEBHOOK}
clusters:
- name: local-auth
  cluster:
    certificate-authority: /etc/ssl/certs/platform_ca.pem
    server: https://127.0.0.1:8443/authorize/policy
users:
  - name: local-auth
current-context: webhook
contexts:
- context:
    cluster: local-auth
    user: local-auth
  name: webhook
EOF
  fi

  if [[ ! -f "${KUBE_TOKEN_WEBHOOK}" ]]; then
  annonce "Generating the token webhook file"
cat <<EOF > ${KUBE_TOKEN_WEBHOOK}
clusters:
- name: local
  cluster:
    certificate-authority: /etc/ssl/certs/platform_ca.pem
    server: https://127.0.0.1:8443/authorize/token
users:
- name: local
current-context: local
contexts:
- context:
    cluster: local
    user: local
  name: local
EOF
  fi
}


create_directories
create_certificates
create_kubernetes_configs
create_kubernetes_auth_policy
create_kube_webhooks
