#!/bin/bash
set -euo pipefail

# Load prerequisites and environment variables
ROOT_DIR=$(realpath "$(dirname "${BASH_SOURCE[0]}")")
source "$ROOT_DIR/workspace.sh" # Ensure this sets PROJECT_ID, BUCKET_NAME, and GITHUB_PAT

# Function to check if gcloud is authenticated and a configuration is set
check_gcloud_config() {
    # Check if there is an active authenticated account
    local active_account
    active_account=$(gcloud auth list --filter="status:ACTIVE" --format="value(account)")

    if [[ -z "$active_account" ]]; then
        echo "Error: No active gcloud authentication found."
        echo "Attempting to authenticate using 'gcloud auth login'..."
        gcloud auth login --update-adc
        if [ $? -ne 0 ]; then
            echo "Error: Authentication failed. Please try again."
            exit 1
        fi
        echo "Authentication successful."
        return
    fi

    # Print the active account and configuration
    echo "Authenticated as: $active_account"
    local active_config
    active_config=$(gcloud config configurations list --filter="IS_ACTIVE:true" --format="value(NAME)")
    if [[ -n "$active_config" ]]; then
        echo "Active gcloud configuration: $active_config"
    else
        echo "Warning: No active gcloud configuration found. You might need to set it up manually."
    fi
}

# Function: Validate the project lifecycle state
validate_project_state() {
    local project_id="$1"
    echo "Validating lifecycle state of project: $project_id..."
    lifecycle_state=$(gcloud projects describe "$project_id" --format="value(lifecycleState)" 2>/dev/null || true)

    if [[ -z "$lifecycle_state" ]]; then
        echo "Error: Project $project_id does not exist or cannot be accessed."
        exit 1
    fi

    case "$lifecycle_state" in
        ACTIVE)
            echo "Project $project_id is ACTIVE. Proceeding with cleanup."
            ;;
        DELETE_REQUESTED)
            echo "Project $project_id is scheduled for deletion. No further actions required."
            exit 0
            ;;
        *)
            echo "Unexpected lifecycle state: $lifecycle_state. Exiting."
            exit 1
            ;;
    esac
}

# Function: Check if the GCS bucket exists
validate_bucket_existence() {
    local bucket_name="$1"
    local bucket_url="gs://${bucket_name}"
    echo "Checking if bucket: $bucket_url exists..."

    if gcloud storage buckets describe "$bucket_name" --project="$PROJECT_ID" >/dev/null 2>&1; then
        echo "Bucket $bucket_url exists. Proceeding with cleanup."
    else
        echo "Error: Bucket $bucket_url does not exist. Exiting script."
        exit 0
    fi
}

# Function: Delete GCS bucket and its contents
delete_bucket() {
    local bucket_name="$1"
    local bucket_url="gs://${bucket_name}"
    echo "Deleting bucket: $bucket_url..."

    if gcloud storage buckets describe "$bucket_name" --project="$PROJECT_ID" >/dev/null 2>&1; then
        echo "Bucket $bucket_url exists. Deleting contents and bucket..."
        gcloud storage rm -r "$bucket_url" --project="$PROJECT_ID" --quiet || {
            echo "Error: Failed to delete bucket $bucket_url."
            exit 1
        }
        echo "Bucket $bucket_url and its contents deleted successfully."
    else
        echo "Bucket $bucket_url does not exist or has already been deleted."
    fi
}

# Function: Destroy Terraform resources for a workspace
destroy_terraform_resources() {
    local workspace="$1"
    echo "Starting Terraform resource cleanup for workspace: $workspace..."
    export TF_VAR_github_pat="${GITHUB_PAT}"
    export TF_VAR_project_id="${PROJECT_ID}"

    cd "$ROOT_DIR"

    if ! ./run.sh -w="$workspace" init; then
        echo "Error: Terraform init failed for workspace: $workspace."
        exit 1
    fi

    if ! ./run.sh -w="$workspace" destroy --auto-approve; then
        echo "Error: Terraform destroy failed for workspace: $workspace."
        exit 1
    fi
    echo "Terraform resources destroyed for workspace: $workspace."
}

# Function: Delete the GCP project
delete_project() {
    local project_id="$1"
    echo "Deleting project: $project_id..."
    if gcloud projects describe "$project_id" >/dev/null 2>&1; then
        gcloud projects delete "$project_id" --quiet || {
            echo "Error: Failed to delete project $project_id."
            exit 1
        }
        echo "Project $project_id deleted successfully."
    else
        echo "Project $project_id does not exist or has already been deleted."
    fi
}

# Main Script Execution
main() {
    echo "---------------------------------------------"
    echo "Starting cleanup process for project: $PROJECT_ID"
    echo "---------------------------------------------"

    # Check if gcloud is authenticated
    check_gcloud_config

    # Validate project state
    validate_project_state "$PROJECT_ID"

    # Check bucket existence
    if ! gcloud storage buckets describe "$BUCKET_NAME" --project="$PROJECT_ID" >/dev/null 2>&1; then
        echo "Bucket $BUCKET_NAME does not exist. Proceeding to delete the project."
        delete_project "$PROJECT_ID"
        exit 0
    fi

    # If bucket exists, proceed with cleanup
    echo "Bucket $BUCKET_NAME exists. Proceeding with resource cleanup."
    destroy_terraform_resources "services"
    destroy_terraform_resources "core"

    echo "Deleting GCS bucket..."
    delete_bucket "$BUCKET_NAME"

    echo "Deleting GCP project..."
    delete_project "$PROJECT_ID"

    echo "---------------------------------------------"
    echo "Cleanup process completed successfully!"
    echo "---------------------------------------------"
}

# Run the main function
main
