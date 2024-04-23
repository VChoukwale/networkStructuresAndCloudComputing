# terraform

# CSYE 6225 Spring 2024
## Name : Vaishnavi Choukwale  NEUID : 002816622

### Overview

This Terraform project creates a Virtual Private Cloud (VPC) and two subnets in Google Cloud Platform (GCP).

### Prerequisites

- Install Terraform: [Terraform Installation Guide](https://learn.hashicorp.com/tutorials/terraform/install-cli)
- Google Cloud Platform account and credentials

### Enable Compute Engine API for new project

To use the Compute Engine API, you need to enable it for your project. Follow these steps:
    1. Open the Google Cloud Console: [https://console.cloud.google.com/](https://console.cloud.google.com/).
    2. Create new project
    3. Click on continue button when the dialogue box pop up to load the data for new project
    4. Click the "Enable" button for Compute Engine Api for respective project.
    5. Wait for the API to be enabled (this may take 10-15 minutes).
    6. Start working on project once the API is enabled

### To setup and run application 
    1. Clone the orignization repository
    2. cd to the cloned repository
    3. Initialize terraform using - terraform init
    4. To check terraform changes before applyig - terrafor plan
    5. To apply terraform configurations - terraform apply
    6. To remove created resources - terraform destroy


