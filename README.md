# AWS EKS MongoDB Infrastructure

This Terraform project automates the provisioning of a robust and scalable infrastructure on AWS. It sets up an Amazon Elastic Kubernetes Service (EKS) cluster and deploys a MongoDB database, ensuring a high-performance environment for containerized applications and data management.

## Table of Contents

- [Introduction](#introduction)
- [Features](#features)
- [Prerequisites](#prerequisites)
- [Usage](#usage)
- [Configuration](#configuration)
- [License](#license)
- [Contributing](#contributing)

## Introduction

This project is designed to simplify the deployment of an EKS cluster and a MongoDB database on AWS. By using Terraform, the entire setup is automated, making it reproducible and manageable through code.

## Features

- **Amazon EKS Cluster**:
  - Creates an EKS cluster for running Kubernetes applications.
  - Configures worker nodes for the cluster.
  - Sets up networking, including VPC, subnets, and security groups.

- **MongoDB Database**:
  - Deploys a MongoDB instance on AWS.
  - Configures storage and backups.
  - Ensures security best practices, including access control and encryption.

- **Scalability**: Easily scale the Kubernetes cluster and MongoDB instances based on workload requirements.
- **High Availability**: Leverages AWS services to ensure high availability and fault tolerance.
- **Security**: Implements security groups, IAM roles, and other security measures to protect the infrastructure.
- **Automation**: Uses Terraform to automate the entire setup, making it reproducible and manageable through code.

## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) installed.
- AWS account with appropriate permissions to create resources.
- AWS CLI configured with your AWS credentials.
