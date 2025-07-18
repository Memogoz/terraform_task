# modules/image-builder/main.tf
resource "aws_instance" "builder" {
  ami             = var.source_ami
  instance_type   = var.builder_instance_type
  subnet_id       = var.subnet_id
  security_groups = var.builder_sg_ids
  user_data       = var.user_data
  tags            = { Name = "${var.prefix}-builder" }
}

resource "aws_ami_from_instance" "web_ami" {
  name               = "${var.prefix}-simple-website-ami"
  source_instance_id = aws_instance.builder.id
  depends_on         = [aws_instance.builder]
}
