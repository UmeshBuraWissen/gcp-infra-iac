
# GCP Infrastructure Automation and Deployment

## Overview

This guide covers the complete process of automating infrastructure provisioning and application deployment on Google Cloud Platform (GCP) using Terraform, Cloud Build, and Cloud Run.

### Prerequisites

Before you begin, ensure the following tools and roles are available:

#### Tools:
- **Terraform** v1.9.8
- **Python** 3.12.3
- **Google Cloud SDK** v501.0.0

#### GCP Roles Required at the Organization Level:
- **Billing Account User**
- **Project Creator**

## Workflow Overview

This workflow consists of two main stages:
1. **Local Script:**
   - Creates a new GCP project, backend bucket (if not already existing).
   - Runs Terraform to provision core infrastructure resources.
   - Sets up required metadata and project configuration.

2. **Pipeline:**
   - Uses Cloud Build to provision infrastructure for Cloud Run, Cloud SQL, and other required resources.
   - Builds and deploys a Docker image to Cloud Run.

## Steps to Bootstrap and Deploy the Infrastructure

### Step 1: Authenticate with GCP

1. **Authenticate gcloud CLI**  
   Run the following command to log in and update application default credentials:
   ```bash
   gcloud auth login --update-adc
   ```

2. **Update `workspace.sh` Configuration**  
   In the `workspace.sh` file, set the following parameters:
   - `PROJECT_ID_SUFFIX="aaaa"` # Ensure this is unique for each run
   - `GITHUB_PAT="xxx"` # Provide your GitHub Personal Access Token

### Step 2: Bootstrap the Project

1. **Run the Bootstrap Script**  
   Execute the following command in your terminal:
   ```bash
   ./bootstrapper.sh
   ```
   After running `bootstrapper.sh`, the following GCP resources will be created:

#### Resources Created Using `gcloud` Commands:
- **GCP Project** (e.g., `proj-dev-demo000-aaaa`): A new GCP project will be created.
- **GCP Storage Bucket**: A GCS bucket will be created to store the backend state.
  - **Bucket URL:** [Console URL](https://console.cloud.google.com/storage/browser?project=proj-dev-demo000-aaaa)

#### Resources Created Using Terraform in the `/workspace/core` Folder:
- **GCP Service Account**: A service account will be created and assigned necessary roles.
  - **Service Account Console URL:** [Console URL](https://console.cloud.google.com/iam-admin/serviceaccounts?referrer=search&authuser=2&project=proj-dev-demo000-aaaa)
- **GCP Storage Log Bucket**: A storage bucket for logs will be created.
  - **Log Bucket Console URL:** [Console URL](https://console.cloud.google.com/storage/browser?project=proj-dev-demo000-aaaa)
- **GCP Cloud Build Github Connection**: A connection to GitHub for infrastructure pipeline.
  - **GitHub Connection Console URL:** [Console URL](https://console.cloud.google.com/cloud-build/repositories/2nd-gen?inv=1&invt=Abia9Q&project=proj-dev-demo000-aaaa)
- **GCP Cloud Build Trigger for Infra Pipeline**: A Cloud Build trigger for the infra pipeline.
  - **Cloud Build Trigger URL:** [Console URL](https://console.cloud.google.com/cloud-build/triggers;region=us-central1?inv=1&invt=Abia9Q&project=proj-dev-demo000-aaaa)
- **GCP Artifact Registry**: An Artifact Registry to store application code images.
  - **Artifact Registry Console URL:** [Console URL](https://console.cloud.google.com/artifacts?referrer=search&authuser=2&inv=1&invt=Abia9Q&project=proj-dev-demo000-aaaa)

### Step 3: Run the Cloud Build Infrastructure Pipeline

1. **Navigate to Cloud Build Console**  
   Go to the following Cloud Build page to start the infrastructure pipeline:
   - **Cloud Build Trigger URL:** [Console URL](https://console.cloud.google.com/cloud-build/triggers;region=us-central1?authuser=2&invt=Abia9Q&project=proj-dev-demo000-aaaa)
   - **Cloud Build Logs:** [Console URL](https://console.cloud.google.com/cloud-build/builds;region=us-central1?authuser=2&invt=Abia9Q&project=proj-dev-demo000-aaaa)

2. **Resources Created After Running Infra Pipeline**:
   - **GCP Service Account for Application Deployment:** A service account to manage deployments.
     - **Console URL:** [Console URL](https://console.cloud.google.com/iam-admin/serviceaccounts?referrer=search&authuser=2&project=proj-dev-demo000-aaaa)
   - **GCP VPC Network**: A VPC network will be created.
     - **VPC Network Console URL:** [Console URL](https://console.cloud.google.com/networking/networks/list?referrer=search&authuser=2&project=proj-dev-demo000-aaaa)
   - **Cloud SQL Instance**: A MySQL instance for the application will be created.
     - **Cloud SQL Console URL:** [Console URL](https://console.cloud.google.com/sql/instances?referrer=search&authuser=2&project=proj-dev-demo000-aaaa)
   - **Cloud Run**: The Cloud Run service for the application will be created.
     - **Cloud Run Console URL:** [Console URL](https://console.cloud.google.com/run?referrer=search&authuser=2&project=proj-dev-demo000-aaaa)

### Step 4: Deploy Application to Cloud Run

1. **Run the Application Deployment Pipeline**  
   Once the infrastructure pipeline has completed, you can run the application deployment pipeline using Cloud Build to deploy a Node.js application to Cloud Run:
   - **Pipeline will:**
     1. Build and push a Docker image of the Node.js application to Artifact Registry.
     2. Deploy the application as a Cloud Run service.
     3. Set up the Cloud SQL database and tables as part of the image deployment.

### Step 5: Access the Deployed Application

1. **Cloud Run URL**  
   After the deployment completes, the application will be accessible via the default URL generated by Cloud Run:
   - **Base URL:** [Cloud Run Console URL](https://console.cloud.google.com/run?referrer=search&authuser=2&project=proj-dev-demo000-aaaa&inv=1&invt=Abia9Q)

## Troubleshooting

- **Authentication Issues**: Ensure that you are authenticated properly by running `gcloud auth login` or `gcloud auth application-default login` if needed.
- **Missing Permissions**: Verify that the correct roles are assigned to your account (Billing Account User and Project Creator).
- **Pipeline Failures**: If the Cloud Build pipelines fail, review the logs in the Cloud Build console for detailed error messages.

## Cleanup

If you need to clean up the created resources:

1. **Run Terraform Destroy**: Use `terraform destroy` to delete resources provisioned by Terraform.
2. **Delete GCP Project**: Once the resources are destroyed, the project can be deleted using `gcloud projects delete`.

---

**Note:** Make sure to update the `PROJECT_ID_SUFFIX` and `GITHUB_PAT` for each run to ensure uniqueness and proper access to GitHub repositories.
