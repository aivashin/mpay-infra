output "cluster_name" {
  value = "kuber.citadele.io"
}

output "master_security_group_ids" {
  value = ["${aws_security_group.masters-kuber-citadele-io.id}"]
}

output "masters_role_arn" {
  value = "${aws_iam_role.masters-kuber-citadele-io.arn}"
}

output "masters_role_name" {
  value = "${aws_iam_role.masters-kuber-citadele-io.name}"
}

output "node_security_group_ids" {
  value = ["${aws_security_group.nodes-kuber-citadele-io.id}"]
}

output "node_subnet_ids" {
  value = ["${aws_subnet.eu-west-1a-kuber-citadele-io.id}", "${aws_subnet.eu-west-1b-kuber-citadele-io.id}"]
}

output "nodes_role_arn" {
  value = "${aws_iam_role.nodes-kuber-citadele-io.arn}"
}

output "nodes_role_name" {
  value = "${aws_iam_role.nodes-kuber-citadele-io.name}"
}

output "region" {
  value = "eu-west-1"
}

output "vpc_id" {
  value = "${aws_vpc.kuber-citadele-io.id}"
}

provider "aws" {
  region = "eu-west-1"
}

resource "aws_autoscaling_attachment" "master-eu-west-1a-masters-kuber-citadele-io" {
  elb                    = "${aws_elb.api-kuber-citadele-io.id}"
  autoscaling_group_name = "${aws_autoscaling_group.master-eu-west-1a-masters-kuber-citadele-io.id}"
}

resource "aws_autoscaling_group" "master-eu-west-1a-masters-kuber-citadele-io" {
  name                 = "master-eu-west-1a.masters.kuber.citadele.io"
  launch_configuration = "${aws_launch_configuration.master-eu-west-1a-masters-kuber-citadele-io.id}"
  max_size             = 1
  min_size             = 1
  vpc_zone_identifier  = ["${aws_subnet.eu-west-1a-kuber-citadele-io.id}"]

  tag = {
    key                 = "KubernetesCluster"
    value               = "kuber.citadele.io"
    propagate_at_launch = true
  }

  tag = {
    key                 = "Name"
    value               = "master-eu-west-1a.masters.kuber.citadele.io"
    propagate_at_launch = true
  }

  tag = {
    key                 = "k8s.io/cluster-autoscaler/node-template/label/kops.k8s.io/instancegroup"
    value               = "master-eu-west-1a"
    propagate_at_launch = true
  }

  tag = {
    key                 = "k8s.io/role/master"
    value               = "1"
    propagate_at_launch = true
  }

  metrics_granularity = "1Minute"
  enabled_metrics     = ["GroupDesiredCapacity", "GroupInServiceInstances", "GroupMaxSize", "GroupMinSize", "GroupPendingInstances", "GroupStandbyInstances", "GroupTerminatingInstances", "GroupTotalInstances"]
}

resource "aws_autoscaling_group" "nodes-kuber-citadele-io" {
  name                 = "nodes.kuber.citadele.io"
  launch_configuration = "${aws_launch_configuration.nodes-kuber-citadele-io.id}"
  max_size             = 2
  min_size             = 2
  vpc_zone_identifier  = ["${aws_subnet.eu-west-1a-kuber-citadele-io.id}", "${aws_subnet.eu-west-1b-kuber-citadele-io.id}"]

  tag = {
    key                 = "KubernetesCluster"
    value               = "kuber.citadele.io"
    propagate_at_launch = true
  }

  tag = {
    key                 = "Name"
    value               = "nodes.kuber.citadele.io"
    propagate_at_launch = true
  }

  tag = {
    key                 = "k8s.io/cluster-autoscaler/node-template/label/kops.k8s.io/instancegroup"
    value               = "nodes"
    propagate_at_launch = true
  }

  tag = {
    key                 = "k8s.io/role/node"
    value               = "1"
    propagate_at_launch = true
  }

  metrics_granularity = "1Minute"
  enabled_metrics     = ["GroupDesiredCapacity", "GroupInServiceInstances", "GroupMaxSize", "GroupMinSize", "GroupPendingInstances", "GroupStandbyInstances", "GroupTerminatingInstances", "GroupTotalInstances"]
}

