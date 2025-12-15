# AWS Photo Recognition Pipeline

## Overview

This project implements an event-driven, serverless photo recognition pipeline on AWS, fully provisioned using Terraform.

Images uploaded to Amazon S3 trigger an EventBridge rule that delivers events to an SQS queue. A Lambda function consumes the messages, analyzes the images using Amazon Rekognition, and stores structured metadata in DynamoDB.

The project focuses on production-oriented best practices such as infrastructure modularization, decoupled event processing, observability (logs, metrics, dashboards, and alarms), and CI/CD automation using GitHub Actions with OIDC authentication.

---

## Features

- **Amazon S3** – Stores uploaded images and emits object creation events.
- **Amazon EventBridge** – Routes S3 events in a decoupled and scalable way.
- **Amazon SQS + Dead Letter Queue (DLQ)** – Buffers events and isolates failures.
- **AWS Lambda** – Processes SQS messages, calls Amazon Rekognition, and persists results.
- **Amazon Rekognition** – Detects animals (dogs and cats) in uploaded images.
- **Amazon DynamoDB** – Stores image metadata and detection results.
- **Amazon CloudWatch Logs** – Centralized logging for Lambda execution.
- **Custom CloudWatch Metrics** – Tracks processed images and detected animals.
- **CloudWatch Dashboard & Alarms** – Provides observability and operational visibility.
- **Terraform (Infrastructure as Code)** – Modular, reusable, and environment-agnostic infrastructure.
- **GitHub Actions + OIDC** – Secure CI/CD pipeline without long-lived AWS credentials.

---

## Architecture Overview

![Architecture Diagram](architecture.png)

## Prerequisites
Before deploying this project, ensure you have the following installed:

