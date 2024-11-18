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
    - `docker` for pulling images required in the pipeline
    - `aws-cli` for executing commands and storing credential
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
- **infra_deploy** Generate execution plan for Terraform, showing changes include resources to be create, modify, delete or recreate. After that, apply changes to the infrastructure.
- **lambda_redeploy** Check for the processing code changes then recreate the Lambda Function and Event Schedule that target to the Lambda
- **infra_destroy** Destroy all the infrastructure for avoiding cost wasting when health checking is not needed

## Instruction

1. **Gitlab-Runner** 
    - **Installation** 
        - Follow basic setup for gitlab runner installation
        - Provide dependencies for runner:
            - Install Docker
            - Install aws-cli
            - Config aws configure to set the credential for AWS environment
        
2. **Pipeline**
    - **Steps**
        - **codescan** Step for code scanning using bridgecrew/checkov image
            - This step will be executed automatically in the pipeline
            - This step can be passed even it is failed
        - **infra_validate** Step for Terraform init and validate using hashicorp/terraform image
            - This step will be executed automatically in the pipeline
            - This step cannot be passed when it is failed
        - **infra_deploy** Step for Terraform init and validate using hashicorp/terraform image
            - This step will be executed manually in the pipeline
            - This step cannot be passed when it is failed
            - This step depend on infra_validate
        - **lambda_redeploy** Step for Terraform init and validate using hashicorp/terraform image
            - This step will be executed automatically in the pipeline when changes in the processing code
            - This step cannot be passed when it is failed
            - This step depend on infra_deploy
        - **infra_destroy** Step for Terraform init and validate using hashicorp/terraform image
            - This step will be executed manually in the pipeline
            - This step cannot be passed when it is failed
            - Remember to empty the S3 bucket "csv-healthcheck-bucket" so as to destroy the resources without any error

3. **Dashboard and alert**
    - **Dashboard setup**
        - Go to CloudWatch
        - Choose Create Dashboard -> Define the dashboard name -> [Data type: Metrics , Widget type: Line]
        - Choose Custome namespace "HealthCheck" -> Service -> CloudFlare -> Create widget
    - **Alert**
        - Go to CloudWatch
        - Choose All metrics -> Custome namespace "HealthCheck" -> Service -> CloudFlare
        - Choose Create alarm -> Condition [Threshold type: "Static" , Whenever HealthStatus is: "Greater" , than: "0"] -> Create topic in SNS -> Name the alarm -> Create alarm