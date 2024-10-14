# Terraform AWS VPC and EC2 Setup

This repository contains Terraform code to provision a basic AWS infrastructure, including a Virtual Private Cloud (VPC), subnets, an Internet Gateway, a security group, an EC2 instance with a web server, an Application Load Balancer (ALB), and an Auto Scaling Group (ASG). This setup is designed to help you get started with AWS infrastructure management using Terraform.

## Prerequisites

Before you begin, ensure you have the following:

- [Terraform](https://www.terraform.io/downloads.html) installed.
- An AWS account with sufficient permissions to create VPCs, EC2 instances, security groups, and load balancers.
- AWS credentials configured on your local machine (using `aws configure` or environment variables).

## Features

- Creates a VPC with CIDR block `10.0.0.0/16`.
- Sets up public and private subnets across two availability zones.
- Configures an Internet Gateway for internet access.
- Deploys an EC2 instance running a web server (Apache).
- Implements a security group to allow HTTP and SSH traffic.
- Sets up an Application Load Balancer to distribute traffic.
- Creates an Auto Scaling Group to manage the EC2 instances dynamically.

## Terraform Code Overview

The main resources defined in this configuration include:

- **VPC**: A Virtual Private Cloud (VPC) with the specified CIDR block.
- **Subnets**: Public and private subnets to segregate resources.
- **Internet Gateway**: Enables internet access for the VPC.
- **Security Groups**: Controls inbound and outbound traffic.
- **EC2 Instance**: An Amazon EC2 instance running a web server, with user data to install and configure Apache.
- **Application Load Balancer**: Distributes incoming application traffic.
- **Auto Scaling Group**: Automatically adjusts the number of EC2 instances based on demand.

## Usage

1. Clone this repository:

   ```bash
   git clone https://github.com/yourusername/repo-name.git
   cd repo-name

