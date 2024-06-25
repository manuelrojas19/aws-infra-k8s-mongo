#####################################################
#Create Bastion instance 
####################################################
resource "aws_instance" "bastion_instance" {
  ami                    = var.ami
  instance_type          = var.bastion_instance_type
  key_name               = aws_key_pair.mongo_qa_key_pair.key_name
  subnet_id              = module.vpc.public_subnets[0]
  vpc_security_group_ids = [aws_security_group.bastion.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name

  tags = {
    Name = "${var.project_name}-${var.environment}-bastion-instance"
  }
}

#####################################################
#Create mongo instance 1
####################################################
resource "aws_instance" "mongodb_instance_1" {
  ami           = var.ami
  instance_type = var.mongo_instance_type
  user_data = base64encode(templatefile("./scripts/build_mongodb.sh",
    {
      MONGO_USER     = var.mongo_user
      MONGO_PASSWORD = var.mongo_password
      REGION         = var.region
      CERT_S3_BUCKET = var.cert_s3_bucket
    }
  ))
  key_name               = aws_key_pair.mongo_qa_key_pair.key_name
  subnet_id              = module.vpc.private_subnets[0]
  vpc_security_group_ids = [aws_security_group.mongodb.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name

  tags = {
    Name = "${var.project_name}-${var.environment}-mongodb-node-1"
  }
}

#####################################################
#Create mongo instance 2
####################################################
resource "aws_instance" "mongodb_instance_2" {
  ami           = var.ami
  instance_type = var.mongo_instance_type
  user_data = base64encode(templatefile("./scripts/build_mongodb.sh",
    {
      MONGO_USER     = var.mongo_user
      MONGO_PASSWORD = var.mongo_password
      REGION         = var.region
      CERT_S3_BUCKET = var.cert_s3_bucket
    }
  ))
  key_name               = aws_key_pair.mongo_qa_key_pair.key_name
  subnet_id              = module.vpc.private_subnets[1]
  vpc_security_group_ids = [aws_security_group.mongodb.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name

  tags = {
    Name = "${var.project_name}-${var.environment}-mongodb-node-2"
  }
}

#####################################################
#Create mongo instance 3
####################################################
resource "aws_instance" "mongodb_instance_3" {
  ami           = var.ami
  instance_type = var.mongo_instance_type
  user_data = base64encode(templatefile("../scripts/build_mongodb.sh",
    {
      MONGO_USER     = var.mongo_user
      MONGO_PASSWORD = var.mongo_password
      REGION         = var.region
      CERT_S3_BUCKET = var.cert_s3_bucket
    }
  ))
  key_name               = aws_key_pair.mongo_qa_key_pair.key_name
  subnet_id              = module.vpc.private_subnets[2]
  vpc_security_group_ids = [aws_security_group.mongodb.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name

  tags = {
    Name = "${var.project_name}-${var.environment}-mongodb-node-3"
  }
}
