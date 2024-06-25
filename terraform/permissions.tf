data "aws_iam_policy" "ebs_csi_policy" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

module "irsa-ebs-csi" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "4.7.0"

  create_role                   = true
  role_name                     = "AmazonEKSTFEBSCSIRole-${module.eks.cluster_name}"
  provider_url                  = module.eks.oidc_provider
  role_policy_arns              = [data.aws_iam_policy.ebs_csi_policy.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:kube-system:ebs-csi-controller-sa"]
}

resource "aws_eks_addon" "ebs-csi" {
  cluster_name             = module.eks.cluster_name
  addon_name               = "aws-ebs-csi-driver"
  addon_version            = "v1.20.0-eksbuild.1"
  service_account_role_arn = module.irsa-ebs-csi.iam_role_arn
  tags = {
    "eks_addon" = "ebs-csi"
    "terraform" = "true"
  }
}

data "aws_iam_policy_document" "ec2_instance_assume_role_policy"{
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com",]
    }
  }

}

data "aws_iam_policy_document" "iam_policy_ec2_instance_document"{
  statement {
    effect = "Allow"
    actions = ["ec2:DescribeInstances",
               "ec2:DescribeTags",
               "S3:*"]
    resources = ["*"]
  }

}

resource "aws_iam_role" "ec2_instance_role" {
  name               = "ec2_instance_role"
  assume_role_policy = data.aws_iam_policy_document.ec2_instance_assume_role_policy.json
  inline_policy {
    name   = "policy-8675308"
    policy = data.aws_iam_policy_document.iam_policy_ec2_instance_document.json
  }
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2_profile"
  role = aws_iam_role.ec2_instance_role.name
}

resource "aws_iam_policy" "kube_worker_policy" {
  name        = "kube-worker-policy"
  description = "Worker policy for the ALB Ingress"

  policy = file("../policies/iam_policy.json")
}

resource "aws_iam_policy" "alb_tag_policy" {
  name        = "alb-tag-policy"
  description = "Worker policy for the ALB Ingress"

  policy = file("../policies/tags_policy.json")
}

resource "aws_iam_role_policy_attachment" "worker" {
  for_each = module.eks.eks_managed_node_groups

  policy_arn = aws_iam_policy.kube_worker_policy.arn
  role       = each.value.iam_role_name
}

resource "aws_iam_role_policy_attachment" "tag" {
  for_each = module.eks.eks_managed_node_groups

  policy_arn = aws_iam_policy.alb_tag_policy.arn
  role       = each.value.iam_role_name
}