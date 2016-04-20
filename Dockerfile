FROM fedora:23
MAINTAINER Rohith <gambol99@gmail.com>

WORKDIR /kube-coreos

ENV VAULT_VERSION 0.5.2
ENV TERRAFORM_VERSION 0.6.14
ENV S3SECRETS_VERSION 0.1.3
ENV FLEETCTL_VERSION 0.11.7
ENV KUBECTL_VERSION 1.2.2

RUN dnf install -y -q git unzip procps-ng openssl jq which tar openssh-clients && dnf clean all
RUN pip3 install awscli

RUN curl -s https://pkg.cfssl.org/R1.1/cfssl_linux-amd64 -o /usr/bin/cfssl && chmod +x /usr/bin/cfssl
RUN curl -s https://pkg.cfssl.org/R1.1/cfssljson_linux-amd64 -o /usr/bin/cfssljson && chmod +x /usr/bin/cfssljson
RUN curl -sL https://github.com/UKHomeOffice/s3secrets/releases/download/v${S3SECRETS_VERSION}/s3secrets_v${S3SECRETS_VERSION}_linux_x86_64 -o /usr/bin/s3secrets && chmod +x /usr/bin/s3secrets
RUN curl -sL https://github.com/coreos/fleet/releases/download/v${FLEETCTL_VERSION}/fleet-v${FLEETCTL_VERSION}-linux-amd64.tar.gz | tar -xzf - -C /usr/bin --strip-components=1 '*/fleetctl'
RUN curl -sL https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl -o /usr/bin/kubectl && chmod +x /usr/bin/kubectl
RUN curl -sL https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_amd64.zip -o /tmp/vault_linux_amd64.zip
RUN curl -sL https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip -o /tmp/terraform_linux_amd64.zip

RUN cd /tmp && \
    unzip /tmp/vault_linux_amd64.zip && \
    rm -f /tmp/vault_linux_amd64.zip && \
    mv vault /usr/bin/vault && \
    mkdir -p /opt/terraform && \
    mv /tmp/terraform_linux_amd64.zip /opt/terraform && \
    cd /opt/terraform && \
    unzip terraform_linux_amd64.zip && \
    rm -f terraform_linux_amd64.zip && \
    ln -s /opt/terraform/terraform /usr/bin/terraform

RUN /usr/bin/aws --version
RUN /usr/bin/cfssl version
RUN /usr/bin/kubectl version -c
RUN /usr/bin/fleetctl version
RUN /usr/bin/vault version
RUN /usr/bin/terraform version

ENTRYPOINT [ "/bin/bash" ]
