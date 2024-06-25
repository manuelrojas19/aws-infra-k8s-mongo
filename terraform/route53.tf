resource "aws_route53_zone" "main" {
  name = "mrr.com"
  vpc {
    vpc_id = module.vpc.vpc_id
  }
}

#####################################################
#Create DNS records for mongo instance 1
####################################################
resource "aws_route53_record" "mongodb_record_1" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "mongodb.node1.mrr.com"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.mongodb_instance_1.private_ip]
}

#####################################################
#Create DNS records for mongo instance 2
####################################################
resource "aws_route53_record" "mongodb_record_2" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "mongodb.node2.mrr.com"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.mongodb_instance_2.private_ip]
}


#####################################################
#Create DNS records for mongo instance 3
####################################################
resource "aws_route53_record" "mongodb_record_3" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "mongodb.node3.mrr.com"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.mongodb_instance_3.private_ip]
}
