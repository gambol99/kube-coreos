FROM fedora:23
MAINTAINER Rohith <gambol99@gmail.com>

WORKDIR /kube-coreos

ENV VAULT_VERSION 0.5.3
ENV TERRAFORM_VERSION 0.6.16
ENV KMSCTL_VERSION 0.1.0
ENV FLEETCTL_VERSION 0.11.7
ENV KUBECTL_VERSION 1.2.2

RUN dnf install -y -q git unzip procps-ng openssl jq which tar openssh-clients && dnf clean all
RUN pip3 install awscli

RUN curl -s https://pkg.cfssl.org/R1.1/cfssl_linux-amd64 -o /usr/bin/cfssl && chmod +x /usr/bin/cfssl
RUN curl -s https://pkg.cfssl.org/R1.1/cfssljson_linux-amd64 -o /usr/bin/cfssljson && chmod +x /usr/bin/cfssljson
RUN curl -sL https://github.com/gambol99/kmsctl/releases/download/v${KMSCTL_VERSION}/kmsctl_v${KMSCTL_VERSION}_linux_x86_64.gz | gunzip - > /usr/bin/kmsctl && chmod +x /usr/bin/kmsctl
RUN curl -sL https://github.com/coreos/fleet/releases/download/v${FLEETCTL_VERSION}/fleet-v${FLEETCTL_VERSION}-linux-amd64.tar.gz | tar -xzf - -C /usr/bin --strip-components=1 '*/fleetctl'
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
RUN /usr/bin/kubectl version -c
RUN /usr/bin/fleetctl version
RUN /usr/bin/terraform version

ENTRYPOINT [ "/bin/bash" ]
