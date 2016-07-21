#!/bin/bash
#
#  vim:ts=2:sw=2:et
#
source scripts/environment.sh || exit 1

annonce "Checking the secrets have been generated"

TOKENS_CSV="${SECRETS_DIR}/secure/tokens.csv"
KUBEAPI_AUTH="${SECRETS_DIR}/secure/auth-policy.json"
ETCD_CSR="${SECRETS_DIR}/secure/etcd-csr.json"
KUBEAPI_CERT_KEY="${SECRETS_DIR}/secure/kubeapi-key.pem"
KUBEAPI_CERT="${SECRETS_DIR}/secure/kubeapi.pem"
KUBEAPI_CSR="${SECRETS_DIR}/secure/kubeapi-csr.json"
ETCD_CERT_KEY="${SECRETS_DIR}/common/etcd-key.pem"
ETCD_CERT="${SECRETS_DIR}/common/etcd.pem"
PLATFORM_CA="${SECRETS_DIR}/common/ca.pem"
PLATFORM_CA_KEY="${SECRETS_DIR}/locked/ca-key.pem"
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

create_certificates() {
  # step: generate the csr for the platform
  make_csr "etcd"    > ${ETCD_CSR}
  make_csr "kubeapi" > ${KUBEAPI_CSR}

  # step: generate the certificates if required
  annonce "Generating the certificates for the platform"
  if [[ ! -f "${PLATFORM_CA}" ]]; then
    annonce "Generating the Platform CA"
    cfssl gencert -initca ca/ca-csr.json | cfssljson -bare ${SECRETS_DIR}/common/ca >/dev/null || failed "unable to generate the ca"
    mv ${SECRETS_DIR}/common/ca-key.pem ${PLATFORM_CA_KEY}
  fi

  if [[ ! -f "${ETCD_CERT}" ]]; then
    annonce "Generating the Etcd certificates"
    cfssl gencert -ca=${PLATFORM_CA} -ca-key=${PLATFORM_CA_KEY} -hostname=localhost,127.0.0.1,*.${AWS_DEFAULT_REGION}.compute.internal \
      -config=ca/ca-config.json -profile=server ${ETCD_CSR} | cfssljson -bare ${SECRETS_DIR}/common/etcd >/dev/null || failed "unable to generate the etcd certificate"
  fi

  if [[ ! -f "${KUBEAPI_CERT}" ]]; then
    annonce "Generating the KubeAPI certificates"
    cfssl gencert -ca=${PLATFORM_CA} -ca-key=${PLATFORM_CA_KEY} -hostname=localhost,127.0.0.1,kube.${CONFIG_DNS_ZONE_NAME},secure.${CONFIG_DNS_ZONE_NAME} \
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
  mv ${SECRETS_DIR}/secure/kubeconfig_{kubelet,proxy} ${SECRETS_DIR}/compute

  # step: copy the admin kubeconfig to $HOME
  mkdir -p ${HOME}/.kube
  [[ -L "${PWD}/${SECRETS_DIR}/kubeconfig_admin" ]] || ln -sf ${PWD}/${SECRETS_DIR}/kubeconfig_admin ${HOME}/.kube/config
}

create_kubernetes_auth_policy() {
  if [[ ! -f "${KUBEAPI_AUTH}" ]]; then
    annonce "Generating the Kubernetes authentication policy"
    cat <<EOF > ${KUBEAPI_AUTH}
{ "apiVersion": "abac.authorization.kubernetes.io/v1beta1", "kind": "Policy", "spec": { "user":"*", "nonResourcePath": "*", "readonly": true}}
{ "apiVersion": "abac.authorization.kubernetes.io/v1beta1", "kind": "Policy", "spec": { "user":"admin", "namespace": "*", "resource": "*", "apiGroup": "*" }}
{ "apiVersion": "abac.authorization.kubernetes.io/v1beta1", "kind": "Policy", "spec": { "user":"controller-manager", "namespace": "*", "resource": "*", "apiGroup": "*" }}
{ "apiVersion": "abac.authorization.kubernetes.io/v1beta1", "kind": "Policy", "spec": { "user":"scheduler", "namespace": "*", "resource": "*", "apiGroup": "*" }}
{ "apiVersion": "abac.authorization.kubernetes.io/v1beta1", "kind": "Policy", "spec": { "user":"kubelet", "namespace": "*", "resource": "*" }}
{ "apiVersion": "abac.authorization.kubernetes.io/v1beta1", "kind": "Policy", "spec": { "user":"proxy", "namespace": "*", "resource": "*", "readonly": true }}
{ "apiVersion": "abac.authorization.kubernetes.io/v1beta1", "kind": "Policy", "spec": { "user":"skydns", "namespace": "*", "resource": "*", "readonly": true }}
EOF
  fi
}

create_certificates
create_kubernetes_configs
create_kubernetes_auth_policy