resource "aws_ebs_volume" "a-etcd-events-kuber-citadele-io" {
  availability_zone = "eu-west-1a"
  size              = 20
  type              = "gp2"
  encrypted         = false

  tags = {
    KubernetesCluster                         = "kuber.citadele.io"
    Name                                      = "a.etcd-events.kuber.citadele.io"
    "k8s.io/etcd/events"                      = "a/a"
    "k8s.io/role/master"                      = "1"
    "kubernetes.io/cluster/kuber.citadele.io" = "owned"
  }
}

resource "aws_ebs_volume" "a-etcd-main-kuber-citadele-io" {
  availability_zone = "eu-west-1a"
  size              = 20
  type              = "gp2"
  encrypted         = false

  tags = {
    KubernetesCluster                         = "kuber.citadele.io"
    Name                                      = "a.etcd-main.kuber.citadele.io"
    "k8s.io/etcd/main"                        = "a/a"
    "k8s.io/role/master"                      = "1"
    "kubernetes.io/cluster/kuber.citadele.io" = "owned"
  }
}

resource "aws_eip" "eu-west-1a-kuber-citadele-io" {
  vpc = true

  tags = {
    KubernetesCluster                         = "kuber.citadele.io"
    Name                                      = "eu-west-1a.kuber.citadele.io"
    "kubernetes.io/cluster/kuber.citadele.io" = "owned"
  }
}

resource "aws_eip" "eu-west-1b-kuber-citadele-io" {
  vpc = true

  tags = {
    KubernetesCluster                         = "kuber.citadele.io"
    Name                                      = "eu-west-1b.kuber.citadele.io"
    "kubernetes.io/cluster/kuber.citadele.io" = "owned"
  }
}

resource "aws_elb" "api-kuber-citadele-io" {
  name = "api-kuber-citadele-io-64bhc7"

  listener = {
    instance_port     = 443
    instance_protocol = "TCP"
    lb_port           = 443
    lb_protocol       = "TCP"
  }

  security_groups = ["${aws_security_group.api-elb-kuber-citadele-io.id}"]
  subnets         = ["${aws_subnet.utility-eu-west-1a-kuber-citadele-io.id}", "${aws_subnet.utility-eu-west-1b-kuber-citadele-io.id}"]

  health_check = {
    target              = "SSL:443"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 10
    timeout             = 5
  }

  idle_timeout = 300

  tags = {
    KubernetesCluster = "kuber.citadele.io"
    Name              = "api.kuber.citadele.io"
  }
}

resource "aws_iam_instance_profile" "masters-kuber-citadele-io" {
  name = "masters.kuber.citadele.io"
  role = "${aws_iam_role.masters-kuber-citadele-io.name}"
}

resource "aws_iam_instance_profile" "nodes-kuber-citadele-io" {
  name = "nodes.kuber.citadele.io"
  role = "${aws_iam_role.nodes-kuber-citadele-io.name}"
}

resource "aws_iam_role" "masters-kuber-citadele-io" {
  name               = "masters.kuber.citadele.io"
  assume_role_policy = "${file("${path.module}/data/aws_iam_role_masters.kuber.citadele.io_policy")}"
}

resource "aws_iam_role" "nodes-kuber-citadele-io" {
  name               = "nodes.kuber.citadele.io"
  assume_role_policy = "${file("${path.module}/data/aws_iam_role_nodes.kuber.citadele.io_policy")}"
}

resource "aws_iam_role_policy" "masters-kuber-citadele-io" {
  name   = "masters.kuber.citadele.io"
  role   = "${aws_iam_role.masters-kuber-citadele-io.name}"
  policy = "${file("${path.module}/data/aws_iam_role_policy_masters.kuber.citadele.io_policy")}"
}

