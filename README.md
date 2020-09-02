# terraform-aws-easy-fargate-service

Do you have a single container web service that needs to be stood up in a hurry? Does your boss need you to deploy this Wordpress site yesterday? We got you covered. With `easy-fargate-service` you can quickly and simply deploy a service using AWS Fargate.

Features:

* Sane Defaults
* Load balanced out of the box
* Configurable scaling
* Looks up Default VPC/Subnets/etc unless told otherwise
* Supports EFS

## Usage

### Prerequisites

* VPC and ECS Cluster (AWS default will do!)
* A docker image
* An ACM cert (only a prerequistie if you want to run the service over HTTPS)

### Variables

#### Required

* `family` - A unique name for the service family; Also used for naming various resources.
* `container_image` - A fully qualified Docker image repository name and tag. E.g. `nginx:latest`.

#### Optional

##### Fargate Task and Service Configuration

* `cluster_name` - The name of the ECS cluster where the Fargate service will run. Default is the default AWS cluster.
* `desired_capacity` - The desired number of containers running in the service. Default is `1`.
* `max_capacity` - The maximum number of containers running in the service. Default is same as `desired_capacity`.
* `min_capacity` - The minimum number of containers running in the service. Default is same as `desired_capacity`.
* `scaling_metric` - A type of target scaling. Needs to be either `cpu` or `memory`. Default is `null`.
* `scaling_threshold` - The percentage in which the scaling metric will trigger a scaling event. Default is `null`.
* `efs_config` - The EFS id, root directory, and path. The module currently supports only one mount. Default is `null`.
* `log_group_name` - The name of the log group. By default the `family` variable will be used.
* `log_group_stream_prefix` - The name of the log group stream prefix. By default this will be `container`.
* `log_group_retention_in_days` - The number of days to retain the log group. By default logs will never expire.
* `log_group_region` - The region where the log group exists. By default the current region will be used.
* `task_cpu` - How much CPU should be reserved for the container (in aws cpu-units). Default is `256`.
* `task_memory` - How much Memory should be reserved for the container (in MB). Default is `512`.
* `container_environment` - Environment variables to be passed in to the container. Default is `[]`.
* `container_secrets` - ECS Task Secrets to be passed in to the container and have permissions granted to read. Default is `[]`.
* `container_port` - The port the container listens on. Default is `80`.
* `health_check_path` - A relative path for the services health checker to hit. Default is `/`.
* `platform_version` - The ECS backend platform version; Defaults to `1.4.0` so EFS is supported.
* `entrypoint_override` - Your Docker entrypoint command. Default is the `ENTRYPOINT` directive from the Docker image.
* `command_override` - Your Docker command. Default is the `CMD` directive from the Docker image.
* `task_policy_json` - A JSON formated IAM policy providing the running container with permissions. Default is `null`.

##### Network and Routing Configuration

* `vpc_id` - The VPC Id in which resources will be provisioned. Default is the default AWS vpc.
* `private_subnet_ids` - A set of subnet ID's that will be associated with the Farage service. By default the module will use the default vpc's public subnets.
* `public_subnet_ids` - A set of subnet ID's that will be associated with the Application Load-balancer. By default the module will use the default vpc's public subnets.
* `security_group_ids` - A set of additional security group ID's that will associated to the Fargate service network interface. Default is `[]`.
* `certificate_arn` - A certificate ARN being managed via ACM. If provided we will redirect 80 to 443 and serve on 443/https. Otherwise traffic will be served on 80/http.
* `hosted_zone_id` - The hosted zone ID where the A record will be created. Required if `certificate_arn` and `service_fqdn` is set. Default is `null`.
* `service_fqdn` - Fully qualified domain name (www.example.com) you wish to use for your service. Must be valid against the ACM cert provided. Required if `certificate_arn` and `hosted_zone_id` is set. Default is `null`.
* `alb_log_bucket_name` - The S3 bucket name to store the ALB access logs in. Default is `null`.
* `alb_log_prefix` - Prefix for each object created in ALB access log bucket. Default is `null`.

### Simple Example

With this module you can deploy an http Fargate service with *just* two(2) variables. Yeah you heard that right, TWO VARIABLES. But be warned, this is as basic as it gets. The following example deploys a docker image on port 80 on the AWS default vpc. Be warned that the container is publically accessible to the internet, so **use this method with caution!** We can't advise it but we can't help but emphasize the **easy** in `easy-fargate-service`.

```terraform
module "my-ez-fargate-service" {
  source             = "USSBA/easy-fargate-service/aws"
  version            = "~> 2.0"
  family             = "my-ez-fargate-service"
  container_image    = "nginx:latest"
}
```

### A Realistic Example

```terraform
module "my-ez-fargate-service" {
  source             = "USSBA/easy-fargate-service/aws"
  version            = "~> 2.0"
  family             = "my-ez-fargate-service"
  container_image    = "nginx:latest"
  cluster_name       = "my-ecs-cluster"
  desired_capacity   = 2
  max_capacity       = 4
  min_capacity       = 2
  scaling_metric     = "cpu"
  scaling_threshold  = 75
  vpc_id             = "vpc-1234abcd"
  private_subnet_ids = ["subnet-11111111", "subnet-22222222", "subnet-33333333"]
  public_subnet_ids  = ["subnet-44444444", "subnet-55555555", "subnet-66666666"]
  certificate_arn    = "arn:aws:acm:us-east-1:123456789012:certificate/12345678-90ab-cdef-1234-567890abcdef"
  hosted_zone_id     = "Z000000000000"
  service_fqdn       = "www.cheeseburger.com"
  container_environment = [
    {
      name  = "FOO"
      value = "bar"
    }
  ]
  container_secrets = [
    {
      name      = "FOO_SECRET"
      valueFrom = "arn:aws:ssm:${local.region}:${local.account_id}:parameter/foo_secret"
    }
  ]
}
```

## Contributing

We welcome contributions.
To contribute please read our [CONTRIBUTING](CONTRIBUTING.md) document.

All contributions are subject to the license and in no way imply compensation for contributions.

### Terraform 0.12

Our code base now exists in Terraform 0.13 and we are halting new features in the Terraform 0.12 major version.  If you wish to make a PR or merge upstream changes back into 0.12, please submit a PR to the `terraform-0.12` branch.

## Code of Conduct

We strive for a welcoming and inclusive environment for all SBA projects.

Please follow this guidelines in all interactions:

* Be Respectful: use welcoming and inclusive language.
* Assume best intentions: seek to understand other's opinions.

## Security Policy

Please do not submit an issue on GitHub for a security vulnerability.
Instead, contact the development team through [HQVulnerabilityManagement](mailto:HQVulnerabilityManagement@sba.gov).
Be sure to include **all** pertinent information.
