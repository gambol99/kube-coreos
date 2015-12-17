#
## Module Outputs
#

output "aws_region"              { value = "${var.aws_region}" }
output "domain_name"             { value = "${var.dns_zone_name}" }
output "environment"             { value = "${var.environment}" }
output "keypair_name"            { value = "${aws_key_pair.default.key_name}" }
output "route_table_id"          { value = "${aws_route_table.default.id}" }
output "secure_api_elb_dns_name" { value = "${aws_elb.secure_api.dns_name}" }
output "sg_vault_elb_id"         { value = "${aws_security_group.vault_elb_sg.id}" }
output "sg_vault_id"             { value = "${aws_security_group.vault_sg.id}" }
output "vaul_elb_dns_name"       { value = "${aws_elb.vault.dns_name}" }
output "vault_asg_az"            { value = "${aws_autoscaling_group.vault.availability_zones}" }
output "vault_asg_id"            { value = "${aws_autoscaling_group.vault.id}" }
output "vault_asg_launch"        { value = "${aws_autoscaling_group.vault.launch_configuration}" }
output "vault_asg_name"          { value = "${aws_autoscaling_group.vault.name}" }
output "vault_size"              { value = "${var.vault_asg_min}" }
output "vault_subnets"           { value = "${join(",",aws_subnet.vault_subnets.*.id)}" }
output "vpc_id"                  { value = "${aws_vpc.vpc.id}" }
