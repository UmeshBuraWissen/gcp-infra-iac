#!/bin/bash
set -euo pipefail

ROOT_DIR=$(realpath "$(dirname "${BASH_SOURCE[0]}")")
source "$ROOT_DIR/workspace.sh"

# Function to destroy resources and delete bucket/project
destroy() {
    WORKSPACE=$1
    WORKSPACE_PATH="workspace/$WORKSPACE"
    ROOT_DIR=$(realpath "$(dirname "${BASH_SOURCE[0]}")")

    cd "$ROOT_DIR"

    echo "Running terraform init on $WORKSPACE_PATH"
    echo "------------------------------------------------------"
    export TF_VAR_github_pat="${GITHUB_PAT}"
    export TF_VAR_project_id="${PROJECT_ID}"

    # Initialize and destroy resources
    ./run.sh -w="$WORKSPACE" init

    echo "Running terraform destroy on $WORKSPACE_PATH"
    echo "------------------------------------------------------"
    ./run.sh -w="$WORKSPACE" destroy # --auto-approve
}

# Destroy resources for specified workspaces
destroy "services"
destroy "core"

# Normalize the bucket name to include the gs:// prefix
BUCKET_URL="gs://${BUCKET_NAME}"

# Deleting bucket
echo "Deleting bucket: $BUCKET_URL"
if gcloud storage buckets describe "$BUCKET_URL" --project="$PROJECT_ID" >/dev/null 2>&1; then
    gcloud storage rm -r "$BUCKET_URL" --project="$PROJECT_ID" --quiet
    echo "Bucket ${BUCKET_URL} deleted successfully."
else
    echo "Bucket ${BUCKET_URL} does not exist or is already deleted."
fi

# Deleting project
echo "Deleting project: $PROJECT_ID"
if gcloud projects describe "$PROJECT_ID" >/dev/null 2>&1; then
    gcloud projects delete "$PROJECT_ID" --quiet
    echo "Project ${PROJECT_ID} deleted successfully."
else
    echo "Project ${PROJECT_ID} does not exist or is already deleted."
fi