#!/bin/bash
set -euo pipefail
clear
cat banner

# Load prerequisites and environment variables
ROOT_DIR=$(realpath "$(dirname "${BASH_SOURCE[0]}")")
source "$ROOT_DIR/workspace.ini" # Ensure this sets PROJECT_ID, BUCKET_NAME, and GITHUB_PAT

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
echo "============================================="

# Function to check if gcloud is authenticated and a configuration is set
check_gcloud_config() {
    echo -e "\n### STEP: Checking Google Cloud authentication..."

    # Check if credentials.json is present in the root directory
    if [[ -f "$ROOT_DIR/credentials.json" ]]; then
        # Set GOOGLE_APPLICATION_CREDENTIALS to the full path of the credentials.json file
        gcloud auth login --cred-file="$ROOT_DIR/credentials.json"
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

# Function to validate project existence
validate_project_existence() {
    echo -e "\n### STEP: Validating project existence..."

    if ! gcloud projects describe "$PROJECT_ID" &>/dev/null; then
        echo "!!! ERROR: Project $PROJECT_ID does not exist. Exiting."
        exit 1
    fi
    echo ">>> Project $PROJECT_ID exists."
}

# Function to validate the project lifecycle state
validate_project_state() {
    local project_id="$1"
    echo -e "\n### STEP: Validating lifecycle state of project: $project_id..."
    local lifecycle_state
    lifecycle_state=$(gcloud projects describe "$project_id" --format="value(lifecycleState)" 2>/dev/null || true)

    if [[ -z "$lifecycle_state" ]]; then
        echo "!!! ERROR: Project $project_id does not exist or cannot be accessed."
        exit 1
    fi

    case "$lifecycle_state" in
    ACTIVE)
        echo ">>> Project $project_id is ACTIVE. Proceeding with cleanup."
        ;;
    DELETE_REQUESTED)
        echo "!!! WARNING: Project $project_id is scheduled for deletion. Exiting."
        exit 0
        ;;
    *)
        echo "!!! ERROR: Unexpected lifecycle state: $lifecycle_state. Exiting."
        exit 1
        ;;
    esac
}

# Function: Check if the GCS bucket exists
validate_bucket_existence() {
    local bucket_url="gs://${BUCKET_NAME}"
    echo -e "\n### STEP: Checking if bucket: $bucket_url exists..."

    if ! gcloud storage buckets describe "$bucket_url" --project="$PROJECT_ID" >/dev/null 2>&1; then
        echo ">>> Bucket $bucket_url does not exist. Proceeding with project deletion."
        return 0
    fi
    echo ">>> Bucket $bucket_url exists. Cleanup required."
    return 1
}

# Function: Delete GCS bucket and its contents
delete_bucket() {
    local bucket_url="gs://${BUCKET_NAME}"
    echo -e "\n### STEP: Deleting bucket: $bucket_url..."

    gcloud storage rm -r "$bucket_url" --project="$PROJECT_ID" --quiet || {
        echo "!!! ERROR: Failed to delete bucket $bucket_url."
        exit 1
    }
    echo ">>> Bucket $bucket_url and its contents deleted successfully."
}

# Function: Destroy Terraform resources for a workspace
destroy_terraform_resources() {
    local workspace="$1"
    echo -e "\n### STEP: Cleaning up Terraform resources for workspace: $workspace..."

    export TF_VAR_github_pat="${GITHUB_PAT}"
    export TF_VAR_project_id="${PROJECT_ID}"

    cd "$ROOT_DIR"

    if ! ./run.sh -w="$workspace" init; then
        echo "!!! ERROR: Terraform init failed for workspace: $workspace."
        exit 1
    fi

    if ! ./run.sh -w="$workspace" destroy --auto-approve; then
        echo "!!! ERROR: Terraform destroy failed for workspace: $workspace."
        exit 1
    fi
    echo ">>> Terraform resources destroyed for workspace: $workspace."
}

# Function: Delete the GCP project
delete_project() {
    local project_id="$1"
    echo -e "\n### STEP: Deleting project: $project_id..."
    if gcloud projects describe "$project_id" >/dev/null 2>&1; then
        gcloud projects delete "$project_id" --quiet || {
            echo "!!! ERROR: Failed to delete project $project_id."
            exit 1
        }
        echo ">>> Project $project_id deleted successfully."
    else
        echo ">>> Project $project_id does not exist or has already been deleted."
    fi
}

# Main Script Execution
main() {
    echo "============================================="
    echo ">>> Starting cleanup process for project: $PROJECT_ID"
    echo "============================================="

    # Check if gcloud is authenticated
    check_gcloud_config

    # Validate project existence
    validate_project_existence

    # Validate project state (active or deletion requested)
    validate_project_state "$PROJECT_ID"

    # Validate bucket existence and proceed with cleanup if necessary
    if ! validate_bucket_existence; then
        # Destroy Terraform resources if the bucket exists
        for workspace in "services" "core"; do
            destroy_terraform_resources "$workspace"
        done

        # Delete the GCS bucket
        delete_bucket
    fi

    # Delete the GCP project
    delete_project "$PROJECT_ID"

    echo "============================================="
    echo ">>> Cleanup process completed successfully!"
    echo "============================================="
}

# Run the main function
main
