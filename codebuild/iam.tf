resource "aws_iam_role" "codebuild-execution" {
  name = local.name

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "codebuild-execution" {
  name = local.name
  role = aws_iam_role.codebuild-execution.id

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Resource": [
                "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:*"
            ],
            "Action": [
                "logs:CreateLogGroup",
                "logs:DescribeLogGroups"
            ]
        },
        {
            "Effect": "Allow",
            "Resource": [
                "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/codebuild/${local.name}",
                "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:jfrog-xray-*"
            ],
            "Action": [
                "logs:DeleteLogGroup",
                "logs:ListTagsLogGroup",
                "logs:PutRetentionPolicy"
            ]
        },
        {
            "Effect": "Allow",
            "Resource": [
                "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/codebuild/${local.name}:log-stream:*"
            ],
            "Action": [
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ]
        },
        {
            "Effect": "Allow",
            "Resource": [
                "*"
            ],
            "Action": [
                "ecs:CreateCluster",
                "ecs:DeregisterTaskDefinition",
                "ecs:DescribeTaskDefinition",
                "ecs:RegisterTaskDefinition"
            ]
        },
        {
            "Effect": "Allow",
            "Resource": [
                "arn:aws:ecs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:service/jfrog-xray-*/xray",
                "arn:aws:ecs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:service/jfrog-xray-*-artifactory/artifactory"
            ],
            "Action": [
                "ecs:CreateService",
                "ecs:DeleteService",
                "ecs:DescribeServices",
                "ecs:UpdateService"
            ]
        },
                {
            "Effect": "Allow",
            "Resource": [
                "arn:aws:ecs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:cluster/jfrog-xray-*",
                "arn:aws:ecs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:cluster/jfrog-xray-*-artifactory"
            ],
            "Action": [
                "ecs:DeleteCluster",
                "ecs:DescribeClusters"
            ]
        },
        {
            "Effect": "Allow",
            "Resource": [
                "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/jfrog-xray-*-ecs-execution",
                "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/jfrog-xray-*-artifactory-ecs-execution"
            ],
            "Action": [
                "iam:CreateRole",
                "iam:DeleteRole",
                "iam:DeleteRolePolicy",
                "iam:GetRole",
                "iam:GetRolePolicy",
                "iam:ListAttachedRolePolicies",
                "iam:ListInstanceProfilesForRole",
                "iam:ListRolePolicies",
                "iam:PassRole",
                "iam:PutRolePolicy",
                "iam:TagRole"
            ]
        },
        {
            "Effect": "Allow",
            "Resource": [
                "*"
            ],
            "Action": [
                "ec2:DescribeAccountAttributes",
                "ec2:DescribeAvailabilityZones",
                "ec2:DescribeInternetGateways",
                "ec2:DescribeNetworkAcls",
                "ec2:DescribeNetworkInterfaces",
                "ec2:DescribeRouteTables",
                "ec2:DescribeSecurityGroups",
                "ec2:DescribeSubnets",
                "ec2:DescribeVpcAttribute",
                "ec2:DescribeVpcClassicLink",
                "ec2:DescribeVpcClassicLinkDnsSupport",
                "ec2:DescribeVpcs"
            ]
        },
        {
            "Effect": "Allow",
            "Resource": [
                "arn:aws:ec2:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*"
            ],
            "Action": [
                "ec2:CreateInternetGateway",
                "ec2:CreateRoute",
                "ec2:CreateRouteTable",
                "ec2:CreateSecurityGroup",
                "ec2:CreateSubnet",
                "ec2:CreateTags",
                "ec2:CreateVpc"
            ]
        },
        {
            "Effect": "Allow",
            "Resource": [
                "arn:aws:ec2:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*"
            ],
            "Action": [
                "ec2:AssociateRouteTable",
                "ec2:AttachInternetGateway",
                "ec2:AuthorizeSecurityGroupEgress",
                "ec2:AuthorizeSecurityGroupIngress",
                "ec2:DeleteInternetGateway",
                "ec2:DeleteRoute",
                "ec2:DeleteRouteTable",
                "ec2:DeleteSecurityGroup",
                "ec2:DeleteSubnet",
                "ec2:DeleteVpc",
                "ec2:DetachInternetGateway",
                "ec2:DetachNetworkInterface",
                "ec2:DisassociateRouteTable",
                "ec2:ModifySubnetAttribute",
                "ec2:ModifyVpcAttribute",
                "ec2:RevokeSecurityGroupEgress",
                "ec2:RevokeSecurityGroupIngress"
            ],
            "Condition": {
                "StringEquals": {"aws:ResourceTag/terraform_module": "terraform-aws-jfrog-xray-serverless"}
            }
        },
        {
            "Effect": "Allow",
            "Resource": [
                "*"
            ],
            "Action": [
                "elasticfilesystem:CreateFileSystem"
            ],
            "Condition": {
                "StringEquals": {"aws:RequestTag/terraform_module": "terraform-aws-jfrog-xray-serverless"}
            }
        },
        {
            "Effect": "Allow",
            "Resource": [
                "*"
            ],
            "Action": [
                "elasticfilesystem:DescribeAccessPoints",
                "elasticfilesystem:DescribeFileSystems",
                "elasticfilesystem:DescribeLifecycleConfiguration",
                "elasticfilesystem:DescribeMountTargets",
                "elasticfilesystem:DescribeMountTargetSecurityGroups"
            ]
        },
        {
            "Effect": "Allow",
            "Resource": [
                "arn:aws:elasticfilesystem:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:file-system/*"
            ],
            "Action": [
                "elasticfilesystem:CreateAccessPoint",
                "elasticfilesystem:CreateMountTarget",
                "elasticfilesystem:DeleteFileSystem",
                "elasticfilesystem:DeleteMountTarget"
            ],
            "Condition": {
                "StringEquals": {"aws:ResourceTag/terraform_module": "terraform-aws-jfrog-xray-serverless"}
            }
        },
        {
            "Effect": "Allow",
            "Resource": [
                "arn:aws:elasticfilesystem:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:access-point/*"
            ],
            "Action": [
                "elasticfilesystem:DeleteAccessPoint"
            ],
            "Condition": {
                "StringEquals": {"aws:ResourceTag/terraform_module": "terraform-aws-jfrog-xray-serverless"}
            }
        },
        {
            "Effect": "Allow",
            "Resource": [
                "*"
            ],
            "Action": [
                "elasticloadbalancing:DescribeListeners",
                "elasticloadbalancing:DescribeLoadBalancerAttributes",
                "elasticloadbalancing:DescribeLoadBalancers",
                "elasticloadbalancing:DescribeTags",
                "elasticloadbalancing:DescribeTargetGroupAttributes",
                "elasticloadbalancing:DescribeTargetGroups"
            ]
        },
        {
            "Effect": "Allow",
            "Resource": [
                "arn:aws:elasticloadbalancing:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:listener/app/jfrog-xray-*-artifactory/*/*",
                "arn:aws:elasticloadbalancing:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:loadbalancer/app/jfrog-xray-*-artifactory/*",
                "arn:aws:elasticloadbalancing:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:targetgroup/jfrog-xray-*-artifactory/*"
            ],
            "Action": [
                "elasticloadbalancing:AddTags"
            ]
        },
        {
            "Effect": "Allow",
            "Resource": [
                "arn:aws:elasticloadbalancing:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:loadbalancer/app/jfrog-xray-*-artifactory/*"
            ],
            "Action": [
                "elasticloadbalancing:CreateListener",
                "elasticloadbalancing:CreateLoadBalancer",
                "elasticloadbalancing:DeleteLoadBalancer",
                "elasticloadbalancing:ModifyLoadBalancerAttributes",
                "elasticloadbalancing:SetSecurityGroups"
            ]
        },
        {
            "Effect": "Allow",
            "Resource": [
                "arn:aws:elasticloadbalancing:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:targetgroup/jfrog-xray-*-artifactory/*"
            ],
            "Action": [
                "elasticloadbalancing:CreateTargetGroup",
                "elasticloadbalancing:DeleteTargetGroup",
                "elasticloadbalancing:ModifyTargetGroupAttributes"
            ]
        },
        {
            "Effect": "Allow",
            "Resource": [
                "arn:aws:elasticloadbalancing:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:listener/app/jfrog-xray-*-artifactory/*/*"
            ],
            "Action": [
                "elasticloadbalancing:DeleteListener"
            ]
        },
        {
            "Effect": "Allow",
            "Resource": [
                "*"
            ],
            "Action": [
                "rds:DescribeDBInstances",
                "rds:DescribeDBSubnetGroups",
                "rds:ListTagsForResource"
            ]
        },
        {
            "Effect": "Allow",
            "Resource": [
                "arn:aws:rds:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*"
            ],
            "Action": [
                "rds:AddTagsToResource",
                "rds:CreateDBInstance"
            ],
            "Condition": {
                "StringEquals": {"aws:RequestTag/terraform_module": "terraform-aws-jfrog-xray-serverless"}
            }
        },
        {
            "Effect": "Allow",
            "Resource": [
                "arn:aws:rds:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:subgrp:jfrog-xray-*"
            ],
            "Action": [
                "rds:CreateDBSubnetGroup",
                "rds:DeleteDBSubnetGroup"
            ]
        },
        {
            "Effect": "Allow",
            "Resource": [
                "arn:aws:rds:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:db:jfrog-xray-*"
            ],
            "Action": [
                "rds:DeleteDBInstance"
            ]
        },
        {
            "Effect": "Allow",
            "Resource": [
                "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/jfrog-xray-*/*"
            ],
            "Action": [
                "ssm:AddTagsToResource",
                "ssm:DeleteParameter",
                "ssm:DescribeParameter",
                "ssm:GetParameter",
                "ssm:GetParameters",
                "ssm:ListTagsForResource",
                "ssm:PutParameter"
            ]
        },
        {
            "Effect": "Allow",
            "Resource": [
                "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*"
            ],
            "Action": [
                "ssm:DescribeParameters"
            ]
        }
    ]
}
EOF
}
