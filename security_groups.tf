resource "aws_security_group" "ssh" {
  name        = "ssh"
  description = "Allow only ssh"
  vpc_id      = "${aws_vpc.platform.id}"

  // allow traffic for TCP 22
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "ssh"
  }
}

resource "aws_security_group" "icmp" {
  name        = "icmp"
  description = "Allow ping bettween instances"
  vpc_id      = "${aws_vpc.platform.id}"

  ingress {
    from_port       = -1
    to_port         = -1
    protocol        = "icmp"
    security_groups = []
    self            = true
  }

  egress {
    from_port       = -1
    to_port         = -1
    protocol        = "icmp"
    security_groups = []
    self            = true
  }

  tags {
    Name = "icmp"
  }
}

resource "aws_security_group" "outgress" {
  name        = "outgress"
  description = "outgress Traffic"
  vpc_id      = "${aws_vpc.platform.id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "outgres"
  }
}

resource "aws_security_group" "kube" {
  name        = "kube"
  description = "give access to everything for now"
  vpc_id      = "${aws_vpc.platform.id}"

  ingress {
    from_port = 0
    to_port   = 65535
    protocol  = "tcp"
    self      = true
  }

  ingress {
    from_port = 0
    to_port   = 65535
    protocol  = "udp"
    self      = true
  }

  tags {
    Name = "kube"
  }
}

resource "aws_security_group" "allow_https" {
  name        = "allow-https"
  description = "give access to 443 port"
  vpc_id      = "${aws_vpc.platform.id}"

  ingress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "allow-https"
  }
}
