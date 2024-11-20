PROJECT_ID="proj-dev-demo000-gbjy" # Replace with your actual project ID
BUCKET_NAME="buck-tf-dev-demo000"

initialize_backend() {
    WORKSPACE=${1:-"core"} # Default workspace is 'core'
    WORKSPACE_PATH="workspace/$WORKSPACE"
    ROOT_DIR=$(pwd)

    # Check if the project exists using gcloud
    gcloud projects describe "$PROJECT_ID" &>/dev/null
    if [ $? -ne 0 ]; then
        echo "Project $PROJECT_ID does not exist. Creating it..."
        gcloud projects create "$PROJECT_ID"
        echo "Project $PROJECT_ID created successfully."
    else
        echo "Project $PROJECT_ID already exists."
    fi

    echo "----------------------------------------------------------------------------------------"
    # Run terraform init to configure the backend and create auth.tf in temp directory (.local)
    echo "Generating auth.tf for $WORKSPACE_PATH"
    TEMP_DIR="$ROOT_DIR/workspace/.local"
    rm -rf "$TEMP_DIR"
    mkdir -p "$TEMP_DIR"
    cp $WORKSPACE_PATH/main.tf $WORKSPACE_PATH/variables.tf $WORKSPACE_PATH/variables.auto.tfvars "$TEMP_DIR/"
    terraform -chdir="$TEMP_DIR" init -backend=false
    terraform -chdir="$TEMP_DIR" apply --auto-approve
    cp -f $TEMP_DIR/auth.tf "$WORKSPACE_PATH/"
    rm -rf "$TEMP_DIR"

    # Change to the specified workspace directory
    cd "$WORKSPACE_PATH" || {
        echo "Error: Workspace directory $WORKSPACE_PATH does not exist."
        exit 1
    }

    # Extract the GCS bucket name from auth.tf
    BUCKET_NAME=$(grep -oP 'bucket\s*=\s*"\K[^"]+' "auth.tf")
    echo "-----------------------------------"
    echo "Bucket name - $BUCKET_NAME"

    # Check if the GCS bucket exists
    if gcloud storage buckets describe "gs://$BUCKET_NAME" &>/dev/null; then
        echo "Bucket $BUCKET_NAME exists. Using remote backend."
    else
        echo "Bucket $BUCKET_NAME does not exist. Creating bucket and using gcloud."

        # Create the bucket if it doesn't exist
        gcloud storage buckets create "gs://$BUCKET_NAME" --location=US # You can specify your region here

        echo "Bucket $BUCKET_NAME created successfully."
    fi

    echo "Backend setup completed."
}

initialize_backend
