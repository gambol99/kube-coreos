

#### **- Building the build container**

The software requirements of the build are packaged up in a container; the Dockerfile for which can be found in the root. In order to build the container simply do a 'make' in the root folder. You can
then jump inside via run.kube -e *ENV* script.

#### **- Environments**

Before performing a build you need to specify the environment. Environment files are kept in the aptly names 'environments' folder in the base, with the scheme of ENVIRONMENT_NAME.tfvars. A sample file has been
left in the folder which details the bare minimum required to get a built going.

```shell
aws_account              = "AWS_ACCOUNT|ALIAS"
aws_region               = "REQUIRED"
aws_profile              = "AWS_PROFILE"
compute_asg_grace_period = "10"
compute_asg_max          = "5"
compute_asg_min          = "1"
compute_flavor           = "t2.small"
coreos_image             = "ami-f4199987"
dns_zone_name            = "dsp.io"
environment              = "dev"
etcd_flavor              = "t2.small"
kms_master_id            = "REQUIRED"
kubeapi_access_list      = "IP,IP,IP"
platform                 = "kube"
secrets_bucket_name      = "dev-dsp-io-secrets-eu-west-1"
secure_asg_max           = "4"
secure_asg_min           = "3"
ssh_access_list          = "IP,IP"
terraform_bucket_name    = "dev-dsp-terraform-eu-west-1"
```

#### **- AWS Credentials**

The build assumes you are using an aws credentials file, the default location ${HOME}/.aws/credentials is automatically mapped into the container on start. Ensure you use the correct aws profile by setting the aws_profile in the platform environment file.

#### **- Building**

* Ensure you have created a AWS KMS key *(in the correct region)* and updated the kms_master_id in the environment file.
* Ensure you have created an S3 bucket for the terraform remote state and update the *terraform_bucket_name* variable in the environment file.
* Ensure you have a aws credentials file location in ${HOME}/.aws/credentials and have updated the environment file with the correct aws_profile and aws_account.
* Ensure you have updated the *kubeapi_access_list* and *ssh_access_list* environment variable to include your ip address.

```shell
[jest@starfury kubernetes-platform]$ ls environments/
dev.tfvars  env.tfvars.sample
[jest@starfury kubernetes-platform]$ ./run.kube -e dev
--> Running Platform, with environment: dev
# Perform a build run
# - will generate the certificates, secrets and start build the environment
[root@platform kube-coreos]$ scripts/run.sh
[root@platform kube-coreos]$ aws-instances
[root@platform kube-coreos]$ aws-instances 
-------------------------------------------------------------------------------------------
|                                    DescribeInstances                                    |
+-------------+----------------+-----------------+-------------+-----------+--------------+
|  dev-compute|  10.100.2.207  |  52.50.141.164  |  i-d9e30f54 |  running  |  eu-west-1c  |
|  dev-compute|  10.100.0.40   |  52.209.124.164 |  i-ec7a5560 |  running  |  eu-west-1a  |
|  dev-secure |  10.100.10.52  |  52.209.201.54  |  i-747a55f8 |  running  |  eu-west-1a  |
|  dev-secure |  10.100.10.51  |  52.209.195.91  |  i-777a55fb |  running  |  eu-west-1a  |
|  dev-secure |  10.100.12.23  |  52.209.195.176 |  i-36e20ebb |  running  |  eu-west-1c  |
+-------------+----------------+-----------------+-------------+-----------+--------------+
```

#### **- Kubernetes Configuration**

At present the cluster is made of two layers, a secure service layer running the etcd masters and Kubernetes core services (api, controller and scheduler) and the compute layer which runs the kubelets (i.e. the nodes).

#### **- Kubernetes Services / Manifests**

Most of the Kubernetes service, barring the kubelet are deployed using manifests these are first templated via Terraform and uploaded to the secrets bucket. Two processes in the boxes (namely in the secure cloudinit) are responsible for keeping the manifests in sync with bucket versions, just updates the services should be a simple as amending the file, performing a run to template and upload and wait (default 10 seconds) for the files to be synchronized downstream; with the kubelet taking care of the rest. Why not, deploy the files as part of the cloudinit? At present the Kubenetes master is running on the Etcd cluster boxes, rolling out changes to these is precarious given it's affects on the cluster membership. Perhaps a better approach would be to add more boxes into the mix and run the Kubernetes core services in a additional auto-scaling group??   

#### **- Post Run SSH Access**

During the setup (and redone on every run) the environment ssh key is copied into the $$HOME/.ssh/ in the container, so assuming you have updated the 'ssh_access_list' tfvar to include your source ip ranges, you should be able to ssh <IP> directly into the instances (core is assumed as the default user)

#### **- Terraform Remote State**

Assuming you wish to use terraform remote state and I highly recommend you should, you need to create an s3 bucket for the remote state. Once the bucket has been created, we can add the 'terraform_bucket_name' variable to the terraform tfvars file. The bucket will be automatically provision and the state push on every run.

