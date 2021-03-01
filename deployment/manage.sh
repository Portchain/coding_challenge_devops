#!/usr/bin/env bash

REGION=${2:-us-east-1}

prepare_docker_repositories() {
    ACC_ID=$(aws sts get-caller-identity --output text --query 'Account')
    aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $ACC_ID.dkr.ecr.$REGION.amazonaws.com

    pushd ./aws
        echo -e "Creating AWS ECR Repositories \n"
        terraform init
        terraform apply -auto-approve -target=module.instance.aws_ecr_repository.portchain
        terraform apply -auto-approve -target=module.instance.aws_ecr_repository.portchain_nginx
    popd

    version=$(git rev-parse --short HEAD)
    # PORTCHAIN IMAGE
    echo -e "Building and pushing portchain image \n"
    docker build -f ./images/portchain.dockerfile -t portchain:$version ../
    docker tag portchain:$version $ACC_ID.dkr.ecr.$REGION.amazonaws.com/portchain:$version
    docker push $ACC_ID.dkr.ecr.$REGION.amazonaws.com/portchain:$version
    docker tag portchain:$version $ACC_ID.dkr.ecr.$REGION.amazonaws.com/portchain:latest
    docker push $ACC_ID.dkr.ecr.$REGION.amazonaws.com/portchain:latest

    # PORTCHAIN NGINX IMAGE
    echo -e "Building and pushing portchain_nginx image \n"
    docker build -f ./images/nginx.dockerfile -t portchain_nginx:$version ./images
    docker tag portchain_nginx:$version $ACC_ID.dkr.ecr.$REGION.amazonaws.com/portchain_nginx:$version
    docker push $ACC_ID.dkr.ecr.$REGION.amazonaws.com/portchain_nginx:$version
    docker tag portchain_nginx:$version $ACC_ID.dkr.ecr.$REGION.amazonaws.com/portchain_nginx:latest
    docker push $ACC_ID.dkr.ecr.$REGION.amazonaws.com/portchain_nginx:latest
}

update_containers_on_server() {
    pushd ./aws
        terraform taint module.instance.aws_ssm_association.run_containers
        terraform plan -out=terraform.plan
        terraform apply "terraform.plan"
    popd
}

deploy_containers() {
    pushd ./aws
        terraform init
        terraform plan -out=terraform.plan
        terraform apply "terraform.plan"
    popd
    sleep 10
    update_containers_on_server
}

case $1 in

  prepare-docker)
    prepare_docker_repositories
    ;;

  deploy-containers)
    deploy_containers
    ;;

  update-containers)
    prepare_docker_repositories
    update_containers_on_server
    ;;

  local-build)
    docker build -f ./images/portchain.dockerfile -t portchain:latest ../
    docker build -f ./images/nginx.dockerfile -t portchain_nginx:latest ./images
    ;;

  local-run)
    docker-compose up -d
    ;;

  *)
    echo -e "Please give one of following. \n"
    echo -e "\t prepare-docker: Builds docker images and pushes to created private ECR repositories."
    echo -e "\t deploy_containers: Creates AWS infrastructure and runs containers."
    echo -e "\t update-containers: Rebuilds images and updates running containers on server."
    echo -e "\t local-build: Build images for local-run."
    echo -e "\t local-run: You can run containers for test. Docker-compose should be installed. \n"
    echo -e "-- NOTE: Additionally you can give region as 2nd argument."
    exit 1
    ;;
esac
