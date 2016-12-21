#
## Module Outputs
#

output "compute_asg_az"          { value = "${aws_autoscaling_group.compute.availability_zones}" }
output "compute_asg_id"          { value = "${aws_autoscaling_group.compute.id}" }
output "compute_asg_launch"      { value = "${aws_autoscaling_group.compute.launch_configuration}" }
output "compute_asg_name"        { value = "${aws_autoscaling_group.compute.name}" }
output "compute_size"            { value = "${var.compute_asg_min}" }
