locals {
  cluster_name = "mrr-eks-cluster-${random_string.suffix.result}-dev"
}

resource "random_string" "suffix" {
  length  = 8
  special = false
  lower   = true
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.15.3"

  cluster_name    = local.cluster_name
  cluster_version = "1.29"

  vpc_id                         = module.vpc.vpc_id
  subnet_ids                     = module.vpc.private_subnets
  cluster_endpoint_public_access = true
  cluster_endpoint_private_access = true


  eks_managed_node_group_defaults = {
    ami_type = "AL2_x86_64"
  }

  eks_managed_node_groups = {
    one = {
      name = "node-group-1"

      instance_types = ["t3.small"]

      min_size     = 1
      max_size     = 3
      desired_size = 2
    }

    two = {
      name = "node-group-2"

      instance_types = ["t3.small"]

      min_size     = 1
      max_size     = 3
      desired_size = 1
    }
  }
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
      command     = "aws"
    }
  }
}

resource "helm_release" "ingress" {
  name       = "ingress"
  chart      = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  version    = "1.4.6"

  set {
    name  = "autoDiscoverAwsRegion"
    value = "true"
  }
  
  set {
    name  = "autoDiscoverAwsVpcID"
    value = "true"
  }

  set {
    name  = "clusterName"
    value = module.eks.cluster_name
  }
}

# resource "helm_release" "nginx_ingress" {
#   name       = "nginx-ingress"
#   repository = "https://helm.nginx.com/stable"
#   chart      = "nginx-ingress"
#   version    = "1.14.2"
  
#   set {
#     name  = "controller.service.enabled"
#     value = "true"
#   }

#   set {
#     name  = "controller.service.type"
#     value = "LoadBalancer"
#   }

#   set {
#     name  = "controller.ingressClass"
#     value = "nginx"
#   }

#   set {
#     name  = "controller.publishService.enabled"
#     value = "true"
#   }

#   # Add more configuration values as needed
# }
