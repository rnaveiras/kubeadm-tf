resource "aws_key_pair" "kube" {
  key_name   = "kube"
  public_key = "${file("~/.ssh/${var.key_name}.pub")}"
}
