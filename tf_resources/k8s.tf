
# task_3

resource "aws_iam_role" "kops" {
  name = "kops_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ec2_full_access_kops" {
  role       = aws_iam_role.kops.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

resource "aws_iam_role_policy_attachment" "route53_full_access_kops" {
  role       = aws_iam_role.kops.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonRoute53FullAccess"
}

resource "aws_iam_role_policy_attachment" "s3_full_access_kops" {
  role       = aws_iam_role.kops.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_role_policy_attachment" "iam_full_access_kops" {
  role       = aws_iam_role.kops.name
  policy_arn = "arn:aws:iam::aws:policy/IAMFullAccess"
}

resource "aws_iam_role_policy_attachment" "vpc_full_access_kops" {
  role       = aws_iam_role.kops.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonVPCFullAccess"
}

resource "aws_iam_role_policy_attachment" "sqs_full_access_kops" {
  role       = aws_iam_role.kops.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSQSFullAccess"
}

resource "aws_iam_role_policy_attachment" "eventbridge_full_access_kops" {
  role       = aws_iam_role.kops.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEventBridgeFullAccess"
}

resource "aws_iam_instance_profile" "kops_instance_profile" {
  name = "kops_instance_profile"
  role = aws_iam_role.kops.name
}

resource "aws_s3_bucket" "kops" {
  bucket = var.bucket_name_kops
}

resource "aws_s3_bucket_server_side_encryption_configuration" "kops" {
  bucket = aws_s3_bucket.kops.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "kops" {
  bucket                  = aws_s3_bucket.kops.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Deploy of kOps infrastructure requires NAT enabling in network.tf file

# resource "aws_instance" "kops_instance" {
#   ami                         = data.aws_ami.al2023-ami.id
#   subnet_id                   = aws_subnet.private["private_a"].id
#   vpc_security_group_ids      = [aws_security_group.common.id]
#   key_name                    = aws_key_pair.kp.key_name
#   instance_type               = var.instance_type
#   iam_instance_profile        = aws_iam_instance_profile.kops_instance_profile.name

#   user_data_replace_on_change = true
#   user_data = templatefile("${path.module}/userdata_k8s.sh", {
#     bucket = var.bucket_name_kops
#     name   = "kops.k8s.local"
#   })
#   depends_on = [aws_route_table_association.private]

#   tags = {
#     Name = "kops-instance"
#   }
# }

# resource "aws_instance" "bastion" {
#   ami                    = data.aws_ami.al2023-ami.id
#   instance_type          = var.instance_type
#   subnet_id              = aws_subnet.public["public_a"].id
#   vpc_security_group_ids = [aws_security_group.bastion.id]
#   key_name               = aws_key_pair.kp.key_name
#   tags = {
#     Name = "bastion-instance"
#   }
# }

# output "bastion_public_ip" {
#   value = aws_instance.bastion.public_ip
# }