resource "aws_iam_role_policy" "nodes-kuber-citadele-io" {
  name   = "nodes.kuber.citadele.io"
  role   = "${aws_iam_role.nodes-kuber-citadele-io.name}"
  policy = "${file("${path.module}/data/aws_iam_role_policy_nodes.kuber.citadele.io_policy")}"
}

resource "aws_internet_gateway" "kuber-citadele-io" {
  vpc_id = "${aws_vpc.kuber-citadele-io.id}"

  tags = {
    KubernetesCluster                         = "kuber.citadele.io"
    Name                                      = "kuber.citadele.io"
    "kubernetes.io/cluster/kuber.citadele.io" = "owned"
  }
}

resource "aws_key_pair" "kubernetes-kuber-citadele-io-9ce12b9b8c347213dfe5c96c118d6a4a" {
  key_name   = "kubernetes.kuber.citadele.io-9c:e1:2b:9b:8c:34:72:13:df:e5:c9:6c:11:8d:6a:4a"
  public_key = "${file("${path.module}/data/aws_key_pair_kubernetes.kuber.citadele.io-9ce12b9b8c347213dfe5c96c118d6a4a_public_key")}"
}

resource "aws_launch_configuration" "master-eu-west-1a-masters-kuber-citadele-io" {
  name_prefix                 = "master-eu-west-1a.masters.kuber.citadele.io-"
  image_id                    = "ami-9084cbe9"
  instance_type               = "t2.large"
  key_name                    = "${aws_key_pair.kubernetes-kuber-citadele-io-9ce12b9b8c347213dfe5c96c118d6a4a.id}"
  iam_instance_profile        = "${aws_iam_instance_profile.masters-kuber-citadele-io.id}"
  security_groups             = ["${aws_security_group.masters-kuber-citadele-io.id}"]
  associate_public_ip_address = false
  user_data                   = "${file("${path.module}/data/aws_launch_configuration_master-eu-west-1a.masters.kuber.citadele.io_user_data")}"

  root_block_device = {
    volume_type           = "gp2"
    volume_size           = 64
    delete_on_termination = true
  }

  lifecycle = {
    create_before_destroy = true
  }

  enable_monitoring = false
}

resource "aws_launch_configuration" "nodes-kuber-citadele-io" {
  name_prefix                 = "nodes.kuber.citadele.io-"
  image_id                    = "ami-9084cbe9"
  instance_type               = "t2.large"
  key_name                    = "${aws_key_pair.kubernetes-kuber-citadele-io-9ce12b9b8c347213dfe5c96c118d6a4a.id}"
  iam_instance_profile        = "${aws_iam_instance_profile.nodes-kuber-citadele-io.id}"
  security_groups             = ["${aws_security_group.nodes-kuber-citadele-io.id}"]
  associate_public_ip_address = false
  user_data                   = "${file("${path.module}/data/aws_launch_configuration_nodes.kuber.citadele.io_user_data")}"

  root_block_device = {
    volume_type           = "gp2"
    volume_size           = 128
    delete_on_termination = true
  }

  lifecycle = {
    create_before_destroy = true
  }

  enable_monitoring = false
}

resource "aws_nat_gateway" "eu-west-1a-kuber-citadele-io" {
  allocation_id = "${aws_eip.eu-west-1a-kuber-citadele-io.id}"
  subnet_id     = "${aws_subnet.utility-eu-west-1a-kuber-citadele-io.id}"

  tags = {
    KubernetesCluster                         = "kuber.citadele.io"
    Name                                      = "eu-west-1a.kuber.citadele.io"
    "kubernetes.io/cluster/kuber.citadele.io" = "owned"
  }
}

