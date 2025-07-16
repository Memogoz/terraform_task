variable "source_ami" {
    type = string
    default = "ami-09ac0b140f63d3458"
}

variable "builder_instance_type" {
    type = string
    default = "t3.small"
}

variable "subnet_id" {
    type = string
}

variable "user_data" {
    type = string
}

variable "prefix" {
    type = string
    default = "ggonz-task"
}