### **1. Install Terraform**
- Download Terraform from the official site: [Terraform Download](https://www.terraform.io/downloads)
- Install it by following the instructions for your OS.
- Verify installation by running:
  ```sh
  terraform -version
  ```

### **2. Configure AWS CLI**
- Install AWS CLI: [AWS CLI Installation](https://aws.amazon.com/cli/)
- Configure it with your AWS credentials:
  ```sh
  aws configure
  ```
  Provide your AWS **Access Key**, **Secret Key**, **Region**, and **Output Format**.

### **3. Set Up VS Code (Optional, but Recommended)**
- Install **VS Code**: [Download Here](https://code.visualstudio.com/)
- Install **Terraform Extension**: Search for `HashiCorp Terraform` in VS Code Extensions.

---

## Project Structure
```
aws-photo-recognition/
├── .github/
│   └── workflows/              # GitHub Actions workflows
│       ├── terraform.yml
│       └── test-oidc.yml
├── lambda/
│   ├── lambda_function.py      # Lambda function source code
│   └── lambda.zip              # Generated automatically by Terraform (not committed)
├── terraform/
│   ├── backend.tf              # Remote state configuration (S3 + DynamoDB)
│   ├── cloudwatch.tf           # Dashboards, alarms, and custom metrics
│   ├── eventbridge.tf          # EventBridge rules and targets
│   ├── iam-github-oidc.tf      # GitHub Actions OIDC configuration
│   ├── main.tf                 # Root Terraform configuration
│   ├── modules/                # Reusable Terraform modules
│   │   ├── lambda/             # Lambda function, IAM role, permissions
│   │   ├── s3_bucket/          # S3 input bucket
│   │   ├── sqs/                # SQS queue and DLQ
│   │   ├── dynamodb/           # DynamoDB table
│   │   └── eventbridge/        # EventBridge integration
│   └── .terraform.lock.hcl     # Provider dependency lock file
├── architecture.png            # High-level architecture diagram
└── README.md                   # Project documentation

```

---

## Deployment Guide

### **Step 1: Clone the Repository**
```sh
git clone https://github.com/diana-mih/aws-photo-recognition.git
cd aws_photo_recognition
```

### **Step 2: Prerequisites**

Ensure the following tools are installed and configured:

- Terraform >= 1.5
- AWS CLI
- Git

Configure AWS credentials locally (for manual deployment):

```sh
aws configure
```

Note: The project also supports automated deployments via GitHub Actions using OIDC, without storing long-lived AWS credentials.


### **Step 3: Initialize Terraform**
```sh
cd terraform
terraform init
```

This step:
- Downloads required providers
- Initializes the remote backend
- Prepares Terraform modules

### **Step 4: Plan Deployment**
```sh
terraform plan
```
- Shows what Terraform will create before applying changes.

### **Step 5: Apply Configuration**
```sh
terraform apply
```
Terraform will:
- Build the Lambda deployment package automatically using archive_file
- Provision all AWS resources
- Configure permissions and event sources

### **Step 6: Access the Application**

1. Upload an image containing a dog or a cat to the S3 input bucket.
2. EventBridge routes the event to SQS.
3. Lambda processes the message and calls Amazon Rekognition.
4. Detection results are stored in DynamoDB.
5. Logs, metrics, and dashboards are available in CloudWatch.

### **Step 7: Destroy Resources (Optional)**
If you want to delete all resources:
```sh
terraform destroy
```

---

## Observability & Monitoring

The project includes built-in observability using Amazon CloudWatch to ensure visibility into the pipeline’s behavior and failures.

### **Logging**
- The Lambda function writes structured logs to **CloudWatch Logs**
- Each processed image and error is logged for traceability and debugging

### **Custom Metrics**
The Lambda function publishes custom CloudWatch metrics, including:
- Number of processed images
- Number of detected animals
- Images with no animals detected

These metrics enable operational insights beyond basic Lambda invocation metrics.

### **Dashboards**
A **CloudWatch Dashboard** provides a centralized view of:
- Image processing volume
- Animal detection activity
- Error and anomaly indicators

### **Alarms**
CloudWatch alarms are configured to:
- Detect when images are processed but no animals are found
- Provide early signals for potential issues in the detection pipeline

---

## CI/CD with GitHub Actions

This project includes a fully automated CI/CD pipeline using **GitHub Actions** and **OIDC authentication** to deploy Terraform infrastructure securely.

### **Workflow Highlights**

- **Terraform Validate** – Checks syntax and module references on every push or pull request
- **Terraform Plan** – Generates an execution plan and outputs the changes
- **Terraform Apply** – Automatically applies changes when pushed to the main branch
- **GitHub OIDC** – Allows GitHub Actions to assume a temporary AWS role without storing long-lived AWS credentials
- **Environment Safety** – The pipeline runs in isolated workflows to prevent accidental changes in production

### **Benefits**

- Secure and credential-free AWS deployment
- Automated infrastructure provisioning
- Consistent environments across contributors
- Integration with branch-based workflow for safe changes

---

## Outputs

After deployment, the following AWS resources are available:

- **S3 Input Bucket** – Upload images here to trigger the pipeline.
- **DynamoDB Table** – Stores metadata for each processed image, including detected animals.
- **Lambda Function** – Automatically processes incoming images and publishes results.
- **CloudWatch Logs** – Provides detailed execution logs for debugging and traceability.
- **Custom CloudWatch Metrics** – Tracks the number of processed images, detected animals, and images with no detections.
- **CloudWatch Dashboard** – Centralized visualization of metrics for monitoring the pipeline.
- **CloudWatch Alarms** – Notify if no animals are detected or if errors occur in processing.
- **SQS Queue + DLQ** – Buffers events and handles failures in a decoupled way.

> Note: All outputs are fully provisioned and managed by Terraform. Lambda packaging is handled automatically; `lambda.zip` is generated during deployment and should not be committed to version control.

---

## Terraform Concepts Covered in This Project

This project demonstrates a wide range of practical skills that are highly valued in cloud and DevOps roles:

- **Serverless Architecture** – Event-driven design using Lambda, S3, EventBridge, and SQS
- **Infrastructure as Code** – Modular Terraform code, reusable and maintainable
- **Observability & Monitoring** – CloudWatch logs, custom metrics, dashboards, and alarms
- **Security Best Practices** – GitHub Actions OIDC for credential-free deployment
- **CI/CD Automation** – Fully automated validation, plan, and apply workflows
- **Production Awareness** – Error handling, DLQs, and metric-driven alerts

---
