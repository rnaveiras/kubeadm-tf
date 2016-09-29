resource "aws_launch_configuration" "nodes" {
  name_prefix   = "node-"
  image_id      = "${data.aws_ami.ubuntu.id}"
  instance_type = "t2.large"

  security_groups = ["${aws_security_group.ssh.id}",
    "${aws_security_group.icmp.id}",
    "${aws_security_group.outgress.id}",
    "${aws_security_group.kube.id}",
  ]

  iam_instance_profile = "${aws_iam_instance_profile.nodes.name}"
  key_name             = "${aws_key_pair.kube.key_name}"

  lifecycle {
    create_before_destroy = true
  }

  root_block_device {
    volume_type           = "gp2"
    volume_size           = 20
    delete_on_termination = true
  }

  associate_public_ip_address = true

  user_data = "${data.template_cloudinit_config.nodes.rendered}"
}

resource "aws_autoscaling_group" "nodes" {
  name                 = "nodes"
  launch_configuration = "${aws_launch_configuration.nodes.name}"

  desired_capacity     = "${var.nodes_num}"
  min_size             = "${var.nodes_num}"
  max_size             = "${var.nodes_num}"
  termination_policies = ["OldestInstance"]
  health_check_type    = "EC2"

  vpc_zone_identifier = ["${aws_subnet.public.*.id}"]

  lifecycle {
    create_before_destroy = true
  }

  tag {
    key                 = "Name"
    value               = "nodes"
    propagate_at_launch = true
  }

  depends_on = ["aws_instance.control_plane"]
}

data "template_file" "nodes" {
  template = "${file("${path.root}/nodes.tpl")}"

  vars {
    k8s_token        = "${var.k8s_token}"
    control_plane_ip = "${aws_instance.control_plane.private_ip}"
  }
}

data "template_file" "kubeadm_join" {
  template = "${file("${path.root}/kubeadm_join.tpl")}"

  vars {
    k8s_token        = "${var.k8s_token}"
    control_plane_ip = "${aws_instance.control_plane.private_ip}"
  }
}

data "template_cloudinit_config" "nodes" {
  gzip          = false
  base64_encode = false

  part {
    content_type = "text/cloud-config"
    content      = "${data.template_file.nodes.rendered}"
  }

  /* part {
    content_type = "text/x-shellscript"
    content      = "${data.template_file.kubeadm_join.rendered}"
  } */
}
