# Take-Home-Assessment

Assessment for DevSecOps interviewing

## Features

- Terraform for deploying the solution infrastructure
- Python code for executing the health check API in Lambda function
- GitlabCI pipeline for deploy and redeploy the infrastructure
- Auto trigger pipeline with different changes in infra code or lambda code

## Prerequisites

For using this source code, you have to provide these requirements
- **AWS environment** AWS environment is required for deploying the infrastructure (Must have enough permission for creating and managing resources)
- **Gitlab environment** Gitlab is for code repository and pipeline executing
- **Gitlab runner** A Gitlab runner for executing the pipeline will required
    - `terraform` for executing the terraform command
    - `docker` for pulling images required in the pipeline
    - `aws credential` for managing the AWS resources

## Infrastructure 

This infrastructure contain these AWS resources:
- An S3 bucket for storing the report contains timestamps and health status of the CloudFlare API
- A CloudWatch Metrics of CloudFlare API Health Check status 
- A Lambda Function for query the CloudFlare API to get the health check responses and put report to s3, metric to Cloudwatch
- An Cloudwatch Event Schedule that create schedule event every 5 minutes target to the Lambda Function for periodically health checking purpose

## Pipeline

The pipeline contain these steps:
- **codescan** Using Checkov for code scanning to ensure Terraform configuration quality
- **infra_validate** Initialize the Terraform, installing the tf dependencies and setup Terraform backend
- **infra_deploy** Check for the infrastructure code changes. Generate execution plan for Terraform, showing changes include resources to be create, modify, delete or recreate. After that, apply changes to the infrastructure
- **lambda_redeploy** Check for the processing code changes then recreate the Lambda Function and Event Schedule that target to the Lambda