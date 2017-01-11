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

There are a few prerequisites before doing a build, namely the KMS key use for at-rest encryption of the secrets and the terraform state bucket (though this one might be wrapped up in the script by now).

> - Ensure you have created a AWS KMS key *(in the correct region)* and updated the kms_master_id with the KeyID in the environment file.
> - Ensure you have created an S3 bucket for the terraform remote state and update the *terraform_bucket_name* variable in the environment file.
> - Ensure you have a aws credentials file location in ${HOME}/.aws/credentials and have updated the environment file with the correct aws_profile and aws_account.
> - Ensure you have updated the *kubeapi_access_list* and *ssh_access_list* environment variable to include your ip address.

```bash
# --> Create the terraform bucket
[jest@starfury kubernetes-platform]$ ./play.kube
--> Running Platform, with environment: play-jest
[play-jest@platform] (master) $ kmsctl bucket create --bucket play-jest-kube-terraform-eu-west-1
... Update

# --> Create the KMS key for encryption
[play-jest@platform] (master) $ kmsctl kms create --name kube-play --description "A shared KMS used for playground builds"
...

# --> Remember to update the variables (kms_master_id and terraform_bucket_name) in the platform/env.tfvars file !!
# Then update teh public and private dns zone for environment and the access lists for ssh and kubeapi access (defaults 0.0.0.0/0)

# --> Kicking off the a build
[play-jest@platform] (master) $ run  
... BUILDING ...

# --> Listing the instances
[play-jest@platform] (master) $ aws-instances
--------------------------------------------------------------------------------------------------------
|                                           DescribeInstances                                          |
+-------------------+---------------+----------------+----------------------+-----------+--------------+
|  play-jest-compute|  10.80.20.160 |  None          |  i-038e04cc103a61161 |  running  |  eu-west-1a  |
|  play-jest-compute|  10.80.22.252 |  None          |  i-08f17394ccce0c69b |  running  |  eu-west-1c  |
|  play-jest-bastion|  10.80.110.30 |  54.154.99.216 |  i-0041f7a15d54455d2 |  running  |  eu-west-1a  |
|  play-jest-compute|  10.80.21.84  |  None          |  i-03357aa1e7f0f6aa9 |  running  |  eu-west-1b  |
|  play-jest-secure |  10.80.11.109 |  None          |  i-0de8c881ae76e6600 |  running  |  eu-west-1b  |
|  play-jest-secure |  10.80.12.160 |  None          |  i-00f36bede3f0894ef |  running  |  eu-west-1c  |
|  play-jest-secure |  10.80.10.155 |  None          |  i-0a9c35b5c68f49100 |  running  |  eu-west-1a  |
+-------------------+---------------+----------------+----------------------+-----------+--------------+

# --> List all the ELBS
[play-jest@platform] (master) $ aws-elbs
--------------------------------------------------------------------------------------------------------------------
|                                               DescribeLoadBalancers                                              |
+-----------------------------------+------------------------------------------------------------------------------+
|  play-jest-kube-internal-elb      |  internal-play-jest-kube-internal-elb-382791532.eu-west-1.elb.amazonaws.com  |
|  play-jest-kubeapi                |  play-jest-kubeapi-2081633621.eu-west-1.elb.amazonaws.com                    |
+-----------------------------------+------------------------------------------------------------------------------+

# A kubeconfig has already been copied from secrets/secure/kubeconfig_admin to ~/.kube/config for you. Note, by
# default the server url will be public hostname of the kubeapi. If you have not set the sub-domain yet your'll
# have you use the aws one for now

[play-jest@platform] (master) $ terraform.sh output
[v] --> Retrieving the terraform remote state
Local and remote state in sync
compute_asg = play-jest-compute-asg
enabled_calico = 0
kubeapi_public = https://kube-play-jest.eu.example.com
kubeapi_public_elb = https://play-jest-kubeapi-2081633621.eu-west-1.elb.amazonaws.com
public_name_services = [
    ns-1227.awsdns-25.org,
    ns-1787.awsdns-31.co.uk,
    ns-469.awsdns-58.com,
    ns-678.awsdns-20.net
]

[play-jest@platform] (master) $ kubectl -s https://play-jest-kubeapi-2081633621.eu-west-1.elb.amazonaws.com get nodes
NAME                                         STATUS                     AGE
ip-10-80-10-147.eu-west-1.compute.internal   Ready,SchedulingDisabled   4m
ip-10-80-11-141.eu-west-1.compute.internal   Ready,SchedulingDisabled   4m
ip-10-80-12-193.eu-west-1.compute.internal   Ready,SchedulingDisabled   5m
ip-10-80-20-160.eu-west-1.compute.internal   Ready                      5m
ip-10-80-21-84.eu-west-1.compute.internal    Ready                      5m
ip-10-80-22-252.eu-west-1.compute.internal   Ready                      5m

# Note is usually takes between 3-5 minutes before seeing the API, it has to download containers (kubelet, hyperkube, kube-auth, kmsctl)
# and two binaries (kmsctl, smilodon)

[play-jest@platform] (master) $ kubectl -s https://play-jest-kubeapi-2081633621.eu-west-1.elb.amazonaws.com get ns
NAME          STATUS    AGE
default       Active    20m
kube-system   Active    20m

# By default kubedns and the dashboard has been automatically deployed via the kube-addons manifest.

# Cleaning up the environment
[play-jest@platform] (master) $ cleanup
This will DELETE ALL resources, are you sure? (yes/no) yes
...
```

#### **Bastion Hosts & SSH Access**

All the instances for the cluster are presently hidden away on private subnet's with not direct access to the internet. Outbound is handled via the managed NAT gateways and inbound can only come from the ELB layers *(by default all node ports from 30000 - 32767 are permitted between the ELB and compute security groups)*.

```shell
# Jump inside the container if not already there
[jest@starfury kubernetes-platform]$ ./play.kube
--> Running Platform, with environment: play-jest

# You have to ensure the secrets are downloaded - assuming a new container, you can fetch them via
[play-jest@platform] (master) $ fetch-secrets
[v] --> Fetching the secrets to the s3 bucket: play-jest-secrets
retrieved the file: addons/calico/deployment.yml and wrote to: secrets/addons/calico/deployment.yml
retrieved the file: addons/dashboard/deployment.yml and wrote to: secrets/addons/dashboard/deployment.yml
retrieved the file: addons/kubedns/deployment.yml and wrote to: secrets/addons/kubedns/deployment.yml
...

# You can setup the ssh-agent via the alias
[play-jest@platform] (master) $ agent-setup
Agent pid 1565
Identity added: /root/.ssh/id_rsa (/root/.ssh/id_rsa)

# Get the bastion host address
[play-jest@platform] (master) $ aws-instances | grep bas
|  play-jest-bastion|  10.80.110.30 |  54.x.x.x |  i-0041f7a15dxxxxxx |  running  |  eu-west-1a  |

[play-jest@platform] (master) $ ssh 54.x.x.x.
CoreOS alpha (1192.2.0)
Update Strategy: No Reboots
Failed Units: 1
  update-engine.service
# go into a master node
core@ip-10-80-110-30 ~ $ ssh 10.80.10.100
```
**Key Points**

> - The terraform variable *ssh_access_list* controls access to SSH via the Management security group.
> - The SSH key for the instance is kept in the secrets bucket under secrets/locked/environment_name
> - You can setup SSH agent forwarding from within the container via the alias 'agent-setup', ensure you have already downloaded the secrets via fetch-secrets.
> - The bastion hosts are run in a auto-scaling group, at the moment they are exposed directly to the internet, but long term I want to place them behind a ELB.


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
