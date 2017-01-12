## **Kubernetes Platform**
---
Kubernetes Platform is a build container, scripts and environment setup container for a Kubernetes cluster. The container provides a generic entrypoint for the man

#### **Build container**

All the software requirements of the build are packaged up in a container; the Dockerfile for which can be found in the root. In order to build the container simply do a 'make' in the root folder. You can then jump inside via run.kube -e *ENV* script or use a playground via ./play.kube. The responsiblity of the container is to provide some default variables kube-tf modules and to provide a quick provisioning of the environment. The intended use would is to map credentials, environment files and any terraform files.

**Key Points**

> - You can build the container via a local Makefile in the root of this repository, type: make
> - The build container itself is nothing more than a generic entrypoint, providing the tools and the environment setup

#### **How would you use the container**

An exmaple of how you use the build can be found in [kube-platform](https://github.com/gambol99/kube-platform). Essentially, you need to provide the build container with the credentials, the environment files and your custom terraform files.

**Volume Mapping**
- environments -> platform/environments
- terraform -> platform/terraform/config.d

Because of the lack of support for recursive directories we need a

#### **Environment Setup**

The environment files are kept in the environments/ directory; most of attributes has defaults but elements such as as DNS zone, KMS keys are must all be filled into before. Jump to the Getting Started tutorial for an example.

> **Note**: the playground environment *(defaults to 'play')* is special and upon entry a default configuration is copied and customized for the user *(uses the USER environment var)*

#### **AWS Credentials**

AWS credentials are be passed into the build container either by environment variables or credentials file. On entrypoint, the run.kube will check for default access and secret keys in the user environment; if absent, it will use the aws credentials file *($HOME/.aws/credentials)* mapping the environment label to the aws profile name. At the moment only static keys are supported, though the intention is to add support for MFA and assuming remote roles.

**Keys Points**
> - Unless access keys are passed via environment variables i.e. AWS_ACCESS_KEY_ID etc the aws shared credentials is read by default with the environment name mapping to the profile name.
> - The playground environment is special, it defaults to aws profile 'play', copies and customizes a template for use.

#### **Getting Started**

Please checkout the [kube-playground](https://github.com/gambol99/kube-playground) repository for a demo / playground environment.

There are a few prerequisites before doing a build, namely the KMS key use for at-rest encryption of the secrets and the terraform state bucket (though this one might be wrapped up in the script by now).

> - Ensure you have created a AWS KMS key *(in the correct region)* and updated the kms_master_id with the KeyID in the environment file.
> - Ensure you have created an S3 bucket for the terraform remote state and update the *terraform_bucket_name* variable in the environment file.
> - Ensure you have a aws credentials file location in ${HOME}/.aws/credentials and have updated the environment file with the correct aws_profile and aws_account.
> - Ensure you have updated the *kubeapi_access_list* and *ssh_access_list* environment variable to include your ip address.

#### **Kubernetes Configuration**

The environment is broken into two main layer, secure and compute. Secure is where the Kubernetes master, controller and scheduler live, with compute being the worker nodes. The entire cluster is hidden on private subnets (secure, compute) with external internet access provided via the managed nat gateways. Note, the secure and compute subnets are not directly connected to a internet gateway, instead outbound in via nat and inbound load balancers must be place into the 'elb' subnets. Another subnet 'mgmt' (connected to the IGW) is where the bastion host lives. Note, I still need to finish of the bastion module!!

#### **Etcd Cluster**

The Etcd cluster which runs in the secure layer is made of a auto-scaling group spread across x availablity zones; terraform for create x EBS volumes and x ENI for the cluster nodes; the bootstrapping of the cluster involves a node in a ASG coming up, looking for available volumes and ENI's in it's availablity zone and attaching before starting etcd2. The process essentially wrapps static volumes and ip addresses to a bunch of random auto-scaling nodes.

#### **Kubernetes Services / Manifests**

Most of the Kubernetes service, barring the kubelet are deployed using manifests these are first templated via Terraform and uploaded to the secrets bucket. Two processes in the boxes (namely in the secure cloudinit) are responsible for keeping the manifests in sync with bucket versions, just updates the services should be a simple as amending the file, performing a run to template and upload and wait (default 10 seconds) for the files to be synchronized downstream; with the kubelet taking care of the rest. Why not, deploy the files as part of the cloudinit? At present the Kubenetes master is running on the Etcd cluster boxes, rolling out changes to these is precarious given it's affects on the cluster membership. Perhaps a better approach would be to add more boxes into the mix and run the Kubernetes core services in a additional auto-scaling group??

#### **Secrets**

All the secrets for the platform are kept in an s3 bucket and encrypted via KMS. Once the platform is built you can check directory structure under platform/secrets. Pulling or uploading the secrets simply involves fetch-secrets or upload-secrets aliases. Note, uploading ABAC or Kubernetes tokens.csv requires only an upload, the changes will be automatically reloade by [kube-auth](https://github.com/gambol99/kube-auth) service.

#### **Bash Aliases**

There's a number of helper aliases and methods brought into the container (scripts/.bashrc)
