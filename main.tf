terraform {
  required_version = ">= 1.6.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0, < 6.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

variable "aws_region" {
  type    = string
  default = "ap-south-1"
}

variable "instance_id" {
  type        = string
  description = "EC2 instance ID to monitor, for example i-0123456789abcdef0."
}

variable "alert_email" {
  type        = string
  description = "Address that must confirm the SNS subscription."
}

variable "cpu_threshold" {
  type    = number
  default = 70
}

resource "aws_sns_topic" "alerts" {
  name = "ec2-cpu-alerts"
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}

resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name          = "${var.instance_id}-high-cpu"
  alarm_description   = "EC2 CPU stayed above the configured threshold for two evaluation periods."
  namespace           = "AWS/EC2"
  metric_name         = "CPUUtilization"
  statistic           = "Average"
  period              = 300
  evaluation_periods  = 2
  datapoints_to_alarm = 2
  threshold           = var.cpu_threshold
  comparison_operator = "GreaterThanOrEqualToThreshold"
  treat_missing_data  = "notBreaching"
  dimensions          = { InstanceId = var.instance_id }
  alarm_actions       = [aws_sns_topic.alerts.arn]
  ok_actions          = [aws_sns_topic.alerts.arn]
}

output "alarm_name" {
  value = aws_cloudwatch_metric_alarm.high_cpu.alarm_name
}

output "sns_topic_arn" {
  value = aws_sns_topic.alerts.arn
}
