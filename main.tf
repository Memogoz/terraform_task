terraform {
  required_version = ">= 1.2"
  backend "s3" {
    bucket       = "my-terraform-state-bucket-05830000"
    key          = "infrastructure/terraform.tfstate"
    region       = "us-east-1"
    use_lockfile = true
    encrypt      = true
  }
}

module "network" {
  source        = "./modules/network"
  prefix        = "ggonz-task"
  vpc_cidr      = "10.0.0.0/16"
  az_a          = "us-east-1a"
  az_b          = "us-east-1b"
  allowed_cidrs = ["201.163.120.0/24"]
}

module "image_builder" {
  source                = "./modules/image-builder"
  prefix                = "ggonz-task"
  source_ami            = data.aws_ami.ubuntu.id
  builder_instance_type = "t3.small"
  subnet_id             = module.network.public_subnet_ids[0]
  builder_sg_ids        = [module.network.builder_sg_id]
  user_data             = file("setup-script.sh")
}

module "alb" {
  source     = "./modules/alb"
  prefix     = "ggonz-task"
  subnet_ids = module.network.public_subnet_ids
  vpc_id     = module.network.vpc_id
  alb_sg_ids = [module.network.alb_sg_id]
}

module "compute" {
  source                = "./modules/compute"
  prefix                = "ggonz-task"
  web_ami_id            = module.image_builder.web_ami_id
  instance_type         = "t3.small"
  subnet_ids            = module.network.public_subnet_ids
  alb_target_group_arns = [module.alb.alb_target_group_arn]
  desired_count         = 3
  user_data             = file("website-script.sh")
  web_sg_ids            = [module.network.web_sg_id]

  depends_on = [module.image_builder]
}