resource "aws_nat_gateway" "eu-west-1b-kuber-citadele-io" {
  allocation_id = "${aws_eip.eu-west-1b-kuber-citadele-io.id}"
  subnet_id     = "${aws_subnet.utility-eu-west-1b-kuber-citadele-io.id}"

  tags = {
    KubernetesCluster                         = "kuber.citadele.io"
    Name                                      = "eu-west-1b.kuber.citadele.io"
    "kubernetes.io/cluster/kuber.citadele.io" = "owned"
  }
}

resource "aws_route" "0-0-0-0--0" {
  route_table_id         = "${aws_route_table.kuber-citadele-io.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.kuber-citadele-io.id}"
}

resource "aws_route" "private-eu-west-1a-0-0-0-0--0" {
  route_table_id         = "${aws_route_table.private-eu-west-1a-kuber-citadele-io.id}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = "${aws_nat_gateway.eu-west-1a-kuber-citadele-io.id}"
}

resource "aws_route" "private-eu-west-1b-0-0-0-0--0" {
  route_table_id         = "${aws_route_table.private-eu-west-1b-kuber-citadele-io.id}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = "${aws_nat_gateway.eu-west-1b-kuber-citadele-io.id}"
}

resource "aws_route53_record" "api-kuber-citadele-io" {
  name = "api.kuber.citadele.io"
  type = "A"

  alias = {
    name                   = "${aws_elb.api-kuber-citadele-io.dns_name}"
    zone_id                = "${aws_elb.api-kuber-citadele-io.zone_id}"
    evaluate_target_health = false
  }

  zone_id = "/hostedzone/Z3RYQ53D5CK053"
}

resource "aws_route_table" "kuber-citadele-io" {
  vpc_id = "${aws_vpc.kuber-citadele-io.id}"

  tags = {
    KubernetesCluster                         = "kuber.citadele.io"
    Name                                      = "kuber.citadele.io"
    "kubernetes.io/cluster/kuber.citadele.io" = "owned"
    "kubernetes.io/kops/role"                 = "public"
  }
}

resource "aws_route_table" "private-eu-west-1a-kuber-citadele-io" {
  vpc_id = "${aws_vpc.kuber-citadele-io.id}"

  tags = {
    KubernetesCluster                         = "kuber.citadele.io"
    Name                                      = "private-eu-west-1a.kuber.citadele.io"
    "kubernetes.io/cluster/kuber.citadele.io" = "owned"
    "kubernetes.io/kops/role"                 = "private-eu-west-1a"
  }
}

resource "aws_route_table" "private-eu-west-1b-kuber-citadele-io" {
  vpc_id = "${aws_vpc.kuber-citadele-io.id}"

  tags = {
    KubernetesCluster                         = "kuber.citadele.io"
    Name                                      = "private-eu-west-1b.kuber.citadele.io"
    "kubernetes.io/cluster/kuber.citadele.io" = "owned"
    "kubernetes.io/kops/role"                 = "private-eu-west-1b"
  }
}

resource "aws_route_table_association" "private-eu-west-1a-kuber-citadele-io" {
  subnet_id      = "${aws_subnet.eu-west-1a-kuber-citadele-io.id}"
  route_table_id = "${aws_route_table.private-eu-west-1a-kuber-citadele-io.id}"
}

resource "aws_route_table_association" "private-eu-west-1b-kuber-citadele-io" {
  subnet_id      = "${aws_subnet.eu-west-1b-kuber-citadele-io.id}"
  route_table_id = "${aws_route_table.private-eu-west-1b-kuber-citadele-io.id}"
}

resource "aws_route_table_association" "utility-eu-west-1a-kuber-citadele-io" {
  subnet_id      = "${aws_subnet.utility-eu-west-1a-kuber-citadele-io.id}"
  route_table_id = "${aws_route_table.kuber-citadele-io.id}"
}

resource "aws_route_table_association" "utility-eu-west-1b-kuber-citadele-io" {
  subnet_id      = "${aws_subnet.utility-eu-west-1b-kuber-citadele-io.id}"
  route_table_id = "${aws_route_table.kuber-citadele-io.id}"
}

