#!/bin/bash
#
#  vim:ts=2:sw=2:et
#
source scripts/environment.sh || exit 1

annonce "Checking the secrets have been generated"

TOKENS_CSV="${SECRETS_DIR}/tokens.csv"
KUBEAPI_AUTH="${SECRETS_DIR}/auth-policy.json"
ETCD_CERT_KEY="${SECRETS_DIR}/etcd-key.pem"
ETCD_CERT="${SECRETS_DIR}/etcd.pem"
ETCD_CSR="${SECRETS_DIR}/etcd-csr.json"
PLATFORM_CA_KEY="${SECRETS_DIR}/ca-key.pem"
PLATFORM_CA="${SECRETS_DIR}/ca.pem"
VAULT_CERT_KEY="${SECRETS_DIR}/vault-key.pem"
VAULT_CERT="${SECRETS_DIR}/vault.pem"
VAULT_CSR="${SECRETS_DIR}/vault-csr.json"
KUBEAPI_CERT_KEY="${SECRETS_DIR}/kubeapi-key.pem"
KUBEAPI_CERT="${SECRETS_DIR}/kubeapi.pem"
KUBEAPI_CSR="${SECRETS_DIR}/kubeapi-csr.json"

CERTITIFATE_COUNTRY=${CERTITIFATE_COUNTRY:-"GB"}
CERTITIFATE_COUNTY=${CERTIFICATE_COUNTY:-"London"}
CERTITIFATE_ORGANIZATION=${CERTIFICATE_ORGANIZATION:-"Kubernetes"}
CERTITIFATE_STATE=${CERTIFICATE_STATE:-"London"}
CERTIFICATE_ALGO=${CERTIFICATE_ALGO:-"rsa"}
CERTIFICATE_SIZE=${CERTIFICATE_SIZE:-"2048"}

make_csr() {
  _OU="$1"
  _DOMAINS="$2"
  cat <<EOF
{
  "CN": "${CONFIG_DNS_ZONE_NAME}",
  "hosts": [ "localhost", "127.0.0.1", ${_DOMAINS} ],
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

certificates() {
  # step: generate the csr for the platform
  make_csr "etcd"  "\"*.${AWS_DEFAULT_REGION}.compute.internal\"" > ${ETCD_CSR}
  make_csr "vault" "\"vault.${CONFIG_DNS_ZONE_NAME}\",\"vault.platform.cluster.local\"" > ${VAULT_CSR}
  make_csr "kubeapi" "\"kubeapi.${CONFIG_DNS_ZONE_NAME}\"" > ${KUBEAPI_CSR}

  # step: generate the certificates if required
  annonce "Generating the certificates for the platform"
  if [ ! -f "${PLATFORM_CA}" ]; then
    annonce "Generating the Platform CA"
    cfssl gencert -initca ca/ca-csr.json | cfssljson -bare ${SECRETS_DIR}/ca >/dev/null || failed "unable to generate the ca"
    cat ${PLATFORM_CA} ${PLATFORM_CA_KEY} > ${SECRETS_DIR}/ca-bundle.pem
  fi

  if [ ! -f "${ETCD_CERT}" ]; then
    annonce "Generating the Etcd certificates"
    cfssl gencert -ca=${PLATFORM_CA} -ca-key=${PLATFORM_CA_KEY} \
      -config=ca/ca-config.json -profile=server ${ETCD_CSR} | cfssljson -bare ${SECRETS_DIR}/etcd >/dev/null || failed "unable to generate the etcd certificate"
  fi

  if [ ! -f  "${VAULT_CERT}" ]; then
    annonce "Generating the Vault certificates"
    cfssl gencert -ca=${PLATFORM_CA} -ca-key=${PLATFORM_CA_KEY} \
      -config=ca/ca-config.json -profile=server ${VAULT_CSR} | cfssljson -bare ${SECRETS_DIR}/vault >/dev/null || failed "unable to generate the vault certificate"
  fi

  if [ ! -f "${KUBEAPI_CERT}" ]; then
    annonce "Generating the KubeAPI certificates"
    cfssl gencert -ca=${PLATFORM_CA} -ca-key=${PLATFORM_CA_KEY} \
      -config=ca/ca-config.json -profile=server ${KUBEAPI_CSR} | cfssljson -bare ${SECRETS_DIR}/kubeapi >/dev/null || failed "unable to generate the kubeapi certificate"
  fi
}

make_kubeconfig() {
  cat <<EOF > ${SECRETS_DIR}/kubeconfig_${1}
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

kube_configs() {
  [ -e ${TOKENS_CSV} ] || touch ${TOKENS_CSV}
  for _username in admin controller scheduler kubelet proxy; do
    if ! grep -q "^${_username}" ${TOKENS_CSV}; then
      token="$(genpass 24)"
      userid="$(uuidgen)"
      echo "${token},${_username},${userid}" >> ${TOKENS_CSV}
      make_kubeconfig "${_username}" "${token}" "${userid}"
    fi
  done
  # step: copy the admin kubeconfig to $HOME
  mkdir -p ${HOME}/.kube
  [ -L "${PWD}/${SECRETS_DIR}/kubeconfig_admin" ] || ln -sf ${PWD}/${SECRETS_DIR}/kubeconfig_admin ${HOME}/.kube/config
}

kube_auth_policy() {
  if [ ! -f "${KUBEAPI_AUTH}" ]; then
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

certificates
kube_configs
kube_auth_policy
