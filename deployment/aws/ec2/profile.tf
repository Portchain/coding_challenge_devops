resource "aws_iam_instance_profile" "portchain_instance_profile" {
  name = "portchain_instance_profile"
  role = aws_iam_role.portchain_role.name
}

resource "aws_iam_role" "portchain_role" {
  name = "portchain_role"
  path = "/"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}

# Permission to manage instance with AWS SSM
resource "aws_iam_role_policy_attachment" "ec2-attach" {
  role       = aws_iam_role.portchain_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# ECR Access policy to pull images from private repositories
resource "aws_iam_role_policy" "ecr-access" {
  name = "ecr-access"
  role = aws_iam_role.portchain_role.id

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ecr:BatchCheckLayerAvailability",
                "ecr:BatchGetImage",
                "ecr:GetDownloadUrlForLayer",
                "ecr:GetAuthorizationToken"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}