resource "aws_security_group" "api-elb-kuber-citadele-io" {
  name        = "api-elb.kuber.citadele.io"
  vpc_id      = "${aws_vpc.kuber-citadele-io.id}"
  description = "Security group for api ELB"

  tags = {
    KubernetesCluster                         = "kuber.citadele.io"
    Name                                      = "api-elb.kuber.citadele.io"
    "kubernetes.io/cluster/kuber.citadele.io" = "owned"
  }
}

resource "aws_security_group" "masters-kuber-citadele-io" {
  name        = "masters.kuber.citadele.io"
  vpc_id      = "${aws_vpc.kuber-citadele-io.id}"
  description = "Security group for masters"

  tags = {
    KubernetesCluster                         = "kuber.citadele.io"
    Name                                      = "masters.kuber.citadele.io"
    "kubernetes.io/cluster/kuber.citadele.io" = "owned"
  }
}

resource "aws_security_group" "nodes-kuber-citadele-io" {
  name        = "nodes.kuber.citadele.io"
  vpc_id      = "${aws_vpc.kuber-citadele-io.id}"
  description = "Security group for nodes"

  tags = {
    KubernetesCluster                         = "kuber.citadele.io"
    Name                                      = "nodes.kuber.citadele.io"
    "kubernetes.io/cluster/kuber.citadele.io" = "owned"
  }
}

resource "aws_security_group_rule" "all-master-to-master" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.masters-kuber-citadele-io.id}"
  source_security_group_id = "${aws_security_group.masters-kuber-citadele-io.id}"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
}

resource "aws_security_group_rule" "all-master-to-node" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.nodes-kuber-citadele-io.id}"
  source_security_group_id = "${aws_security_group.masters-kuber-citadele-io.id}"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
}

resource "aws_security_group_rule" "all-node-to-node" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.nodes-kuber-citadele-io.id}"
  source_security_group_id = "${aws_security_group.nodes-kuber-citadele-io.id}"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
}

resource "aws_security_group_rule" "api-elb-egress" {
  type              = "egress"
  security_group_id = "${aws_security_group.api-elb-kuber-citadele-io.id}"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "https-api-elb-0-0-0-0--0" {
  type              = "ingress"
  security_group_id = "${aws_security_group.api-elb-kuber-citadele-io.id}"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "https-elb-to-master" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.masters-kuber-citadele-io.id}"
  source_security_group_id = "${aws_security_group.api-elb-kuber-citadele-io.id}"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
}

resource "aws_security_group_rule" "master-egress" {
  type              = "egress"
  security_group_id = "${aws_security_group.masters-kuber-citadele-io.id}"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "node-egress" {
  type              = "egress"
  security_group_id = "${aws_security_group.nodes-kuber-citadele-io.id}"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "node-to-master-protocol-ipip" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.masters-kuber-citadele-io.id}"
  source_security_group_id = "${aws_security_group.nodes-kuber-citadele-io.id}"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "4"
}

resource "aws_security_group_rule" "node-to-master-tcp-1-2379" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.masters-kuber-citadele-io.id}"
  source_security_group_id = "${aws_security_group.nodes-kuber-citadele-io.id}"
  from_port                = 1
  to_port                  = 2379
  protocol                 = "tcp"
}

resource "aws_security_group_rule" "node-to-master-tcp-2382-4000" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.masters-kuber-citadele-io.id}"
  source_security_group_id = "${aws_security_group.nodes-kuber-citadele-io.id}"
  from_port                = 2382
  to_port                  = 4000
  protocol                 = "tcp"
}

resource "aws_security_group_rule" "node-to-master-tcp-4003-65535" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.masters-kuber-citadele-io.id}"
  source_security_group_id = "${aws_security_group.nodes-kuber-citadele-io.id}"
  from_port                = 4003
  to_port                  = 65535
  protocol                 = "tcp"
}

