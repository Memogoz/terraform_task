output "web_ami_id" {
  description = "The ID of the AMI created from the builder instance"
  value       = aws_ami_from_instance.web_ami.id
}