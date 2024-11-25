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

# Cleanup resources
echo "Deleting bucket: $BUCKET_NAME"
if gsutil ls -b "gs://${BUCKET_NAME}" >/dev/null 2>&1; then
    gsutil rm -r "gs://${BUCKET_NAME}"
    echo "Bucket ${BUCKET_NAME} deleted successfully."
else
    echo "Bucket ${BUCKET_NAME} does not exist or is already deleted."
fi

echo "Deleting project: $PROJECT_ID"
if gcloud projects describe "$PROJECT_ID" >/dev/null 2>&1; then
    gcloud projects delete "$PROJECT_ID" --quiet
    echo "Project ${PROJECT_ID} deleted successfully."
else
    echo "Project ${PROJECT_ID} does not exist or is already deleted."
fi