resource "aws_security_group_rule" "node-to-master-udp-1-65535" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.masters-kuber-citadele-io.id}"
  source_security_group_id = "${aws_security_group.nodes-kuber-citadele-io.id}"
  from_port                = 1
  to_port                  = 65535
  protocol                 = "udp"
}

resource "aws_security_group_rule" "ssh-external-to-master-0-0-0-0--0" {
  type              = "ingress"
  security_group_id = "${aws_security_group.masters-kuber-citadele-io.id}"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "ssh-external-to-node-0-0-0-0--0" {
  type              = "ingress"
  security_group_id = "${aws_security_group.nodes-kuber-citadele-io.id}"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_subnet" "eu-west-1a-kuber-citadele-io" {
  vpc_id            = "${aws_vpc.kuber-citadele-io.id}"
  cidr_block        = "172.20.32.0/19"
  availability_zone = "eu-west-1a"

  tags = {
    KubernetesCluster                         = "kuber.citadele.io"
    Name                                      = "eu-west-1a.kuber.citadele.io"
    SubnetType                                = "Private"
    "kubernetes.io/cluster/kuber.citadele.io" = "owned"
    "kubernetes.io/role/internal-elb"         = "1"
  }
}

resource "aws_subnet" "eu-west-1b-kuber-citadele-io" {
  vpc_id            = "${aws_vpc.kuber-citadele-io.id}"
  cidr_block        = "172.20.64.0/19"
  availability_zone = "eu-west-1b"

  tags = {
    KubernetesCluster                         = "kuber.citadele.io"
    Name                                      = "eu-west-1b.kuber.citadele.io"
    SubnetType                                = "Private"
    "kubernetes.io/cluster/kuber.citadele.io" = "owned"
    "kubernetes.io/role/internal-elb"         = "1"
  }
}

resource "aws_subnet" "utility-eu-west-1a-kuber-citadele-io" {
  vpc_id            = "${aws_vpc.kuber-citadele-io.id}"
  cidr_block        = "172.20.0.0/22"
  availability_zone = "eu-west-1a"

  tags = {
    KubernetesCluster                         = "kuber.citadele.io"
    Name                                      = "utility-eu-west-1a.kuber.citadele.io"
    SubnetType                                = "Utility"
    "kubernetes.io/cluster/kuber.citadele.io" = "owned"
    "kubernetes.io/role/elb"                  = "1"
  }
}

resource "aws_subnet" "utility-eu-west-1b-kuber-citadele-io" {
  vpc_id            = "${aws_vpc.kuber-citadele-io.id}"
  cidr_block        = "172.20.4.0/22"
  availability_zone = "eu-west-1b"

  tags = {
    KubernetesCluster                         = "kuber.citadele.io"
    Name                                      = "utility-eu-west-1b.kuber.citadele.io"
    SubnetType                                = "Utility"
    "kubernetes.io/cluster/kuber.citadele.io" = "owned"
    "kubernetes.io/role/elb"                  = "1"
  }
}

resource "aws_vpc" "kuber-citadele-io" {
  cidr_block           = "172.20.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    KubernetesCluster                         = "kuber.citadele.io"
    Name                                      = "kuber.citadele.io"
    "kubernetes.io/cluster/kuber.citadele.io" = "owned"
  }
}

resource "aws_vpc_dhcp_options" "kuber-citadele-io" {
  domain_name         = "eu-west-1.compute.internal"
  domain_name_servers = ["AmazonProvidedDNS"]

  tags = {
    KubernetesCluster                         = "kuber.citadele.io"
    Name                                      = "kuber.citadele.io"
    "kubernetes.io/cluster/kuber.citadele.io" = "owned"
  }
}

resource "aws_vpc_dhcp_options_association" "kuber-citadele-io" {
  vpc_id          = "${aws_vpc.kuber-citadele-io.id}"
  dhcp_options_id = "${aws_vpc_dhcp_options.kuber-citadele-io.id}"
}

terraform = {
  required_version = ">= 0.9.3"
}
