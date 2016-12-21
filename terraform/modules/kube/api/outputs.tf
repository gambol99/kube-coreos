
output "kubeapi_dns_aws"        { value = "https://${aws_elb.kubeapi.dns_name}" }
output "kubeapi_dns"            { value = "https://${var.kubeapi_dns}.${var.public_zone_name}" }
output "kubeapi_internal_dns"   { value = "https://${var.kubeapi_internal_dns}.${var.private_zone_name}" }
