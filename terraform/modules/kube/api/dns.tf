
## DNS Name for Secure API ELB
resource "aws_route53_record" "kubeapi" {
  zone_id = "${var.private_zone}"
  name    = "${var.kubeapi_internal_dns}"
  type    = "A"

  alias {
    name                   = "${aws_elb.kubeapi_internal.dns_name}"
    zone_id                = "${aws_elb.kubeapi_internal.zone_id}"
    evaluate_target_health = true
  }
}


## DNS Name for Kube API ELB
resource "aws_route53_record" "kube" {
  zone_id = "${var.public_zone}"
  name    = "${var.kubeapi_dns}"
  type    = "A"

  alias {
    name                   = "${aws_elb.kubeapi.dns_name}"
    zone_id                = "${aws_elb.kubeapi.zone_id}"
    evaluate_target_health = true
  }
}
