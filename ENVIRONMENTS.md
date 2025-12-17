# Environment-Based Deployment Guide

## Overview

This project uses the `TF_ENV` variable to control which AWS account to deploy to (dev, stg, prod) with AWS profile validation as a safety mechanism.

## Quick Start

### Deploy to Development
```bash
terraform plan \
  -var="TF_ENV=dev" \
  -var="aws_profile=dev-profile" \
  -var-file="environments/dev.tfvars"

terraform apply \
  -var="TF_ENV=dev" \
  -var="aws_profile=dev-profile" \
  -var-file="environments/dev.tfvars"
```

### Deploy to Staging
```bash
terraform apply \
  -var="TF_ENV=stg" \
  -var="aws_profile=staging-profile" \
  -var-file="environments/stg.tfvars"
```

### Deploy to Production
```bash
terraform apply \
  -var="TF_ENV=prod" \
  -var="aws_profile=production-profile" \
  -var-file="environments/prod.tfvars"
```

## Safety Features

### 1. Environment Validation
Only `dev`, `stg`, and `prod` are allowed:
```bash
# This will ERROR
terraform apply -var="TF_ENV=development"  # ❌ Invalid
```

### 2. Profile Double-Check
The AWS profile must match the expected profile for the environment:

**Default mapping** (configured in `variables.tf`):
- `dev` → `dev-profile`
- `stg` → `staging-profile`
- `prod` → `production-profile`

**Example error prevention:**
```bash
# This will ERROR with clear message
terraform apply \
  -var="TF_ENV=prod" \
  -var="aws_profile=dev-profile"  # ❌ Profile mismatch!
```

Error message:
```
Profile mismatch! Environment 'prod' requires profile 'production-profile' but got 'dev-profile'
```

## Configuration

### Update Expected Profiles

Edit `variables.tf` to change the expected profile names:

```hcl
variable "environment_profile_map" {
  default = {
    dev  = "my-dev-profile"      # Your dev profile name
    stg  = "my-staging-profile"  # Your staging profile name
    prod = "my-prod-profile"     # Your production profile name
  }
}
```

### AWS CLI Profile Setup

Configure your AWS CLI profiles in `~/.aws/credentials`:

```ini
[dev-profile]
aws_access_key_id = YOUR_DEV_KEY
aws_secret_access_key = YOUR_DEV_SECRET

[staging-profile]
aws_access_key_id = YOUR_STAGING_KEY
aws_secret_access_key = YOUR_STAGING_SECRET

[production-profile]
aws_access_key_id = YOUR_PROD_KEY
aws_secret_access_key = YOUR_PROD_SECRET
```

Or use role assumption in `~/.aws/config`:

```ini
[profile dev-profile]
role_arn = arn:aws:iam::111111111111:role/TerraformRole
source_profile = default

[profile staging-profile]
role_arn = arn:aws:iam::222222222222:role/TerraformRole
source_profile = default

[profile production-profile]
role_arn = arn:aws:iam::333333333333:role/TerraformRole
source_profile = default
```

## Environment-Specific Resources

All resources are automatically tagged and named with the environment:

**SNS Topics:**
- `cloudwatch-alerts-critical-dev`
- `cloudwatch-alerts-critical-stg`
- `cloudwatch-alerts-critical-prod`

**Tags:**
All resources get these tags automatically:
```hcl
{
  Environment = "dev"  # or stg/prod
  ManagedBy   = "Terraform"
  # ... plus any tags from your tfvars
}
```

## Environment Files

Each environment has its own configuration file:

```
environments/
├── dev.tfvars      # Development resources and settings
├── stg.tfvars      # Staging resources and settings
└── prod.tfvars     # Production resources and settings
```

**Edit these files** to configure which resources to monitor in each environment.

## Best Practices

### 1. Always Specify Both Variables
```bash
# ✅ Correct
terraform apply -var="TF_ENV=prod" -var="aws_profile=production-profile" -var-file="environments/prod.tfvars"

# ❌ Missing profile (will use default, may be wrong)
terraform apply -var="TF_ENV=prod" -var-file="environments/prod.tfvars"
```

### 2. Use Shell Aliases
Create aliases in your `~/.bashrc` or `~/.zshrc`:

```bash
alias tf-dev='terraform apply -var="TF_ENV=dev" -var="aws_profile=dev-profile" -var-file="environments/dev.tfvars"'
alias tf-stg='terraform apply -var="TF_ENV=stg" -var="aws_profile=staging-profile" -var-file="environments/stg.tfvars"'
alias tf-prod='terraform apply -var="TF_ENV=prod" -var="aws_profile=production-profile" -var-file="environments/prod.tfvars"'
```

Then simply run:
```bash
tf-dev    # Deploy to dev
tf-prod   # Deploy to prod
```

### 3. Plan Before Apply
Always run `plan` first:
```bash
terraform plan -var="TF_ENV=prod" -var="aws_profile=production-profile" -var-file="environments/prod.tfvars"
```

### 4. Separate State Files (Optional)

For additional safety, use different state files per environment:

```bash
# Development
terraform init -backend-config="key=monitoring/dev/terraform.tfstate"

# Production
terraform init -backend-config="key=monitoring/prod/terraform.tfstate"
```

## Troubleshooting

### Profile not found
```
Error: No valid credential sources found
```
**Fix**: Ensure the profile exists in `~/.aws/credentials` or `~/.aws/config`

### Profile mismatch error
```
Profile mismatch! Environment 'prod' requires profile 'production-profile'
```
**Fix**: Use the correct profile for the environment, or update `environment_profile_map` in `variables.tf`

### Wrong resources deployed
**Prevention**: Always double-check the `TF_ENV` value and tfvars file match
**Recovery**: Run `terraform destroy` with the same variables, then redeploy correctly

## Summary

**Three-step safety:**
1. ✅ `TF_ENV` must be dev/stg/prod (validated)
2. ✅ `aws_profile` must match expected profile (validated)
3. ✅ Use correct tfvars file (manual check)

This prevents accidental deployments to wrong environments!
