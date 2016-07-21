FROM fedora:24
MAINTAINER Rohith <gambol99@gmail.com>

WORKDIR /kube-coreos

RUN dnf install -y -q git unzip procps-ng openssl jq which tar openssh-clients && dnf clean all
RUN pip3 install awscli

ENV CFSSL_VERSION 1.2
ENV VAULT_VERSION 0.5.3
ENV TERRAFORM_VERSION 0.6.16
ENV KMSCTL_VERSION 0.2.0
ENV KUBECTL_VERSION 1.3.0

RUN curl -s https://pkg.cfssl.org/R${CFSSL_VERSION}/cfssl_linux-amd64 -o /usr/bin/cfssl && chmod +x /usr/bin/cfssl
RUN curl -s https://pkg.cfssl.org/R${CFSSL_VERSION}/cfssljson_linux-amd64 -o /usr/bin/cfssljson && chmod +x /usr/bin/cfssljson
RUN curl -sL https://github.com/gambol99/kmsctl/releases/download/v${KMSCTL_VERSION}/kmsctl_v${KMSCTL_VERSION}_linux_x86_64.gz | gunzip - > /usr/bin/kmsctl && chmod +x /usr/bin/kmsctl
RUN curl -sL https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl -o /usr/bin/kubectl && chmod +x /usr/bin/kubectl
RUN curl -sL https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip -o /tmp/terraform_linux_amd64.zip

RUN mkdir -p /opt/terraform && \
    mv /tmp/terraform_linux_amd64.zip /opt/terraform && \
    cd /opt/terraform && \
    unzip terraform_linux_amd64.zip && \
    rm -f terraform_linux_amd64.zip && \
    ln -s /opt/terraform/terraform /usr/bin/terraform

RUN /usr/bin/aws --version
RUN /usr/bin/cfssl version
RUN /usr/bin/kubectl version --client
RUN /usr/bin/terraform version

ENTRYPOINT [ "/bin/bash" ]
