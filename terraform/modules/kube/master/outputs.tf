#
## Module Outputs
#

output "environment"             { value = "${var.environment}" }
output "secure_asg_az"           { value = "${aws_autoscaling_group.secure.availability_zones}" }
output "etcd_members_url"        { value = "${join(",", formatlist("%s=https://%s:2380", keys(var.secure_nodes), values(var.secure_nodes)))}" }
output "flannel_members_url"     { value = "${join(",", formatlist("https://%s:2379", values(var.secure_nodes)))}" }
output "secure_asg"              { value = "${aws_autoscaling_group.secure.id}" }
output "secure_asg_launch"       { value = "${aws_autoscaling_group.secure.launch_configuration}" }
output "secure_asg_name"         { value = "${aws_autoscaling_group.secure.name}" }

output "etcd_data_volumes"       { value = [ "${aws_ebs_volume.etcd_volumes.*.id}" ] }
output "etcd_enis"               { value = [ "${aws_network_interface.etcd_eni.*.id}" ] }
