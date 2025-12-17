# Deployment Guide

## Commands

### Development
```bash
terraform plan -var="TF_ENV=dev" -var="aws_profile=dev-profile" -var-file="environments/dev.tfvars"
terraform apply -var="TF_ENV=dev" -var="aws_profile=dev-profile" -var-file="environments/dev.tfvars"
```

### Staging
```bash
terraform plan -var="TF_ENV=stg" -var="aws_profile=staging-profile" -var-file="environments/stg.tfvars"
terraform apply -var="TF_ENV=stg" -var="aws_profile=staging-profile" -var-file="environments/stg.tfvars"
```

### Production
```bash
terraform plan -var="TF_ENV=prod" -var="aws_profile=production-profile" -var-file="environments/prod.tfvars"
terraform apply -var="TF_ENV=prod" -var="aws_profile=production-profile" -var-file="environments/prod.tfvars"
```

## Project Name

Set the `project` variable in your `.tfvars` file to include it in alarm names:

```hcl
# environments/prod.tfvars
project = "api"
```

This will create alarms like:
- `api-ec2-WebServer-high-cpu`
- Description: `[api] CPU too high...`

If you don't set `project`, alarms will be named:
- `ec2-WebServer-high-cpu`
- Description: `CPU too high...`

## Configuration Files

- `environments/dev.tfvars` - Development resources
- `environments/stg.tfvars` - Staging resources
- `environments/prod.tfvars` - Production resources

## Safety Features

- **TF_ENV validation**: Only dev/stg/prod allowed
- **Profile validation**: aws_profile must match expected profile for TF_ENV
- **Auto-tagging**: All resources tagged with environment and project

## Customize AWS Profiles

Edit `variables.tf`:

```hcl
variable "environment_profile_map" {
  default = {
    dev  = "your-dev-profile"
    stg  = "your-stg-profile"
    prod = "your-prod-profile"
  }
}
```
