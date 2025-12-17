# AWS CloudWatch Monitoring with Terraform

A comprehensive, modular Terraform project for monitoring AWS resources using CloudWatch Alarms with SNS notifications.

## Credits

Developed by **Google Antigravity** (with **Gemini 3 Pro** and **Claude Sonnet 4.5**).

## Features

- **DRY Architecture**: Reusable modules eliminate code duplication
- **Comprehensive Metrics**: CPU, memory, disk, network, connections, latency, and more
- **Flexible Configuration**: Global defaults with per-resource overrides
- **Multiple Severity Levels**: Critical, warning, and info SNS topics
- **Auto-Resolution**: Automatic lookup of resource names from tags/AWS
- **Validation**: Built-in validation for thresholds and configuration
- **Multi-Account Ready**: Optional cross-account deployment support

## Supported Services

| Service | Metrics Monitored |
|---------|-------------------|
| **EC2** | CPU, Memory*, Disk*, Network In/Out, Status Checks |
| **ASG** | CPU, Memory*, Disk*, Network In/Out, Status Checks (All Dynamic) |
| **RDS** | CPU, Free Storage, Connections, Read/Write Latency |
| **Lambda** | Errors, Throttles, Duration, Concurrent Executions |
| **ALB** | 5XX Errors (ALB & Target Groups) |
| **API Gateway** | 5XX Errors, Latency |
| **S3** | 4XX/5XX Errors |

*Requires CloudWatch Agent

## Quick Start

### Prerequisites

1. **AWS Credentials**: Configure AWS CLI or environment variables
2. **Terraform**: Version >= 1.0
3. **IAM Permissions**: CloudWatch, SNS, EC2 (read), RDS (read), etc.
4. **CloudWatch Agent** (optional): For EC2 memory/disk monitoring

### Installation

```bash
cd aws-cloudwatch-monitoring
terraform init
```

### Basic Configuration

1. Copy the example configuration:
```bash
cp environments/dev.tfvars.example dev.tfvars
```

2. Edit `dev.tfvars` with your specifics:

```hcl
aws_region = "us-east-1"

# Email notifications by severity
alarm_emails = {
  critical = ["oncall@example.com"]
  warning  = ["team@example.com"]
  info     = ["logs@example.com"]
}

# EC2 Monitoring (IDs auto-resolve to Names)
ec2_instances = {
  "i-1234567890abcdef0" = {}  # Uses defaults
  "i-critical-server" = {
    cpu_threshold = 70        # Custom threshold
    period        = 60        # Check every 1 minute
  }
}

# Auto Scaling Group Monitoring (Dynamic)
auto_scaling_groups = {
  "my-app-asg" = {            # Name of the ASG
    cpu_threshold      = 75
    memory_threshold   = 80   # Requires CW Agent
    disk_threshold     = 85   # Requires CW Agent
    network_in_threshold = 100000000
    period             = 60
    severity           = "critical" # Override severity
  }
}

# Note: ASG alarms use CloudWatch SEARCH expressions with MAX aggregation.
# A single alarm tracks all instances. If ANY instance breaches the threshold,
# the alarm fires. This provides zero-maintenance monitoring.


# RDS Monitoring
rds_instances = {
  "production-db" = {
    connections_threshold = 90
  }
}

# Lambda Monitoring
lambda_functions = {
  "api-handler" = {}
  "batch-processor" = {
    duration_threshold = 270000  # 4.5 minutes
  }
}
```

### Deploy

```bash
terraform plan
terraform apply
```

## Configuration Guide

### Global Defaults

All metrics have sensible defaults that can be overridden globally:

```hcl
# EC2 Defaults
ec2_cpu_threshold = 80           # Percentage
ec2_memory_threshold = 80        # Percentage
ec2_disk_threshold = 80          # Percentage
ec2_period = 300                 # 5 minutes
ec2_eval_periods = 2             # 2 consecutive breaches

# ASG Defaults (Dynamic Discovery)
asg_cpu_threshold = 80
asg_period = 300


# RDS Defaults
rds_connections_threshold = 80   # Percentage of max
rds_read_latency_threshold = 0.01  # 10ms
```

### Per-Resource Overrides

Override any setting for specific resources:

```hcl
ec2_instances = {
  "i-web-server" = {
    cpu_threshold = 90
    memory_threshold = 85
    period = 60
    eval_periods = 3
  }
}
```

### Severity Levels

Alarms are automatically routed to severity-specific SNS topics:

