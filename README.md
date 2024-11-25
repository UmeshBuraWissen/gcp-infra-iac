# gcp-infra-iac
Prerequisites:

Terraform v1.9.8
Python 3.12.3
Google Cloud SDK 501.0.0

Roles required at org:
Billing Account User
Project Creator


Flow:
1. local script 
    a. will create project, backend bucket if not exists
        - ask metadata, project unique id to user
        - using naming convention
            - project name = metadata + unique id
            - bucket name
            - github pat
            
    b. keep data block for project in core
    c. run terraform for core layer
        1. enable required services
        2. service account
        3. artifact registry 
        4. cloudbuild


2. pipeline
    a. cloudbuild for services terraform folder
        1. cloudrun with base image
        2. cloudsql
        3. secrets
        4. vpc connector
        5. firewall
    b. build and deploy image in artifact and deploy on cloudrun


destroy

Steps:

1. Check prerequisites for packages and roles on gcp
2. gcloud auth login --update-adc
3.  Add values for variables in workspace.sh
    - change suffix for project
    - add github pat
4. run "./bootstrapper.sh" to bootstrap project, state bucket and core folder
5. go to cloud build and run pipeline to provision infra
6. go to cloud build and run pipeline for docker image build and deploy it to cloudrun
