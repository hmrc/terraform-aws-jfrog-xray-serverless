
# terraform-aws-jfrog-xray-serverless

Terraform module which uses serverless or managed [AWS](https://aws.amazon.com) resources to add [JFrog Xray](https://jfrog.com/xray/) capabilities to an existing [JFrog Platform](https://jfrog.com/platform/) configuration.

## Usage

<!--
TODO: Is it cool to have the join key in plaintext like this? Might be better to advise using a sensitive variable or something
-->


```hcl
module "jfrog_xray" {
  source = "github.com/hmrc/terraform-aws-jfrog-xray-serverless"

  artifactory_url               = "https://artifactory.example.com"
  artifactory_join_key          = "foo-join-key"
  subnet_ids                    = ["subnet-123", "subnet-456"]
  vpc_id                        = "vpc-123"
  artifactory_security_group_id = "sg-123"
}
```

### Prerequisites

In order to successfully use this module, you require the following:

* A configured, healthy and licensed instance of JFrog Platform (i.e. [JFrog Artifactory](https://jfrog.com/artifactory/)) running in AWS.
* The [join key](https://www.jfrog.com/confluence/display/JFROG/Managing+Keys#ManagingKeys-JoinKey) for the JFrog Platform.
* An [AWS VPC](https://aws.amazon.com/vpc/), including subnets that can route to the public internet and the Artifactory URL.

## Examples

* [JFrog Artifactory with Xray](https://github.com/hmrc/terraform-aws-jfrog-xray-serverless/tree/main/examples/jfrog-artifactory-with-xray)

## Contributing

Report issues/questions/feature requests on in the [issues](https://github.com/hmrc/terraform-aws-jfrog-xray-serverless/issues/new) section.

PRs are welcomed. More specific guidance will be added in future.

### Local Testing

Terratests can be run locally by running `make test` with AWS authentication.

With aws-profile:
`aws-profile -p <user> make test`

With aws-vault:
`aws-vault exec <user> -- make test`


## Requirements

|Name|Version|
|-|-|
|terraform|>= 1.0.11|
|aws|>= 3.69.0|
|random|>= 3.1.0|

## Providers

No providers.

## Modules

No modules.

## Resources

|Name|Type|
|-|-|
|aws_caller_identity.current|data|
|aws_cloudwatch_log_group.main|resource|
|aws_db_instance.main|resource|
|aws_db_subnet_group.main|resource|
|aws_ecs_cluster.main|resource|
|aws_ecs_service.main|resource|
|aws_ecs_task_definition.main|resource|
|aws_efs_access_point.rabbitmq|resource|
|aws_efs_access_point.xray|resource|
|aws_efs_file_system.main|resource|
|aws_efs_mount_target.main|resource|
|aws_iam_role.ecs_execution|resource|
|aws_security_group.ecs_task|resource|
|aws_security_group.efs_file_system|resource|
|aws_security_group.rds_instance|resource|
|aws_security_group_rule.ecs_task_allow_dns_to_anywhere|resource|
|aws_security_group_rule.ecs_task_allow_http_from_artifactory|resource|
|aws_security_group_rule.ecs_task_allow_http_to_anywhere|resource|
|aws_security_group_rule.ecs_task_allow_http_to_artifactory|resource|
|aws_security_group_rule.ecs_task_allow_https_to_anywhere|resource|
|aws_security_group_rule.ecs_task_allow_nfs_to_efs|resource|
|aws_security_group_rule.ecs_task_allow_postgres_to_rds|resource|
|aws_security_group_rule.efs_allow_nfs_from_ecs_task|resource|
|aws_security_group_rule.rds_allow_postgres_from_ecs_task|resource|
|random_password.rds|resource|

## Inputs

|Name|Description|Type|Default|Required|
|-|-|-|-|-|
|artifactory_join_key|Key to use in order to join Xray to the JFrog Artifactory/Platform service.|`string`|n/a|yes|
|artifactory_security_group_id|The ID of the Security Group assigned to Artifactory instances.|`string`|n/a|yes|
|artifactory_url|URL of the JFrog Artifactory/Platform service that Xray will be joined to.|`string`|n/a|yes|
|assign_public_ip|Set whether to give the Xray task a public IP. Only turn this on if testing with only an internet gateway.|`bool`|`false`|no|
|environment_name|The name of the environment. Used for the names of various resources.|`string`|`"jfrog-xray"`|no|
|subnet_ids|A list of subnet IDs to run the JFrog Xray resources in.|`list(string)`|n/a|yes|
|vpc_id|The ID of the VPC to run the JFrog Xray resources in.|`string`|n/a|yes|
|xray_task_cpu|CPU value to be used for the Xray Fargate task.|`number`|`1024`|no|
|xray_task_memory|Amount of memory to be used for the Xray Fargate task.|`number`|`2048`|no|
|xray_version|Version of JFrog Xray you wish to run.|`string`|`"3.36.2"`|no|

## Outputs

No outputs.

## License

This code is open source software licensed under the [Apache 2.0 License]("http://www.apache.org/licenses/LICENSE-2.0.html").
