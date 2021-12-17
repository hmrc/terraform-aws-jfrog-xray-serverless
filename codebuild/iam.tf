resource "aws_iam_role" "codebuild-xray-test-execution" {
  name = "test-role"

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

resource "aws_iam_role_policy" "codebuild-xray-test-execution" {
  name = "jfrog-xray-codebuild-xray-test-execution"
  role = aws_iam_role.codebuild-xray-test-execution.id

# TODO - tighten up policy statements
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Resource": [
                "arn:aws:logs:eu-west-2:${data.aws_caller_identity.current.account_id}:log-group:/aws/codebuild/jfrog-xray-test-pipeline",
                "arn:aws:logs:eu-west-2:${data.aws_caller_identity.current.account_id}:log-group:jfrog-xray-*"
            ],
            "Action": [
                "logs:CreateLogGroup",
                "logs:DeleteLogGroup",
                "logs:ListTagsLogGroup",
                "logs:PutRetentionPolicy"
            ]
        },
        {
            "Effect": "Allow",
            "Resource": [
                "arn:aws:logs:eu-west-2:${data.aws_caller_identity.current.account_id}:log-group:/aws/codebuild/jfrog-xray-test-pipeline:log-stream:*"
            ],
            "Action": [
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ]
        },
                {
            "Effect": "Allow",
            "Resource": [
                "arn:aws:logs:eu-west-2:${data.aws_caller_identity.current.account_id}:log-group:*"
            ],
            "Action": [
                "logs:DescribeLogGroups"
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
                "arn:aws:ecs:eu-west-2:${data.aws_caller_identity.current.account_id}:service/jfrog-xray-*/xray",
                "arn:aws:ecs:eu-west-2:${data.aws_caller_identity.current.account_id}:service/jfrog-xray-*-artifactory/artifactory"
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
                "arn:aws:ecs:eu-west-2:${data.aws_caller_identity.current.account_id}:cluster/jfrog-xray-*",
                "arn:aws:ecs:eu-west-2:${data.aws_caller_identity.current.account_id}:cluster/jfrog-xray-*-artifactory"
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
                "iam:PutRolePolicy"
            ]
        },
        {
            "Effect": "Allow",
            "Resource": [
                "*"
            ],
            "Action": [
                "ec2:AssociateRouteTable",
                "ec2:AttachInternetGateway",
                "ec2:AuthorizeSecurityGroupEgress",
                "ec2:AuthorizeSecurityGroupIngress",
                "ec2:CreateInternetGateway",
                "ec2:CreateRoute",
                "ec2:CreateRouteTable",
                "ec2:CreateSecurityGroup",
                "ec2:CreateSubnet",
                "ec2:CreateTags",
                "ec2:CreateVpc",
                "ec2:DeleteInternetGateway",
                "ec2:DeleteRoute",
                "ec2:DeleteRouteTable",
                "ec2:DeleteSecurityGroup",
                "ec2:DeleteSubnet",
                "ec2:DeleteVpc",
                "ec2:DescribeAccountAttributes",
                "ec2:DescribeInternetGateways",
                "ec2:DescribeNetworkAcls",
                "ec2:DescribeNetworkInterfaces",
                "ec2:DescribeRouteTables",
                "ec2:DescribeSecurityGroups",
                "ec2:DescribeSubnets",
                "ec2:DescribeVpcAttribute",
                "ec2:DescribeVpcClassicLink",
                "ec2:DescribeVpcClassicLinkDnsSupport",
                "ec2:DescribeVpcs",
                "ec2:DetachInternetGateway",
                "ec2:DetachNetworkInterface",
                "ec2:DisassociateRouteTable",
                "ec2:ModifySubnetAttribute",
                "ec2:ModifyVpcAttribute",
                "ec2:RevokeSecurityGroupEgress",
                "ec2:RevokeSecurityGroupIngress"
            ]
        },
        {
            "Effect": "Allow",
            "Resource": [
                "*"
            ],
            "Action": [
                "elasticfilesystem:CreateFileSystem",
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
                "arn:aws:elasticfilesystem:eu-west-2:${data.aws_caller_identity.current.account_id}:file-system/*"
            ],
            "Action": [
                "elasticfilesystem:CreateAccessPoint",
                "elasticfilesystem:CreateMountTarget",
                "elasticfilesystem:DeleteFileSystem",
                "elasticfilesystem:DeleteMountTarget",
            ]
        },
        {
            "Effect": "Allow",
            "Resource": [
                "arn:aws:elasticfilesystem:eu-west-2:${data.aws_caller_identity.current.account_id}:access-point/*"
            ],
            "Action": [
                "elasticfilesystem:DeleteAccessPoint",
            ]
        },
        {
            "Effect": "Allow",
            "Resource": [
                "*"
            ],
            "Action": [
                "elasticloadbalancing:CreateListener",
                "elasticloadbalancing:CreateLoadBalancer",
                "elasticloadbalancing:CreateTargetGroup",
                "elasticloadbalancing:DeleteListener",
                "elasticloadbalancing:DeleteLoadBalancer",
                "elasticloadbalancing:DeleteTargetGroup",
                "elasticloadbalancing:DescribeListeners",
                "elasticloadbalancing:DescribeLoadBalancerAttributes",
                "elasticloadbalancing:DescribeLoadBalancers",
                "elasticloadbalancing:DescribeTags",
                "elasticloadbalancing:DescribeTargetGroupAttributes",
                "elasticloadbalancing:DescribeTargetGroups",
                "elasticloadbalancing:ModifyLoadBalancerAttributes",
                "elasticloadbalancing:ModifyTargetGroupAttributes",
                "elasticloadbalancing:SetSecurityGroups"
            ]
        },
        {
            "Effect": "Allow",
            "Resource": [
                "arn:aws:rds:eu-west-2:${data.aws_caller_identity.current.account_id}:cev",
                "arn:aws:rds:eu-west-2:${data.aws_caller_identity.current.account_id}:cluster",
                "arn:aws:rds:eu-west-2:${data.aws_caller_identity.current.account_id}:cluster-endpoint",
                "arn:aws:rds:eu-west-2:${data.aws_caller_identity.current.account_id}:cluster-pg",
                "arn:aws:rds:eu-west-2:${data.aws_caller_identity.current.account_id}:cluster-snapshot",
                "arn:aws:rds:eu-west-2:${data.aws_caller_identity.current.account_id}:db",
                "arn:aws:rds:eu-west-2:${data.aws_caller_identity.current.account_id}:es",
                "arn:aws:rds:eu-west-2:${data.aws_caller_identity.current.account_id}:og",
                "arn:aws:rds:eu-west-2:${data.aws_caller_identity.current.account_id}:pg",
                "arn:aws:rds:eu-west-2:${data.aws_caller_identity.current.account_id}:proxy",
                "arn:aws:rds:eu-west-2:${data.aws_caller_identity.current.account_id}:proxy-endpoint",
                "arn:aws:rds:eu-west-2:${data.aws_caller_identity.current.account_id}:ri",
                "arn:aws:rds:eu-west-2:${data.aws_caller_identity.current.account_id}:secgrp",
                "arn:aws:rds:eu-west-2:${data.aws_caller_identity.current.account_id}:snapshot",
                "arn:aws:rds:eu-west-2:${data.aws_caller_identity.current.account_id}:subgrp:jfrog-xray-*",
                "arn:aws:rds:eu-west-2:${data.aws_caller_identity.current.account_id}:target-group"
            ],
            "Action": [
                "rds:AddTagsToResource",
                "rds:ListTagsForResource"
            ]
        },
        {
            "Effect": "Allow",
            "Resource": [
                "arn:aws:rds:eu-west-2:${data.aws_caller_identity.current.account_id}:cluster",
                "arn:aws:rds:eu-west-2:${data.aws_caller_identity.current.account_id}:db",
                "arn:aws:rds:eu-west-2:${data.aws_caller_identity.current.account_id}:og",
                "arn:aws:rds:eu-west-2:${data.aws_caller_identity.current.account_id}:pg",
                "arn:aws:rds:eu-west-2:${data.aws_caller_identity.current.account_id}:secgrp",
                "arn:aws:rds:eu-west-2:${data.aws_caller_identity.current.account_id}:subgrp"
            ],
            "Action": [
                "rds:CreateDBInstance"
            ]
        },
        {
            "Effect": "Allow",
            "Resource": [
                "arn:aws:rds:eu-west-2:${data.aws_caller_identity.current.account_id}:subgrp:jfrog-xray-*"
            ],
            "Action": [
                "rds:CreateDBSubnetGroup",
                "rds:DeleteDBSubnetGroup",
                "rds:DescribeDBSubnetGroups"
            ]
        },
        {
            "Effect": "Allow",
            "Resource": [
                "arn:aws:rds:eu-west-2:${data.aws_caller_identity.current.account_id}:db"
            ],
            "Action": [                
                "rds:DeleteDBInstance",
                "rds:DescribeDBInstances"
            ]
        }
    ]
}
EOF
}
