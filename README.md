# AWS EKS MongoDB Infrastructure

This Terraform project automates the provisioning of a robust and scalable infrastructure on AWS. It sets up an Amazon Elastic Kubernetes Service (EKS) cluster and deploys a MongoDB database, ensuring a high-performance environment for containerized applications and data management.

## Table of Contents

1. [Introduction](#introduction)
2. [Features](#features)
3. [Prerequisites](#prerequisites)
4. [Usage](#usage)
5. [Configuration](#configuration)
6. [License](#license)
7. [Contributing](#contributing)

## Introduction

This project is designed to simplify the deployment of an EKS cluster and a MongoDB database on AWS. By using Terraform, the entire setup is automated, making it reproducible and manageable through code.

## Features

### Amazon EKS Cluster
- **EKS Cluster Creation**: Creates an EKS cluster for running Kubernetes applications.
- **Worker Nodes Configuration**: Configures worker nodes for the cluster.
- **Networking Setup**: Sets up networking, including VPC, subnets, and security groups.

### MongoDB Database
- **MongoDB Deployment**: Deploys a MongoDB instance on AWS.
- **Storage and Backups**: Configures storage and backups.
- **Security Best Practices**: Ensures security best practices, including access control and encryption.

### General Features
- **Scalability**: Easily scale the Kubernetes cluster and MongoDB instances based on workload requirements.
- **High Availability**: Leverages AWS services to ensure high availability and fault tolerance.
- **Security**: Implements security groups, IAM roles, and other security measures to protect the infrastructure.
- **Automation**: Uses Terraform to automate the entire setup, making it reproducible and manageable through code.

## Prerequisites
- **Terraform**: [Install Terraform](https://www.terraform.io/downloads.html).
- **AWS Account**: An AWS account with appropriate permissions to create resources.
- **AWS CLI**: [Install and configure AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html) with your AWS credentials.
- **MongoDB Self Signed Certificates**: [Create x.509 Certificates](https://github.com/manuelrojas19/aws-infra-k8s-mongo/blob/main/docs/certificates.md): for MongoDB.

## Usage

1. **Clone the repository**:
    ```sh
    git clone https://github.com/manuelrojas19/aws-infra-k8s-mongo
    cd aws-infra-k8s-mongo/terrafom
    ```

2. **Initialize Terraform**:
    ```sh
    terraform init
    ```

3. **Review and edit configuration variables** in `variables.tf` as needed.

4. **Apply the Terraform configuration**:
    ```sh
    terraform apply
    ```

    - Confirm the apply action by typing `yes` when prompted.

5. **Access your EKS cluster** using the AWS CLI or Kubernetes tools like `kubectl`.

## Configuration

The configuration is managed through the `variables.tf` file. Key parameters include:

- **AWS Region**: The AWS region where the resources will be deployed.
- **Cluster Name**: The name of the EKS cluster.
- **Node Instance Type**: The instance type for the worker nodes.
- **MongoDB Configuration**: Parameters for MongoDB deployment, such as instance size and backup settings.

## TODO

- CI/CD Integration
- EKS Cluster SSL/TLS Configuration
- Kafka Integration


## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Contributing

Contributions are welcome! Please submit a pull request or open an issue to discuss your ideas.
