
output "aws_profile"             { value = "${var.aws_profile}" }
output "aws_region"              { value = "${var.aws_region}" }
output "compute_sg"              { value = "${aws_security_group.compute.id}" }
output "elb_sg"                  { value = "${aws_security_group.elb.id}" }
output "key_name"                { value = "${aws_key_pair.default.key_name}" }
output "mgmt_sg"                 { value = "${aws_security_group.mgmt.id}" }
output "nat_route_table"         { value = "${aws_route_table.nat_routes.id}" }
output "nat_sg"                  { value = "${aws_security_group.public.id}" }
output "private_zone"            { value = "${aws_route53_zone.private.id}" }
output "public_zone"             { value = "${aws_route53_zone.public.id}" }
output "secrets_bucket_name"     { value = "${aws_s3_bucket.secrets.id}" }
output "secure_sg"               { value = "${aws_security_group.secure.id}" }
output "vpc_id"                  { value = "${aws_vpc.vpc.id}" }

output "public_nameservers"      { value = [ "${aws_route53_zone.public.name_servers}" ] }
output "nat_gateway_private_ips" { value = [ "${aws_nat_gateway.gateways.*.private_ip}" ] }
output "nat_gateway_public_ips"  { value = [ "${aws_nat_gateway.gateways.*.public_ip}" ] }
output "compute_subnets"         { value = [ "${aws_subnet.compute_subnets.*.id}" ] }
output "elb_subnets"             { value = [ "${aws_subnet.elb_subnets.*.id}" ] }
output "mgmt_subnets"            { value = [ "${aws_subnet.mgmt_subnets.*.id}" ] }
output "zone_route_tables"       { value = [ "${aws_route_table.zone_routes.*.id}" ] }
output "nat_subnets"             { value = [ "${aws_subnet.nat_subnets.*.id}" ] }
output "secure_subnets"          { value = [ "${aws_subnet.secure_subnets.*.id}" ] }
