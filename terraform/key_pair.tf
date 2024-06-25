resource "aws_key_pair" "mongo_qa_key_pair" {
  key_name   = "mongo_key_pair"  # Specify a unique name for your key pair
  public_key = file("../ssh/mongo_key_pair.pub")  # Path to your public key file
}