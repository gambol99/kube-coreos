
#### **- Building the build container**

All the software requirements of the build are packaged up in a container; the Dockerfile for which can be found in the root. In order to build the container simply do a 'make' in the root folder. You can then jump inside via run.kube -e *ENV* script or use a playground via ./play.kube

#### **- Environments**

The environments are kept in the root environments directory. Note, when using a playground entrypoint (./play.kube) a default comfiguration is copied for you taking the environment name of play-<USERNAME>. Altnatively you can look at the variables.tf in the terraform directory to find all the attributes and settings.

#### **- AWS Credentials**

The build assumes you are using an aws credentials file, the default location ${HOME}/.aws/credentials is automatically mapped into the container on start. Ensure you use the correct aws profile by setting the aws_profile in the platform environment file and the correct permissions on the IAM account.

#### **- Building**

There are two prerequestes before doing a build, namely the KMS key use for at-rest encryption of the secrets and the terraform state bucket (though this one might be wrapped up in the script by now).

* Ensure you have created a AWS KMS key *(in the correct region)* and updated the kms_master_id with the KeyID in the environment file.
* Ensure you have created an S3 bucket for the terraform remote state and update the *terraform_bucket_name* variable in the environment file.
* Ensure you have a aws credentials file location in ${HOME}/.aws/credentials and have updated the environment file with the correct aws_profile and aws_account.
* Ensure you have updated the *kubeapi_access_list* and *ssh_access_list* environment variable to include your ip address.

```shell
[jest@starfury kubernetes-platform]$ ./play.kube
--> Running Platform, with environment: play-jest
[play-jest@platform]$
# Perform a build run
# - will generate the certificates, secrets and start build the environment
[play-jest@platform]$ run
... BUILDING ...
[play-jest@platform]$ aws-instances
-------------------------------------------------------------------------------------------
|                                    DescribeInstances                                    |
+-------------+----------------+-----------------+-------------+-----------+--------------+
|  dev-compute|  10.100.2.207  |  52.50.141.164  |  i-d9e30f54 |  running  |  eu-west-1c  |
|  dev-compute|  10.100.0.40   |  52.209.124.164 |  i-ec7a5560 |  running  |  eu-west-1a  |
|  dev-secure |  10.100.10.52  |  52.209.201.54  |  i-747a55f8 |  running  |  eu-west-1a  |
|  dev-secure |  10.100.10.51  |  52.209.195.91  |  i-777a55fb |  running  |  eu-west-1a  |
|  dev-secure |  10.100.12.23  |  52.209.195.176 |  i-36e20ebb |  running  |  eu-west-1c  |
+-------------+----------------+-----------------+-------------+-----------+--------------+

# list the Kubernetes api ELB
[play-jest@platform]$ aws-elbs
--------------------------------------------------------------------------------------
|                                DescribeLoadBalancers                               |
+----------------+-------------------------------------------------------------------+
|  dev-kubeapi   |  dev-kubeapi-1815972942.eu-west-1.elb.amazonaws.com               |
|  dev-kube-elb  |  internal-dev-kube-elb-457444291.eu-west-1.elb.amazonaws.com      |
|  dev-secure-elb|  internal-dev-secure-elb-1990127985.eu-west-1.elb.amazonaws.com   |
+----------------+-------------------------------------------------------------------+

[root@platform kube-coreos]$  kubectl -s https://dev-kubeapi-1815972942.eu-west-1.elb.amazonaws.com get ns
NAME          STATUS    AGE
default       Active    20m
kube-system   Active    20m
```

#### **- Kubernetes Configuration**

The environment is broken into two main layer, secure and compute. Secure is where the Kubernetes master, controller and scheduler live, with compute being the worker nodes. The entire cluster is hidden on private subnets (secure, compute) with external internet access provided via the managed nat gateways. Note, the secure and compute subnets are not directly connected to a internet gateway, instead outbound in via nat and inbound load balancers must be place into the 'elb' subnets. Another subnet 'mgmt' (connected to the IGW) is where the bastion host lives. Note, I still need to finish of the bastion module!!

#### **- Etcd Cluster**

The Etcd cluster which runs in the secure layer is made of a auto-scaling group spread across x availablity zones; terraform for create x EBS volumes and x ENI for the cluster nodes; the bootstrapping of the cluster involves a node in a ASG coming up, looking for available volumes and ENI's in it's availablity zone and attaching before starting etcd2. The process essentially wrapps static volumes and ip addresses to a bunch of random auto-scaling nodes.

#### **- Kubernetes Services / Manifests**

Most of the Kubernetes service, barring the kubelet are deployed using manifests these are first templated via Terraform and uploaded to the secrets bucket. Two processes in the boxes (namely in the secure cloudinit) are responsible for keeping the manifests in sync with bucket versions, just updates the services should be a simple as amending the file, performing a run to template and upload and wait (default 10 seconds) for the files to be synchronized downstream; with the kubelet taking care of the rest. Why not, deploy the files as part of the cloudinit? At present the Kubenetes master is running on the Etcd cluster boxes, rolling out changes to these is precarious given it's affects on the cluster membership. Perhaps a better approach would be to add more boxes into the mix and run the Kubernetes core services in a additional auto-scaling group??

#### **- Secrets**

All the secrets for the platform are kept in an s3 bucket and encrypted via KMS. Once the platform is built you can check directory structure under platform/secrets. Pulling or uploading the secrets simply involves fetch-secrets or upload-secrets aliases. Note, uploading ABAC or Kubernetes tokens.csv requires only an upload of the changes secrets as the kube-auth container (k8s webhook bridge) will take care of the reloading for the file.

#### **- Terraform Remote State**

Assuming you wish to use terraform remote state and I highly recommend you should, you need to create an s3 bucket for the remote state. Once the bucket has been created, we can add the 'terraform_bucket_name' variable to the terraform tfvars file. The bucket will be automatically provision and the state push on every run.

#### **- Bash Aliases**

There's a number of helper aliases and methods brought into the container (scripts/.bashrc)
