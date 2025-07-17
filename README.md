# Terraform AWS Web Infrastructure

This project uses Terraform to provision a scalable and resilient web application infrastructure on AWS. It includes a custom VPC, an EC2 Image Builder pipeline to create a golden AMI, an Application Load Balancer for traffic distribution, and an Auto Scaling Group to manage EC2 instances.

The state of the infrastructure is managed remotely and securely using an S3 bucket backend.

## Table of Contents

- [Architecture](#architecture)
- [Prerequisites](#prerequisites)
- [Setup](#setup)
- [Usage](#usage)
  - [Deploying the Infrastructure](#deploying-the-infrastructure)
  - [Destroying the Infrastructure](#destroying-the-infrastructure)
- [Modules](#modules)
- [Outputs](#outputs)

## Architecture

The infrastructure created by this project consists of the following components:

1.  **VPC**: A custom Virtual Private Cloud (VPC) with a `10.0.0.0/16` CIDR block provides a logically isolated network environment.
2.  **Subnets**: Two public subnets are created across different Availability Zones (`us-east-1a`, `us-east-1b`) for high availability.
3.  **EC2 Image Builder**: An Image Builder pipeline is defined to:
    - Start with a base Ubuntu 22.04 AMI.
    - Run a provisioning script (`setup-script.sh`) to install software (e.g., a web server) and configure the image.
    - Produce a custom "golden" AMI.
4.  **Application Load Balancer (ALB)**: An internet-facing ALB is deployed in the public subnets. It listens for HTTP traffic on port 80 and distributes it to the instances in the Auto Scaling Group.
5.  **Auto Scaling Group (ASG)**: The ASG manages the lifecycle of EC2 instances. It is configured to:
    - Launch `t3.small` instances using the custom AMI created by Image Builder.
    - Maintain a desired capacity of 3 instances across the public subnets.
    - Run a `user_data` script (`website-script.sh`) on instance launch for final configurations.
    - Automatically register new instances with the ALB's target group.
6.  **Security Groups**:
    - An ALB Security Group that allows inbound HTTP traffic from anywhere (`0.0.0.0/0`).
    - A Web Server Security Group that allows inbound traffic from the ALB, ensuring instances are not directly exposed to the internet.
7.  **S3 Backend**: Terraform state is stored in a designated S3 bucket, enabling collaboration and state locking.

## Prerequisites

Before you begin, ensure you have the following installed and configured:

- **Terraform**: Version `1.2` or newer.
- **AWS CLI**: Installed and configured with your AWS credentials.
- **AWS Account**: An active AWS account with permissions to create the resources defined in this project.

## Setup

1.  **Clone the Repository**

    ```sh
    git clone <your-repository-url>
    cd <repository-directory>
    ```

2.  **Configure the S3 Backend**

    This project is configured to use an S3 bucket for remote state management. You must create this bucket manually before running Terraform.

    - Create a unique S3 bucket in the `us-east-1` region.
    - Open the `main.tf` file and update the `backend` configuration with your bucket name:

      ```terraform
      # /Users/ggonzalez/Documents/DevOps Internship/19. Infrastructure management with Terraform/Practical Task/main.tf

      terraform {
        # ...
        backend "s3" {
          bucket       = "your-unique-bucket-name-here" # <-- CHANGE THIS
          key          = "infrastructure/terraform.tfstate"
          region       = "us-east-1"
          use_lockfile = true
          encrypt      = true
        }
      }
      ```

## Usage

### Deploying the Infrastructure

1.  **Initialize Terraform**
    This command downloads the necessary provider plugins and initializes the backend.

    ```sh
    terraform init
    ```

2.  **Plan the Deployment**
    (Optional) This command shows you what resources Terraform will create, modify, or destroy.

    ```sh
    terraform plan
    ```

3.  **Apply the Configuration**
    This command builds and deploys the resources on AWS. You will be prompted to confirm the action.

    ```sh
    terraform apply
    ```
    Enter `yes` when prompted. The deployment may take several minutes, as the EC2 Image Builder pipeline needs time to create the custom AMI.

### Destroying the Infrastructure

To tear down all the resources created by this project, run the following command. You will be prompted for confirmation.

```sh
terraform destroy
```

## Modules

This project is organized into several reusable Terraform modules:

- `network`: Manages all networking resources, including the VPC, subnets, internet gateway, route tables, and security groups.
- `image-builder`: Defines the EC2 Image Builder components and pipeline to create the custom AMI.
- `alb`: Sets up the Application Load Balancer, its target group, and listener.
- `compute`: Manages the Auto Scaling Group and Launch Template for the web server instances.

## Outputs

After a successful `terraform apply`, the following output will be displayed:

- **`url`**: The public DNS name of the Application Load Balter. You can paste this URL into your browser to access the deployed web application.

