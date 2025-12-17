# Cross-Account Monitoring Setup Guide

This guide explains how to monitor AWS resources across multiple accounts using provider aliases.

## Architecture

```
Management Account (Terraform runs here)
  ├── Monitors resources in Production Account
  ├── Monitors resources in Staging Account
  └── Monitors resources in Development Account
```

## Prerequisites

1. **IAM Roles**: Create a monitoring role in each target account
2. **Trust Relationship**: Allow management account to assume the role
3. **Permissions**: CloudWatch read, EC2 describe, RDS describe, etc.

## Setup Steps

### 1. Create IAM Role in Target Accounts

In each account you want to monitor (e.g., Production):

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::MANAGEMENT_ACCOUNT_ID:root"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
```

Attach policy:
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "cloudwatch:PutMetricAlarm",
        "cloudwatch:DeleteAlarms",
        "cloudwatch:DescribeAlarms",
        "ec2:DescribeInstances",
        "rds:DescribeDBInstances",
        "elasticloadbalancing:DescribeLoadBalancers",
        "elasticloadbalancing:DescribeTargetGroups",
        "sns:CreateTopic",
        "sns:Subscribe",
        "sns:ListSubscriptionsByTopic"
      ],
      "Resource": "*"
    }
  ]
}
```

### 2. Configure Providers in Terraform

In your root `main.tf`:

```hcl
# Default provider (management account)
provider "aws" {
  region = var.aws_region
}

# Production account
provider "aws" {
  alias  = "production"
  region = var.aws_region
  assume_role {
    role_arn = "arn:aws:iam::111111111111:role/MonitoringRole"
  }
}

# Staging account
provider "aws" {
  alias  = "staging"
  region = var.aws_region
  assume_role {
    role_arn = "arn:aws:iam::222222222222:role/MonitoringRole"
  }
}
```

### 3. Deploy Modules Per Account

```hcl
# Production EC2 monitoring
module "monitor_ec2_prod" {
  source = "./modules/monitor-ec2"
  
  providers = {
    aws = aws.production
  }
  
  instances_config = var.ec2_instances_prod
  cpu_threshold    = var.ec2_cpu_threshold
  period           = var.ec2_period
  eval_periods     = var.ec2_eval_periods
  alarm_sns_topics = [aws_sns_topic.alerts_prod.arn]
}

# Staging EC2 monitoring
module "monitor_ec2_staging" {
  source = "./modules/monitor-ec2"
  
  providers = {
    aws = aws.staging
  }
  
  instances_config = var.ec2_instances_staging
  cpu_threshold    = var.ec2_cpu_threshold
  period           = var.ec2_period
  eval_periods     = var.ec2_eval_periods
  alarm_sns_topics = [aws_sns_topic.alerts_staging.arn]
}
```

### 4. Separate Variables Per Account

In `variables.tf`:

```hcl
variable "ec2_instances_prod" {
  description = "Production EC2 instances"
  type = map(object({
    cpu_threshold = optional(number)
    period        = optional(number)
    eval_periods  = optional(number)
  }))
  default = {}
}

variable "ec2_instances_staging" {
  description = "Staging EC2 instances"
  type = map(object({
    cpu_threshold = optional(number)
    period        = optional(number)
    eval_periods  = optional(number)
  }))
  default = {}
}
```

### 5. Configure in terraform.tfvars

```hcl
# Production instances
ec2_instances_prod = {
  "i-prod-web-1" = {}
  "i-prod-web-2" = {}
  "i-prod-db" = {
    cpu_threshold = 70
  }
}

# Staging instances
ec2_instances_staging = {
  "i-staging-web" = {}
}
```

## Alternative: Workspace-Based Approach

Use Terraform workspaces for account separation:

```bash
# Create workspaces
terraform workspace new production
terraform workspace new staging

# Deploy to production
terraform workspace select production
terraform apply -var-file="production.tfvars"

# Deploy to staging
terraform workspace select staging
terraform apply -var-file="staging.tfvars"
```

## SNS Topics Per Account

Create separate SNS topics in each account:

```hcl
# Production SNS
resource "aws_sns_topic" "alerts_prod" {
  provider = aws.production
  name     = "cloudwatch-alerts-production"
}

# Staging SNS
resource "aws_sns_topic" "alerts_staging" {
  provider = aws.staging
  name     = "cloudwatch-alerts-staging"
}
```

## Best Practices

1. **Separate State Files**: Use different S3 backends per account
2. **Tagging**: Add `Environment` tag to distinguish resources
3. **Naming**: Include account/environment in alarm names
4. **Testing**: Test in staging before deploying to production
5. **Permissions**: Use least-privilege IAM roles

## Troubleshooting

### "AssumeRole" errors
- Verify trust relationship in target account
- Check management account has `sts:AssumeRole` permission
- Confirm role ARN is correct

### Resources not found
- Ensure provider alias is specified in module
- Verify region matches resource location
- Check IAM role has describe permissions

## Security Considerations

- **MFA**: Require MFA for AssumeRole in production
- **External ID**: Use external ID for additional security
- **Session Duration**: Set appropriate session timeout
- **Audit**: Enable CloudTrail in all accounts

---

For questions, see main README.md or open an issue.
