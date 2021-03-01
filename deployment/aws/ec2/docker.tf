# Install Docker to instance
data "aws_ssm_document" "configure_docker" {
  name            = "AWS-ConfigureDocker"
  document_format = "YAML"
}

resource "aws_ssm_association" "configure_docker_association" {
  name = data.aws_ssm_document.configure_docker.name
  parameters = {
    "action" = "Install"
  }

  targets {
    key    = "InstanceIds"
    values = [aws_instance.portchain_instance.id]
  }
}

# Use docker-compose.yml file as template to terraform.
locals {
  docker-compose = base64encode(templatefile("../docker-compose.yml", 
    { PORTCHAIN_IMAGE = "${aws_ecr_repository.portchain.repository_url}:latest",
    PORTCHAIN_PORT = var.portchain_port,
    PORTCHAIN_NODE_ENV = "production",
    PORTCHAIN_NGINX_IMAGE = "${aws_ecr_repository.portchain_nginx.repository_url}:latest",  }))
}

# Create AWS Document to run on instance.
resource "aws_ssm_document" "run_containers" {
  name          = "run_containers"
  document_type = "Command"

  content = <<DOC
  {
    "schemaVersion": "2.2",
    "parameters": {

    },
    "mainSteps": [
      {
         "action": "aws:runShellScript",
         "name": "runContainers",
         "inputs": {
            "runCommand": [
               "curl -L https://github.com/docker/compose/releases/download/1.28.5/docker-compose-Linux-x86_64 -o /tmp/docker-compose",
               "chmod +x /tmp/docker-compose",
               "aws ecr get-login-password --region ${var.region} | docker login --username AWS --password-stdin $(aws sts get-caller-identity --output text --query 'Account').dkr.ecr.${var.region}.amazonaws.com",
               "echo ${local.docker-compose} | base64 -d > /tmp/docker-compose.yml",
               "/tmp/docker-compose -f /tmp/docker-compose.yml up -d"
            ]
         }
      }
    ]
  }
DOC
}

# Run containers 
resource "aws_ssm_association" "run_containers" {
  depends_on = [ "aws_ssm_association.configure_docker_association" ]
  name = aws_ssm_document.run_containers.name

  targets {
    key    = "InstanceIds"
    values = [aws_instance.portchain_instance.id]
  }
}