Requirements:
  - Terraform v0.14.3
  - aws-cli/2.0.46
  - docker-compose-1.28.5
  - image: nginx:1.19.7-alpine
  - image: node:14.16.0-alpine3.10

You can use the `deployment/manage.sh` script to create AWS resources, docker images etc. Below the parameters it accepts.
```bash
	 prepare-docker: Builds docker images and pushes to created private ECR repositories.
	 deploy_containers: Creates AWS infrastructure and runs containers.
	 update-containers: Rebuilds images and updates running containers on server.
	 local-build: Build images for local-run.
	 local-run: You can run containers for test. Docker-compose should be installed. 
```

We create VPC, subnet, IGW for network seperation and 2 AWS ECR repositories and 1 EC2 instance.
EC2 instance has read image pull access from ECR.
EC2 instance only allows 80 and 443 ports from public access. 
We use AWS SSM Service to connect or login to the instance one should use `aws ssm start-session --target INSTANCE_ID`. This gives us more control and security.
We create a special SystemsManager's RunCommand Document to run containers via docker-compose.
Additionally, you can also use the docker-compose.yml file to run/test on your local machine.