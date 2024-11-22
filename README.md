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
    b. keep data block for project and backend bucket in core
    c. run terraform for core layer
        1. enable required services
        2. service account
        3. artifact registry (can be moved to devops)
        4. vpc
    d. run terraform for devops
        1. cloudbuild

2. pipeline
    a. cloudbuild for services terraform folder
        1. cloudrun with base image
        2. cloudsql
        3. secrets
        4. vpc connector
        5. firewall
    b. build and deploy image in artifact and deploy on cloudrun


destroy
