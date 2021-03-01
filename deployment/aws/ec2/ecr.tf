resource "aws_ecr_repository" "portchain" {
  name = "portchain"
}

resource "aws_ecr_repository" "portchain_nginx" {
  name = "portchain_nginx"
}