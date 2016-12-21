
## Etcd ENI Interfaces
resource "aws_network_interface" "etcd_eni" {
  count             = "${length(values(var.secure_nodes))}"
  private_ips       = [ "${element(values(var.secure_nodes), count.index)}" ]
  security_groups   = [ "${var.secure_sg}" ]
  source_dest_check = false
  subnet_id         = "${element(var.secure_subnets, lookup(var.secure_nodes_info, "${element(values(var.secure_nodes), count.index)}_subnet"))}"

  tags {
    Env     = "${var.environment}"
    Name    = "${var.environment}-etcd-data"
    NodeID  = "${count.index}"
  	Role    = "etcd-eni"
    Service = "etcd"
  }
}

## Etcd Data volumes
resource "aws_ebs_volume" "etcd_volumes" {
  count     = "${length(values(var.secure_nodes))}"
  encrypted = "${var.secure_data_encrypted}"
  size      = "${var.secure_data_volume}"
  availability_zone = "${lookup(var.secure_nodes_info, "${element(values(var.secure_nodes), count.index)}_zone")}"

  tags {
    Env    = "${var.environment}"
    Name   = "${var.environment}-etcd-node${count.index}"
    NodeID = "${count.index}"
  	Role   = "etcd-data"
  }
}
