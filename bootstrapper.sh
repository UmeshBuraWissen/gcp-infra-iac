#!/bin/bash
set -euo pipefail

ROOT_DIR=$(realpath "$(dirname "${BASH_SOURCE[0]}")")
source "$ROOT_DIR/workspace.sh"

# Print the results
echo "Generated PROJECT_ID: $PROJECT_ID"
echo "Generated BUCKET_NAME: $BUCKET_NAME"

bootstrap_project() {
    # Check if the project exists using gcloud
    # Check if the project exists and create it if necessary
    gcloud projects describe "$PROJECT_ID" &>/dev/null
    if [ $? -ne 0 ]; then
        echo "Project $PROJECT_ID does not exist or you do not have permission to access it."

        # Attempt to create the project
        echo "Attempting to create project $PROJECT_ID..."
        if gcloud projects create "$PROJECT_ID"; then
            gcloud config set project $PROJECT_ID
            gcloud billing projects link $PROJECT_ID --billing-account=$BILLING_ACCOUNT_ID
            echo "Project $PROJECT_ID created successfully."
        else
            echo "Failed to create project $PROJECT_ID. Ensure you have the necessary permissions."
            echo "You may need 'resourcemanager.projects.create' permissions on your account."
            exit 1
        fi
    else
        echo "Project $PROJECT_ID already exists."
    fi

    echo "-----------------------------------"
    echo "Bucket name - $BUCKET_NAME"

    # Check if the GCS bucket exists
    if gcloud storage buckets describe "gs://$BUCKET_NAME" --project=$PROJECT_ID &>/dev/null; then
        echo "Bucket $BUCKET_NAME exists. Using remote backend."
    else
        echo "Bucket $BUCKET_NAME does not exist. Creating bucket and using gcloud."

        # Create the bucket if it doesn't exist
        gcloud storage buckets create "gs://$BUCKET_NAME" --location=US --project=$PROJECT_ID # You can specify your region here

        echo "Bucket $BUCKET_NAME created successfully."
    fi

    gcloud config set project $PROJECT_ID

    echo "-----------------------------------"
    echo "Project Bootrapping completed."
    echo "-----------------------------------"
}

provision_core() {
    WORKSPACE=${1:-"core"} # Default workspace is 'core'
    WORKSPACE_PATH="workspace/$WORKSPACE"

    ROOT_DIR=$(realpath "$(dirname "${BASH_SOURCE[0]}")")

    cd $ROOT_DIR
    export TF_VAR_github_pat="${GITHUB_PAT}"
    export TF_VAR_project_id="${PROJECT_ID}"

    ./run.sh -w=core init
    ./run.sh -w=core apply --auto-approve
}

bootstrap_project
provision_core
