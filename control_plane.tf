/*
resource "aws_launch_configuration" "control_plane" {
  name_prefix   = "control-plane-"
  image_id      = "${data.aws_ami.ubuntu.id}"
  instance_type = "t2.large"

  security_groups = ["${aws_security_group.ssh.id}",
    "${aws_security_group.icmp.id}",
    "${aws_security_group.outgress.id}",
    "${aws_security_group.kube.id}",
  ]

  iam_instance_profile = "${aws_iam_instance_profile.control_plane.name}"
  key_name             = "${aws_key_pair.kube.key_name}"

  lifecycle {
    create_before_destroy = true
  }

  root_block_device {
    volume_type           = "gp2"
    volume_size           = 20
    delete_on_termination = true
  }

  ebs_block_device {
    device_name           = "/dev/xvdb"
    volume_type           = "gp2"
    volume_size           = 20
    delete_on_termination = false
  }

  associate_public_ip_address = true

  user_data = "${data.template_cloudinit_config.control_plane.rendered}"
}

resource "aws_autoscaling_group" "control_plane" {
  name                 = "control-plane"
  launch_configuration = "${aws_launch_configuration.control_plane.name}"

  desired_capacity     = "${var.control_plane_num}"
  min_size             = "${var.control_plane_num}"
  max_size             = "${var.control_plane_num + 1}"
  termination_policies = ["OldestInstance"]
  health_check_type    = "EC2"

  vpc_zone_identifier = ["${aws_subnet.public.*.id}"]

  lifecycle {
    create_before_destroy = true
  }

  wait_for_capacity_timeout = "15m"

  tag {
    key                 = "Name"
    value               = "control-plane"
    propagate_at_launch = true
  }
}
*/

resource "aws_instance" "control_plane" {
  ami = "${data.aws_ami.ubuntu.id}"

  instance_type = "t2.large"

  subnet_id = "${aws_subnet.public.0.id}"

  vpc_security_group_ids = ["${aws_security_group.ssh.id}",
    "${aws_security_group.icmp.id}",
    "${aws_security_group.outgress.id}",
    "${aws_security_group.kube.id}",
    "${aws_security_group.allow_https.id}",
  ]

  source_dest_check = false

  iam_instance_profile = "${aws_iam_instance_profile.control_plane.name}"
  key_name             = "${aws_key_pair.kube.key_name}"

  lifecycle {
    create_before_destroy = true
  }

  root_block_device {
    volume_type           = "gp2"
    volume_size           = 20
    delete_on_termination = true
  }

  /* TODO storage for etcd
    ebs_block_device {
      device_name           = "/dev/xvdb"
      volume_type           = "gp2"
      volume_size           = 20
      delete_on_termination = false
    } 
    */

  tags {
    Name = "control-plane"
  }
  associate_public_ip_address = true
  user_data = "${data.template_cloudinit_config.control_plane.rendered}"
}

data "template_file" "control_plane" {
  template = "${file("${path.root}/control_plane.tpl")}"

  vars {
    k8s_token = "${var.k8s_token}"
  }
}

data "template_cloudinit_config" "control_plane" {
  gzip          = false
  base64_encode = false

  part {
    content_type = "text/cloud-config"
    content      = "${data.template_file.control_plane.rendered}"
  }
}

output "control_plane.public_ip" {
  value = "${aws_instance.control_plane.public_ip}"
}
