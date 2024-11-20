#!/bin/bash

# Function to display usage information
usage() {
  echo "Usage: $0 -w=<workspace> <terraform_command>"
  echo "Example: $0 reset"
  echo "Example: $0 -w=core init"
  exit 1
}

reset() {
  ROOT_DIR=${1:-$(pwd)} # Use the provided root directory or the current directory by default

  echo "Cleaning up Terraform-related files and directories in: $ROOT_DIR"

  # Remove directories and files matching the specified patterns
  find "$ROOT_DIR" -type d -name ".terraform" -prune -exec rm -rf {} + # Remove .terraform directories
  find "$ROOT_DIR" -type d -name ".local" -prune -exec rm -rf {} +     # Remove .local directories
  find "$ROOT_DIR" -type f \( \
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
    \) -exec rm -f {} +

  terraform fmt -recursive
  echo "Cleanup completed."
}

# Parse arguments
if [[ "$#" -lt 1 ]]; then
  usage
fi

# Initialize variables
WORKSPACE=""
COMMAND=""

# Loop through the arguments
for ARG in "$@"; do
  case $ARG in
  -w=*)
    WORKSPACE="${ARG#*=}" # Extract the workspace value
    ;;
  *)
    COMMAND="$COMMAND $ARG" # Collect the terraform command
    ;;
  esac
done

if [[ "$COMMAND" == " reset" ]]; then
  reset
  exit
fi

# Validate workspace
if [[ -z "$WORKSPACE" ]]; then
  echo "Error: Workspace (-w) is required."
  usage
fi

ROOT_DIR=$(pwd)
WORKSPACE_PATH="$ROOT_DIR/workspace/$WORKSPACE"

# Check if the command is "init"
if [[ "$COMMAND" == " init" ]]; then
  reset
  TEMP_DIR="$ROOT_DIR/workspace/.local"
  rm -rf "$TEMP_DIR"
  mkdir -p "$TEMP_DIR"

  cp $WORKSPACE_PATH/main.tf $WORKSPACE_PATH/variables.tf $WORKSPACE_PATH/variables.auto.tfvars "$TEMP_DIR/"

  terraform -chdir="$TEMP_DIR" init -backend=false
  terraform -chdir="$TEMP_DIR" apply --auto-approve

  cp -f $TEMP_DIR/auth.tf "$WORKSPACE_PATH/"
  rm -rf "$TEMP_DIR"
fi

terraform -chdir="$WORKSPACE_PATH" $COMMAND
