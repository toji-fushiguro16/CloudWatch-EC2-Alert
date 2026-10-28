# EC2 CPU Monitoring Alert

This Terraform project creates an Amazon CloudWatch alarm for an existing EC2 instance and sends state-change notifications through Amazon SNS email.

## Architecture

```text
EC2 CPUUtilization → CloudWatch alarm → SNS email subscription
```

## Deploy

Prerequisites: Terraform 1.6+, AWS CLI credentials, an EC2 instance in the selected region, and permission to create CloudWatch alarms and SNS topics/subscriptions.

```bash
aws configure
terraform init
terraform plan -var="instance_id=i-0123456789abcdef0" -var="alert_email=you@example.com"
terraform apply -var="instance_id=i-0123456789abcdef0" -var="alert_email=you@example.com"
```

Confirm the SNS subscription from the email before expecting notifications. The alarm checks five-minute average CPU and enters ALARM after two consecutive periods at or above the threshold. Override it with `-var="cpu_threshold=80"`.

## Clean up

```bash
terraform destroy -var="instance_id=i-0123456789abcdef0" -var="alert_email=you@example.com"
```

The stack creates an alarm, an SNS topic, and an email subscription. CloudWatch and SNS usage may incur account charges. This project does not create or modify the monitored EC2 instance.
