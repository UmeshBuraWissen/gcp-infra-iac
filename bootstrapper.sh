#!/bin/bash
set -euo pipefail
clear
cat banner

# Load prerequisites and environment variables
ROOT_DIR=$(realpath "$(dirname "${BASH_SOURCE[0]}")")
source "$ROOT_DIR/workspace.ini" # Ensure this sets PROJECT_ID, BUCKET_NAME, GITHUB_PAT, BILLING_ACCOUNT_ID

# Configurable Variables
REGION=${REGION:-"us-central1"} # Default region
WORKSPACE=${WORKSPACE:-"core"}  # Default Terraform workspace

# Generate PROJECT_ID and BUCKET_NAME programmatically
PROJECT_ID="proj-${ENVIRONMENT}-${WORKLOAD}${SEQ}-${PROJECT_ID_SUFFIX}"
BUCKET_NAME="buck-tf-${ENVIRONMENT}-${WORKLOAD}${SEQ}"

export TF_VAR_github_pat="${GITHUB_PAT}"
export TF_VAR_project_id="${PROJECT_ID}"

# Print Initial Information
echo "============================================="
echo "ROOT_DIR: $ROOT_DIR"
echo "PROJECT_ID: $PROJECT_ID"
echo "BUCKET_NAME: $BUCKET_NAME"
echo "Region: $REGION"
echo "Workspace: $WORKSPACE"
echo "============================================="

# Function to check if gcloud is authenticated and a configuration is set
check_gcloud_config() {
    echo -e "\n### STEP: Checking Google Cloud authentication..."

    # Check if credentials.json is present in the root directory
    if [[ -f "$ROOT_DIR/credentials.json" ]]; then
        # Set GOOGLE_APPLICATION_CREDENTIALS to the full path of the credentials.json file
        gcloud auth login --cred-file="$ROOT_DIR/credentials.json" --quiet
        export GOOGLE_APPLICATION_CREDENTIALS="$ROOT_DIR/credentials.json"
        echo ">>> Using $GOOGLE_APPLICATION_CREDENTIALS"
    else
        echo ">>> No $ROOT_DIR/credentials.json found. Checking active gcloud authentication..."

        # Check for an active gcloud account
        local active_account
        active_account=$(gcloud auth list --filter="status:ACTIVE" --format="value(account)")

        if [[ -z "$active_account" ]]; then
            echo ">>> No active Google Cloud authentication found."
            echo ">>> Attempting to authenticate using 'gcloud auth login'..."
            gcloud auth login --update-adc
            if [[ $? -ne 0 ]]; then
                echo "!!! ERROR: Google Cloud authentication failed. Please try again."
                exit 1
            fi
            echo ">>> Authentication successful."
        else
            echo ">>> Authenticated as: $active_account"
        fi
    fi

    # Check the active gcloud configuration
    local active_config
    active_config=$(gcloud config configurations list --filter="IS_ACTIVE:true" --format="value(NAME)")

    if [[ -n "$active_config" ]]; then
        echo ">>> Active gcloud configuration: $active_config"
    else
        echo "!!! WARNING: No active gcloud configuration found. Ensure proper setup."
    fi
}

# Function: Validate project existence and create if necessary
validate_project() {
    echo -e "\n### STEP: Validating project existence..."

    if ! gcloud projects describe "$PROJECT_ID" &>/dev/null; then
        echo ">>> Project $PROJECT_ID does not exist."
        echo ">>> Creating project: $PROJECT_ID..."
        gcloud projects create "$PROJECT_ID" --name="$PROJECT_ID" --organization="$ORGANIZATION_ID" --set-as-default || {
            echo "!!! ERROR: Failed to create project $PROJECT_ID."
            exit 1
        }
        echo ">>> Project $PROJECT_ID created successfully."
    else
        echo ">>> Project $PROJECT_ID already exists."
    fi

    project_state=$(gcloud projects describe "$PROJECT_ID" --format="value(lifecycleState)")
    if [[ "$project_state" == "DELETE_REQUESTED" ]]; then
        echo "!!! ERROR: Project $PROJECT_ID is set for deletion. Exiting..."
        exit 1
    fi
}

# Function: Link billing account to project
link_billing_account() {
    echo -e "\n### STEP: Linking billing account to project..."

    billing_status=$(gcloud billing projects describe "$PROJECT_ID" --format="value(billingAccountName)" || true)

    if [[ -z "$billing_status" ]]; then
        echo ">>> No billing account linked to project."
        echo ">>> Linking billing account: $BILLING_ACCOUNT_ID..."
        gcloud billing projects link "$PROJECT_ID" --billing-account="$BILLING_ACCOUNT_ID" || {
            echo "!!! ERROR: Failed to link billing account $BILLING_ACCOUNT_ID."
            exit 1
        }
        echo ">>> Billing account linked successfully."
    else
        echo ">>> Billing account already linked to the project."
    fi
}

# Function: Check if the GCS bucket exists
validate_bucket_existence() {
    echo -e "\n### STEP: Validating GCS bucket existence..."

    bucket_url="gs://${BUCKET_NAME}"

    if gcloud storage buckets describe "$bucket_url" --project="$PROJECT_ID" &>/dev/null; then
        echo ">>> Bucket $BUCKET_NAME exists."
    else
        echo ">>> Bucket $BUCKET_NAME does not exist."
        echo ">>> Creating bucket: $BUCKET_NAME in region: $REGION..."
        gcloud storage buckets create "$bucket_url" --location="$REGION" --project="$PROJECT_ID" --uniform-bucket-level-access || {
            echo "!!! ERROR: Failed to create bucket $BUCKET_NAME."
            exit 1
        }
        echo ">>> Bucket $BUCKET_NAME created successfully."
    fi
}

# Function: Provision Terraform Core
provision_core() {
    echo -e "\n### STEP: Provisioning Terraform resources for workspace: $WORKSPACE..."

    cd "$ROOT_DIR"
    if [ ! -f ./run.sh ]; then
        echo "!!! ERROR: run.sh script not found in $ROOT_DIR."
        exit 1
    fi

    echo ">>> Initializing Terraform..."
    ./run.sh -w="$WORKSPACE" init || {
        echo "!!! ERROR: Terraform init failed."
        exit 1
    }
    echo ">>> Applying Terraform changes..."
    ./run.sh -w="$WORKSPACE" apply --auto-approve || {
        echo "!!! ERROR: Terraform apply failed."
        exit 1
    }
    echo ">>> Terraform provisioning completed successfully."
}

# Main Script Execution
main() {
    echo "============================================="
    echo ">>> Starting provisioning process for project: $PROJECT_ID"
    echo "============================================="

    # Check if gcloud is authenticated
    check_gcloud_config

    # Validate project existence and state
    validate_project

    # Link billing account if necessary
    link_billing_account

    # Check if bucket exists and create if necessary
    validate_bucket_existence

    # Provision core services using Terraform
    provision_core

    echo "============================================="
    echo ">>> Provisioning process completed successfully!"
    echo "============================================="
}

# Run the main function
main
