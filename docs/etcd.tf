#
# Secure Layer
#

# the etcd userdata template
#resource "template_file" "etcd_userdata" {
#  template = "${file(\"resources/templates/etcd.yml\")}"
#  count    = "${var.etcd_nodes}"
#  vars = {
#    aws_region             = "${var.aws_region}"
#    dns_zone_name          = "${var.dns_zone_name}"
#    environment            = "${var.environment}"
#    fqdn                   = "etcd${count.index}.${var.dns_zone_name}"
#    hostname               = "etcd${count.index}"
#    kubernetes_release_md5 = "${var.kubernetes_release_md5}"
#    kubernetes_release_url = "${var.kubernetes_release_url}"
#    s3secrets_release_md5  = "${var.s3secrets_release_md5}"
#    s3secrets_release_url  = "${var.s3secrets_release_url}"
#    secrets_bucket_name    = "${var.secrets_bucket_name}"
#  }
#}
#
## the instance policy template
#resource "template_file" "etcd_policy" {
#  template = "${file(\"resources/policies/etcd.json\")}"
#  vars = {
#    aws_region          = "${var.aws_region}"
#    environment         = "${var.environment}"
#    kms_master_id       = "${var.kms_master_id}"
#    secrets_bucket_name = "${var.secrets_bucket_name}"
#  }
#}
#
## etcd role
#resource "aws_iam_role_policy" "etcd_policy" {
#  name   = "${var.environment}-etcd-role"
#  role   = "${aws_iam_role.etcd_role.id}"
#  policy = "${template_file.etcd_policy.rendered}"
#}
#
# instance profile
#resource "aws_iam_instance_profile" "etcd_instance_profile" {
#  name  = "${var.environment}-etcd-instance-profile"
#  roles = [ "${aws_iam_role.etcd_role.name}" ]
#}
#
## etcd instances
#resource "aws_instance" "etcd" {
#    depends_on = [
#      "aws_subnet.secure_subnets",
#      "aws_route53_zone.default",
#      "aws_iam_role.etcd_role"
#    ]
#
#    security_groups = [
#      "${aws_security_group.secure_default_sg.id}"
#    ]
#    ami                         = "${lookup(var.compute_ami, var.aws_region)}"
#    associate_public_ip_address = true
#    availability_zone           = "${lookup(var.etcd_hosts, \"etcd_${count.index}_zone\")}"
#    count                       = "${var.etcd_nodes}"
#    iam_instance_profile        = "${aws_iam_instance_profile.etcd_instance_profile.name}"
#    instance_type               = "${var.instance_flavor_etcd}"
#    key_name                    = "${aws_key_pair.default.id}"
#    monitoring                  = false
#    private_ip                  = "${lookup(var.etcd_hosts, \"etcd_${count.index}_private_ip\")}"
#    subnet_id                   = "${element(aws_subnet.secure_subnets.*.id, #lookup(var.etcd_hosts,\"etcd_${count.index}_zone_id\"))}"
#    user_data                   = "${element(template_file.etcd_userdata.*.rendered, count.index)}"
#
#    tags {
#        Name = "${var.environment}-etcd${count.index}"
#        Env  = "${var.environment}"
#        Role = "etcd"
#    }
#
#    root_block_device = {
#      delete_on_termination = true
#      volume_size           = "${var.root_volume_size}"
#      volume_type           = "gp2"
#    }
}

#
# ========= ETCD DATA VOLUME RELATED RESOURCES ===============
#

# the etcd data volumes
#resource "aws_ebs_volume" "etcd_volumes" {
#  count             = "${var.etcd_nodes}"
#  availability_zone = "${lookup(var.etcd_hosts, \"etcd_${count.index}_zone\")}"
#  size              = "${var.etcd_data_volume_size}"
#  tags {
#    Name = "${var.environment}-etcd${count.index}-data-volume"
#    Env  = "${var.environment}"
#  }
#}
#
## attach the volume to the etcd instances
#resource "aws_volume_attachment" "etcd_volume_attach" {
#  count        = "${var.etcd_nodes}"
#  device_name  = "/dev/xvdd"
#  volume_id    = "${element(aws_ebs_volume.etcd_volumes.*.id, count.index)}"
#  instance_id  = "${element(aws_instance.etcd.*.id, count.index)}"
#}
#
##
## ========= DNS RELATED RESOURCES ===============
##
#
## create's x etcd_service_record resources - used by the formatlist to add the service records
#resource "template_file" "etcd_service_record" {
#  template = "etcd${count.index}.${var.dns_zone_name}"
#  count    = "${var.etcd_nodes}"
#  vars {
#    index = "${count.index}"
#  }
#}
#
## add the a record for the etcd node
#resource "aws_route53_record" "etcd_a_record" {
#  count   = "${var.etcd_nodes}"
#  name    = "etcd${count.index}"
#  records = ["${element(aws_instance.etcd.*.private_ip, count.index)}"]
#  ttl     = "120"
#  type    = "A"
#  zone_id = "${aws_route53_zone.default.zone_id}"
#}
#
## the etcd service record - used for cluster discovery
#resource "aws_route53_record" "etcd_srv_record" {
#  depends_on = [
#    "aws_route53_record.etcd_a_record"
#  ]
#  zone_id = "${aws_route53_zone.default.id}"
#  name    = "_etcd-server-ssl._tcp.${var.dns_zone_name}"
#  type    = "SRV"
#  ttl     = "1"
#  records = ["${formatlist(\"0 0 2380 %s\", template_file.etcd_service_record.*.rendered)}"]
#}
#
