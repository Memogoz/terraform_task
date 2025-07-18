output "vpc_id" {
  value = aws_vpc.this.id
}

output "public_subnet_ids" {
  value = [aws_subnet.public_a.id, aws_subnet.public_b.id]
}

output "alb_sg_id" {
  value = aws_security_group.alb_sg.id
}

output "builder_sg_id" {
  value = aws_security_group.builder_sg.id
}

output "web_sg_id" {
  value = aws_security_group.web_sg.id
}