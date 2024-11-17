import urllib3
import csv
import boto3
import time
from datetime import datetime
from io import StringIO
from config import (
    cloudwatch_namespace,
    s3,
    api_healthcheck_url,
    cloudwatch,
)


# Function to query GitLab API
def query_healtcheck_api():
    try:
        url= api_healthcheck_url
        http = urllib3.PoolManager()
        method = "GET"
        headers = {
        "Content-Type": "application/json",
        }
        health_response = http.request(
            method=method, 
            url= url, 
            headers=headers,
            
        )
        timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        health_status = "healthy" if health_response.status == 200 else "unhealthy"
        return timestamp, health_status

    except Exception as e:
        print(f"Error querying CloudFlare API: {e}")
        return None


def upload_csv_s3():  # Function to generate CSV report and upload to S3
    data = query_healtcheck_api()
    if data:
        timestamp, health_status = data
    csv_buffer = StringIO()
    csvwriter = csv.writer(csv_buffer)
    csvwriter.writerow(
        ["Timestamp", "Health Status"]
    )
    
    csvwriter.writerow(
        [
            timestamp,
            health_status
        ]
    )

    # generate current time based prefix (e.g. reports/2021-09-01/)
    current_time = datetime.now().strftime("%Y-%m-%d")

    s3_key = f"reports/{current_time}/CloudFlare.csv"

    # Upload to S3
    s3_bucket = boto3.client("s3")
    s3_bucket.put_object(
        Bucket=s3,
        Key=s3_key,
        Body=csv_buffer.getvalue(),
    )

    print("CSV report uploaded to S3.")


# Function to publish metrics to cloudwatch
def publish_to_cloudwatch(health_status):
    try:
        cloudwatch.put_metric_data(
            Namespace=cloudwatch_namespace,
            MetricData=[
                {
                    "MetricName": "HealthStatus",
                    "Dimensions": [{"Name": "Service", "Value": "CloudFlare"}],
                    "Value": 1 if health_status == "healthy" else 0,
                    "Unit": "Count",
                }
            ]
        )
        print("Metrics published to CloudWatch.")
    except Exception as e:
        print(f"Error publishing metrics to CloudWatch: {e}")


# Main function to query and store data
def lambda_handler(event, context):
    try:
        result = query_healtcheck_api()
        if result:
            health_status = result
            print(result)
            publish_to_cloudwatch(health_status)
        upload_csv_s3()

        return {
            "statusCode": 200,
            "body": "Data successfully stored in DynamoDB and CSV report uploaded to S3.",
        }

    except Exception as e:
        print(f"Error during execution: {e}")
        return {
            "statusCode": 500,
            "body": f"Error during execution: {e}",
        }
