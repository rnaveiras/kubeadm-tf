// http://cloud-images.ubuntu.com/locator/ec2/
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "image-type"
    values = ["machine"]
  }

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
  }

  owners = ["099720109477"] # Canonical
}

output "ami" {
  value = "${data.aws_ami.ubuntu.id}"
}

/*
output "image_name" {
  value = "${data.aws_ami.ubuntu.name}"
}

output "image_creation_date" {
  value = "${data.aws_ami.ubuntu.creation_date}"
}
*/