**Critical Alarms** → `cloudwatch-alerts-critical-{env}`
- EC2: CPU, Status Checks
- RDS: CPU
- Lambda: Errors, Throttles
- ALB/API Gateway/S3: 5XX Errors
- ASG: CPU, Status Checks

**Warning Alarms** → `cloudwatch-alerts-warning-{env}`
- EC2: Memory, Disk
- RDS: Storage, Connections, Latency
- Lambda: Duration, Concurrent Executions

**Info Alarms** → `cloudwatch-alerts-info-{env}`
- EC2: Network I/O

Configure different email lists per severity:

```hcl
alarm_emails = {
  critical = ["pagerduty@example.com", "oncall@example.com"]
  warning  = ["team@example.com"]
  info     = []  # No emails for info-level
}
```

Each severity level gets its own SNS topic and email subscriptions.

## Advanced Features

### CloudWatch Agent Setup (EC2 & ASG Memory/Disk)

Memory and disk monitoring require the CloudWatch Agent.

**For EC2 Instances:**
1. Install agent
2. Configure with namespace `CWAgent`
3. Ensure metrics: `mem_used_percent`, `disk_used_percent`

**For Auto Scaling Groups (CRITICAL):**
The Agent MUST be configured to emit metrics with the `AutoScalingGroupName` dimension.
In your `amazon-cloudwatch-agent.json`:
```json
{
  "metrics": {
    "append_dimensions": {
      "AutoScalingGroupName": "${aws:AutoScalingGroupName}"
    }
  }
}
```
Without this dimension, the ASG alarms cannot find the metrics for the group.

### Cross-Account Monitoring (Optional)

Monitor resources in different AWS accounts using provider aliases:

```hcl
# In your root main.tf
provider "aws" {
  alias  = "prod"
  region = "us-east-1"
  assume_role {
    role_arn = "arn:aws:iam::123456789012:role/MonitoringRole"
  }
}

module "monitor_ec2_prod" {
  source = "./modules/monitor-ec2"
  providers = {
    aws = aws.prod
  }
  # ... configuration
}
```

### Validation

Built-in validation prevents common mistakes:

```hcl
# This will ERROR - threshold must be 0-100
ec2_cpu_threshold = 150  # ❌

# This will PASS
ec2_cpu_threshold = 85   # ✅
```

## Project Structure

```
aws-cloudwatch-monitoring/
├── main.tf                    # Root configuration
├── variables.tf               # Global variables
├── outputs.tf                 # Outputs
├── versions.tf                # Provider versions
└── modules/
    ├── common-alarm/          # Base alarm module (DRY)
    ├── monitor-ec2/           # EC2 monitoring
    ├── monitor-rds/           # RDS monitoring
    ├── monitor-lambda/        # Lambda monitoring
    ├── monitor-alb/           # ALB monitoring
    ├── monitor-apigateway/    # API Gateway monitoring
    └── monitor-s3/            # S3 monitoring
```

## Outputs

After deployment, Terraform outputs the SNS topic ARNs:

```bash
terraform output
```

Use these ARNs to integrate with:
- PagerDuty
- Slack
- Microsoft Teams
- Custom webhooks

## Cost Estimation

CloudWatch costs (us-east-1, as of 2024):
- **Alarms**: $0.10/alarm/month
- **Metrics** (custom): $0.30/metric/month
- **API calls**: Minimal

Example: 50 EC2 instances with 6 alarms each = 300 alarms = **$30/month**

## Troubleshooting

### Alarms not triggering

1. Check SNS topic subscriptions are confirmed (check email)
2. Verify metric data exists: `aws cloudwatch get-metric-statistics ...`
3. Check alarm state: `aws cloudwatch describe-alarms`

### Memory/Disk alarms missing

1. Ensure CloudWatch Agent is installed and running
2. Verify namespace is `CWAgent`
3. Check agent configuration file

### Data source errors

```
Error: no matching EC2 Instance found
```
- Verify instance ID exists in the specified region
- Check AWS credentials have EC2 read permissions

## Contributing

To add a new service:

1. Create `modules/monitor-<service>/`
2. Define variables in `variables.tf`
3. Create alarms in `main.tf` using `common-alarm` module
4. Add service variables to root `variables.tf`
5. Wire module in root `main.tf`

## License

MIT License - See LICENSE file

## Support

For issues or questions:
- GitHub Issues: [your-repo-url]
- Documentation: See `walkthrough.md` for detailed examples

---

**Note**: This project creates CloudWatch Alarms which incur AWS costs. Review pricing before deployment.

