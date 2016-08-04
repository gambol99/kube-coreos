

#### **Building the build container**

The software requirements of the build are packaged up in a container; the Dockerfile for which can be found in the root. In order to build the container simply do a 'make' in the root folder. You can
then jump inside via run.kube script.

#### **Environments**

Before performing a build you need to specify the environment. Environment files are kept in the aptly names 'environments' folder in the base, with the scheme of ENVIRONMENT_NAME.tfvars. A sample file has been
left in the folder which details the bare minimum required to get a built going.

#### **Kubernetes Configuration**

At present the cluster is made of two layers, a secure service layer running the etcd masters and Kubernetes core services (api, controller and scheduler) and the compute layer which runs the kubelets (i.e. the nodes).


#### **Secrets Bucket**



#### **Kubernetes Services / Manifests**

Most of the Kubernetes service, barring the kubelet are deployed using manifests these are first templated via Terraform and uploaded to the secrets bucket. Two processes in the boxes (namely in the secure cloudinit) are responsible for keeping the manifests in sync with bucket versions, just updates the services should be a simple as amending the file, performing a run to template and upload and wait (default 10 seconds) for the files to be synchronized downstream; with the kubelet taking care of the rest. Why not, deploy the files as part of the cloudinit? At present the Kubenetes master is running on the Etcd cluster boxes, rolling out changes to these is precarious given it's affects on the cluster membership. Perhaps a better approach would be to add more boxes into the mix and run the Kubernetes core services in a additional auto-scaling group??   

#### **Post Run SSH Access**

During the setup (and redone on every run) the environment ssh key is copied into the $$HOME/.ssh/ in the container, so assuming you have updated the 'ssh_access_list' tfvar to include your source ip ranges, you should be able to ssh <IP> directly into the instances (core is assumed as the default user)

#### **Terraform Remote State**

Assuming you wish to use terraform remote state and I highly recommend you should, you need to create an s3 bucket for the remote state. Once the bucket has been created, we can add the 'terraform_bucket_name' variable to the terraform tfvars file. The bucket will be automatically provision and the state push on every run.
