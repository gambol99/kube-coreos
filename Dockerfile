FROM fedora:25
MAINTAINER Rohith <gambol99@gmail.com>

WORKDIR /platform

RUN dnf install -y -q git unzip procps-ng openssl jq which tar openssh-clients python-pip bind-utils && dnf clean all
RUN pip3 install awscli pyhcl

ENV CFSSL_VERSION=1.2 \
    TERRAFORM_VERSION=0.8.2 \
    KMSCTL_VERSION=1.0.3 \
    KUBECTL_VERSION=1.4.7

RUN curl -sL https://pkg.cfssl.org/R${CFSSL_VERSION}/cfssl_linux-amd64 -o /usr/bin/cfssl && chmod +x /usr/bin/cfssl && \
    curl -sL https://pkg.cfssl.org/R${CFSSL_VERSION}/cfssljson_linux-amd64 -o /usr/bin/cfssljson && chmod +x /usr/bin/cfssljson && \
    curl -sL https://github.com/gambol99/kmsctl/releases/download/v${KMSCTL_VERSION}/kmsctl-linux-amd64 > /usr/bin/kmsctl && chmod +x /usr/bin/kmsctl && \
    curl -sL https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl -o /usr/bin/kubectl && chmod +x /usr/bin/kubectl && \
    curl -sL https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip -o /tmp/terraform_linux_amd64.zip

RUN mkdir -p /opt/terraform && \
    mv /tmp/terraform_linux_amd64.zip /opt/terraform && \
    cd /opt/terraform && \
    unzip terraform_linux_amd64.zip && \
    rm -f terraform_linux_amd64.zip && \
    ln -s /opt/terraform/terraform /usr/bin/terraform

RUN /usr/bin/aws --version && \
    /usr/bin/cfssl version && \
    /usr/bin/kubectl version --client && \
    /usr/bin/terraform version && \
    /usr/bin/kmsctl --version

ENTRYPOINT [ "/bin/bash" ]
