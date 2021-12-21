# JFrog Artifactory with Xray

Provisions a thin slice implementation of JFrog Artifactory/Platform, and then uses the `terraform-aws-jfrog-with-xray` module to extend it with JFrog Xray.

> The implemention of JFrog Artifactory/Platform within this example is for test purposes only and has not been optimised for performance, availability or security. It should not considered for production use.

## Usage

To run this example you need to execute:

```bash
$ terraform init
$ terraform apply
```

Note that this example creates resources which cost money. Run `terraform destroy` when you don't need these resources.

### Prerequisites

In order to join JFrog Xray to a JFrog Artifactory/Platform instance, that instance must have an appropriate licence installed. This is also true for example/test infrastructure.

In order for the Artifactory task to properly find an appropriate licence, first add a base64 encoded licence key to [AWS Systems Manager Parameter Store](https://docs.aws.amazon.com/systems-manager/latest/userguide/systems-manager-parameter-store.html) as a secure string with path `/terraform-aws-jfrog-xray-serverless/artifactory/licence-key-base64`.

## Requirements

|Name|Version|
|-|-|
|terraform|>= 1.0.11|
|aws|>= 3.69.0|
|null|>= 3.1.0|
|random|>= 3.1.0|

## Providers

|Name|Version|
|-|-|
|aws|>= 3.69.0|
|null|>= 3.1.0|
|random|>= 3.1.0|

## Modules

|Name|Source|Version|
|-|-|-|
|jfrog_xray|../../|n/a|
|vpc|terraform-aws-modules/vpc/aws|2.64.0|

## Resources

|Name|Type|
|-|-|
|aws_caller_identity.current|data|
|aws_cloudwatch_log_group.artifactory|resource|
|aws_ecs_cluster.main|resource|
|aws_ecs_service.jfrog_artifactory_service|resource|
|aws_ecs_task_definition.artifactory|resource|
|aws_iam_role.artifactory_ecs_execution|resource|
|aws_lb.artifactory|resource|
|aws_lb_listener.artifactory|resource|
|aws_lb_target_group.artifactory|resource|
|aws_security_group.artifactory-lb-access|resource|
|aws_security_group.artifactory_instance|resource|
|aws_security_group_rule.artifactory_allow_all_to_vpc_public_subnets|resource|
|aws_security_group_rule.artifactory_allow_dns_to_anywhere|resource|
|aws_security_group_rule.artifactory_allow_http_from_lb|resource|
|aws_security_group_rule.artifactory_allow_http_from_public_subnets|resource|
|aws_security_group_rule.artifactory_allow_https_to_anywhere|resource|
|null_resource.wait_for_artifactory|resource|
|null_resource.wait_for_xray|resource|
|random_string.resource_code|resource|

## Inputs

No inputs.

## Outputs

|Name|Description|
|-|-|
|artifactory_url|URL of the JFrog Artifactory/Platform service.|
