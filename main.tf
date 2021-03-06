terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.0.0"
    }
  }
}

provider "aws" {
  region = var.region
}

data "aws_s3_bucket" "remote-state" {
  bucket = "tr-state-maxno1988"
}


resource "aws_iam_user" "new_user" {
  name = "Alice"
}

resource "aws_iam_user_policy_attachment" "Attach-Test" {
  user       = aws_iam_user.new_user.name
  policy_arn = aws_iam_policy.policy.arn
}

resource "aws_iam_group_membership" "Consultants" {
  name  = "IAMGroup"
  users = [aws_iam_user.new_user.name]
  group = "Consultants"
}


resource "aws_iam_policy" "policy" {
  name        = "NewUser_Test_Policy"
  description = "My test policy"

  policy = <<EOT
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:ListAllMyBuckets"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOT
}

resource "aws_s3_bucket_policy" "mypolicy" {
  bucket = data.aws_s3_bucket.remote-state.id

  policy = <<POLICY1
{
    "Version": "2012-10-17",
    "Id": "Policy1653577756734",
    "Statement": [
        {
            "Sid": "Stmt1653577726786",
            "Effect": "Allow",
            "Principal": {
                "AWS": "${aws_iam_user.new_user.arn}"
            },
            "Action": "s3:ListBucket",
            "Resource": "${data.aws_s3_bucket.remote-state.arn}" 
        },
        {
            "Sid": "Stmt1653577755475",
            "Effect": "Allow",
            "Principal": {
                "AWS": "${aws_iam_user.new_user.arn}"
            },
            "Action": "s3:GetObject",
            "Resource": "${data.aws_s3_bucket.remote-state.arn}/*"
        }
    ]
}
POLICY1
}
