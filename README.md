
#### **- Building the build container**

All the software requirements of the build are packaged up in a container; the Dockerfile for which can be found in the root. In order to build the container simply do a 'make' in the root folder. You can then jump inside via run.kube -e *ENV* script or use a playground via ./play.kube

#### **- Environments**

The environments are kept in the root environments directory. Note, when using a playground entrypoint (./play.kube) a default comfiguration is copied for you taking the environment name of play-<USERNAME>. Altnatively you can look at the variables.tf in the terraform directory to find all the attributes and settings.

#### **- AWS Credentials**

The AWS credentials passed into the container either via preset environment variables (i.e. it will first check they are set) or reading them from the current users static credentials files (~/.aws/credentials, assuming the environment variables aren't set). The profile is mapped to the environment name.

#### **- Building**

There are a few prerequestes before doing a build, namely the KMS key use for at-rest encryption of the secrets and the terraform state bucket (though this one might be wrapped up in the script by now).

* Ensure you have created a AWS KMS key *(in the correct region)* and updated the kms_master_id with the KeyID in the environment file.
* Ensure you have created an S3 bucket for the terraform remote state and update the *terraform_bucket_name* variable in the environment file.
* Ensure you have a aws credentials file location in ${HOME}/.aws/credentials and have updated the environment file with the correct aws_profile and aws_account.
* Ensure you have updated the *kubeapi_access_list* and *ssh_access_list* environment variable to include your ip address.

```shell
# Create the terraform bucket
[jest@starfury kubernetes-platform]$ ./play.kube
--> Running Platform, with environment: play-jest
[play-jest@platform] (master) $ kmsctl bucket create --bucket play-jest-kube-terraform-eu-west-1
... Update

#  Create the KMS key for encryption
[play-jest@platform] (master) $ kmsctl kms create --name kube-play --description "A shared KMS used for playground builds"
...

# Remember to update the variables (kms_master_id and terraform_bucket_name) in the platform/env.tfvars file !!
# Then update teh public and private dns zone for environment and the access lists for ssh and kubeapi access (defaults 0.0.0.0/0)

# Kicking off the a build
[play-jest@platform] (master) $ run  
... BUILDING ...

# Listing the instances
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

# List all the ELBS
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

[root@platform kube-coreos]$  kubectl -s https://play-jest-kubeapi-2081633621.eu-west-1.elb.amazonaws.com get ns
NAME          STATUS    AGE
default       Active    20m
kube-system   Active    20m
```

#### **- Bastion **

All the Kubernetes instances are on private subnets and inaccesable publically, in order to ssh to the boxes you have to hop on via the bastion instances.

```shell
[jest@starfury kubernetes-platform]$ ./play.kube
--> Running Platform, with environment: play-jest


```


#### **- Kubernetes Configuration**

The environment is broken into two main layer, secure and compute. Secure is where the Kubernetes master, controller and scheduler live, with compute being the worker nodes. The entire cluster is hidden on private subnets (secure, compute) with external internet access provided via the managed nat gateways. Note, the secure and compute subnets are not directly connected to a internet gateway, instead outbound in via nat and inbound load balancers must be place into the 'elb' subnets. Another subnet 'mgmt' (connected to the IGW) is where the bastion host lives. Note, I still need to finish of the bastion module!!

#### **- Etcd Cluster**

The Etcd cluster which runs in the secure layer is made of a auto-scaling group spread across x availablity zones; terraform for create x EBS volumes and x ENI for the cluster nodes; the bootstrapping of the cluster involves a node in a ASG coming up, looking for available volumes and ENI's in it's availablity zone and attaching before starting etcd2. The process essentially wrapps static volumes and ip addresses to a bunch of random auto-scaling nodes.

#### **- Kubernetes Services / Manifests**

Most of the Kubernetes service, barring the kubelet are deployed using manifests these are first templated via Terraform and uploaded to the secrets bucket. Two processes in the boxes (namely in the secure cloudinit) are responsible for keeping the manifests in sync with bucket versions, just updates the services should be a simple as amending the file, performing a run to template and upload and wait (default 10 seconds) for the files to be synchronized downstream; with the kubelet taking care of the rest. Why not, deploy the files as part of the cloudinit? At present the Kubenetes master is running on the Etcd cluster boxes, rolling out changes to these is precarious given it's affects on the cluster membership. Perhaps a better approach would be to add more boxes into the mix and run the Kubernetes core services in a additional auto-scaling group??

#### **- Secrets**

All the secrets for the platform are kept in an s3 bucket and encrypted via KMS. Once the platform is built you can check directory structure under platform/secrets. Pulling or uploading the secrets simply involves fetch-secrets or upload-secrets aliases. Note, uploading ABAC or Kubernetes tokens.csv requires only an upload, the changes will be automatically reloade by [kube-auth](https://github.com/gambol99/kube-auth) service.

#### **- Bash Aliases**

There's a number of helper aliases and methods brought into the container (scripts/.bashrc)
