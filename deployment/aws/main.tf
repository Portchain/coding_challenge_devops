module "instance" {
  source = "./ec2"
  
  region = var.region
}