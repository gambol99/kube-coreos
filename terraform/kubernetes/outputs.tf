#
## Module Outputs
#

output "aws_region"              { value = "${var.aws_region}" }
output "compute_asg_az"          { value = "${aws_autoscaling_group.compute.availability_zones}" }
output "compute_asg_id"          { value = "${aws_autoscaling_group.compute.id}" }
output "compute_asg_launch"      { value = "${aws_autoscaling_group.compute.launch_configuration}" }
output "compute_asg_name"        { value = "${aws_autoscaling_group.compute.name}" }
output "compute_size"            { value = "${var.compute_asg_min}" }
output "compute_subnets"         { value = "${join(",",aws_subnet.compute_subnets.*.id)}" }
output "domain_id"               { value = "${aws_route53_zone.default.id}" }
output "domain_name_servers"     { value = "${aws_route53_zone.default.name_servers}" }
output "domain_name"             { value = "${var.dns_zone_name}" }
output "environment"             { value = "${var.environment}" }
output "keypair_name"            { value = "${aws_key_pair.default.key_name}" }
output "kube_elb_dns_name"       { value = "${aws_elb.kube.dns_name}" }
output "route_table_id"          { value = "${aws_route_table.default.id}" }
output "secure_asg_az"           { value = "${aws_autoscaling_group.secure.availability_zones}" }
output "secure_asg_id"           { value = "${aws_autoscaling_group.secure.id}" }
output "secure_asg_launch"       { value = "${aws_autoscaling_group.secure.launch_configuration}" }
output "secure_asg_name"         { value = "${aws_autoscaling_group.secure.name}" }
output "secure_size"             { value = "${var.secure_asg_min}" }
output "secure_subnets"          { value = "${join(",",aws_subnet.secure_subnets.*.id)}" }
output "sg_compute_id"           { value = "${aws_security_group.compute.id}" }
output "sg_kube_elb_id"          { value = "${aws_security_group.kube_elb.id}" }
output "sg_kubeapi_elb_id"       { value = "${aws_security_group.kubeapi_elb.id}" }
output "sg_public_id"            { value = "${aws_security_group.public.id}" }
output "sg_secure_elb_id"        { value = "${aws_security_group.secure_elb.id}" }
output "sg_secure_id"            { value = "${aws_security_group.secure.id}" }
output "terraform_state_bucket"  { value = "${terraform_bucket_name}" }
output "terraform_state_key"     { value = "${var.aws_region}/${var.environment}/${var.platform}/terraform.tfstate" }
output "vpc_id"                  { value = "${aws_vpc.vpc.id}" }
