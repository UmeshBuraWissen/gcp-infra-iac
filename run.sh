#!/bin/bash

# Enable strict mode
set -euo pipefail

# Function to display usage information
usage() {
  echo "Usage: $0 -w=<workspace> <terraform_command>"
  echo "Example: $0 -w=core reset"
  echo "Example: $0 -w=core init"
  exit 1
}

# Load prerequisites and environment variables
ROOT_DIR=$(realpath "$(dirname "${BASH_SOURCE[0]}")")
source "$ROOT_DIR/workspace.ini" # Ensure this sets PROJECT_ID, BUCKET_NAME, GITHUB_PAT, BILLING_ACCOUNT_ID

# Generate PROJECT_ID and BUCKET_NAME programmatically
PROJECT_ID="proj-${ENVIRONMENT}-${WORKLOAD}${SEQ}-${PROJECT_ID_SUFFIX}"
BUCKET_NAME="buck-tf-${ENVIRONMENT}-${WORKLOAD}${SEQ}"

export TF_VAR_github_pat="${GITHUB_PAT}"
export TF_VAR_project_id="${PROJECT_ID}"

# Check if credentials.json is present in the root directory
if [[ -f "$ROOT_DIR/credentials.json" ]]; then
  # Set GOOGLE_APPLICATION_CREDENTIALS to the full path of the credentials.json file
  export GOOGLE_APPLICATION_CREDENTIALS="$ROOT_DIR/credentials.json"
  echo ">>> Using $GOOGLE_APPLICATION_CREDENTIALS"
fi

# Function to clean up Terraform-related files in a given directory
reset() {
  TARGET_DIR="$1" # Workspace directory, properly quoted

  echo "Cleaning up Terraform-related files and directories in: $TARGET_DIR"

  # Remove directories and files matching the specified patterns
  find "$TARGET_DIR" -type d -name ".terraform" -prune -exec rm -rf "{}" + # Remove .terraform directories
  find "$TARGET_DIR" -type d -name ".local" -prune -exec rm -rf "{}" +     # Remove .local directories
  find "$TARGET_DIR" -type f \( \
    -name "*.tfstate" -o \
    -name "*.tfstate.*" -o \
    -name "crash.log" -o \
    -name "crash.*.log" -o \
    -name "*.tfvars.json" -o \
    -name "override.tf" -o \
    -name "override.tf.json" -o \
    -name "*_override.tf" -o \
    -name "*_override.tf.json" -o \
    -name ".terraform.tfstate.lock.info" -o \
    -name ".terraform.lock.hcl" -o \
    -name ".terraformrc" -o \
    -name "terraform.rc" \
    \) -exec rm -f "{}" +

  terraform fmt -recursive "$TARGET_DIR"
  echo "Cleanup completed."
}

# Parse arguments
if [[ "$#" -lt 1 ]]; then
  usage
fi

ROOT_DIR=$(realpath "$(dirname "${BASH_SOURCE[0]}")")
source "$ROOT_DIR/workspace.ini"

# Initialize variables
WORKSPACE=""
COMMAND=""

# Loop through the arguments
for ARG in "$@"; do
  case $ARG in
  -w=* | --workspace=*)
    WORKSPACE="${ARG#*=}" # Extract the workspace value
    ;;
  *)
    COMMAND="$COMMAND $ARG" # Collect the terraform command
    ;;
  esac
done

# Handle "reset" command
if [[ "$COMMAND" == " reset" ]]; then
  if [[ -n "$WORKSPACE" ]]; then
    ROOT_DIR="$(pwd)"
    WORKSPACE_PATH="$ROOT_DIR/workspace/$WORKSPACE"
    if [[ -d "$WORKSPACE_PATH" ]]; then
      reset "$WORKSPACE_PATH"
    else
      echo "Error: Workspace directory does not exist: $WORKSPACE_PATH"
      exit 1
    fi
  else
    echo "Error: The reset command requires a workspace (-w) to be specified."
    usage
  fi
  exit
fi

# Validate workspace
if [[ -z "$WORKSPACE" ]]; then
  echo "Error: Workspace (-w) is required."
  usage
fi

ROOT_DIR="$(pwd)"
WORKSPACE_PATH="$ROOT_DIR/workspace/$WORKSPACE"

# Check if the command is "init"
if [[ "$COMMAND" == " init" ]]; then
  reset "$WORKSPACE_PATH" # Cleanup specific workspace before init
  TEMP_DIR="$ROOT_DIR/workspace/.local"
  rm -rf "$TEMP_DIR"
  mkdir -p "$TEMP_DIR"

  cp "$WORKSPACE_PATH/main.tf" "$WORKSPACE_PATH/import.tf" "$WORKSPACE_PATH/variables.tf" "$WORKSPACE_PATH/variables.auto.tfvars" "$TEMP_DIR/"

  terraform -chdir="$TEMP_DIR" init -backend=false
  terraform -chdir="$TEMP_DIR" apply --auto-approve

  cp -f "$TEMP_DIR/auth.tf" "$WORKSPACE_PATH/"
  rm -rf "$TEMP_DIR"
fi

# gcloud config set project $PROJECT_ID
terraform -chdir="$WORKSPACE_PATH" $COMMAND
