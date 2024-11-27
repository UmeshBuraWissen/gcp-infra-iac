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
3.  Add values for variables in workspace.ini
    - change suffix for project
    - add github pat
4. run "./bootstrapper.sh" to bootstrap project, state bucket and core folder
5. go to cloud build and run pipeline to provision infra
6. go to cloud build and run pipeline for docker image build and deploy it to cloudrun


// 25-Nov-2024

END To END GCP Automation Steps:

Step 1: If we want to run terraform script using service account, add the 'credentials.json' in the root directory. Otherwise script will run using active account or else it will prompt user to login.

Step 2: Create a copy of this 'workspace_template.ini' file in root directory and name it "workspace.ini".

Step 3: In workspace.ini update below two parameters:

            1. PROJECT_ID_SUFFIX="aaaa" # Has to be unique
            2. GITHUB_PAT="xxx"
            3. ORGANIZATION_ID="501043380274"
            4. BILLING_ACCOUNT_ID="01CE4F-F5D80F-4EF741"

Step 4: Run './bootstrapper.sh' in VSCode editor in the ouput terminal
After running './bootstrapper.sh' below GCP resources are created:

    The below GCP resoureces will created using gcloud commands:
        1. GCP PROJECT(proj-dev-demo000-aaaa)  # the suffix 'aaaa' will be updated during every run
        2. GCP Storage Bucket For gcs backend
                GCP Storage Bucket Console URL: https://console.cloud.google.com/storage/browser?project=proj-dev-demo000-aaaa
    
    The below GCP resoureces will created from '/workspace/core' folder using Terraform 
    auth.tf will be created after running './bootstrapper.sh' command which is used for providers and backend.
        1. GCP Service Account With Role
                GCP Sercice Account Console URL: https://console.cloud.google.com/iam-admin/serviceaccounts?referrer=search&authuser=2&project=proj-dev-demo000-aaaa
        2. GCP Storage Log Bucket
                GCP Storage Log Bucket Console URL: https://console.cloud.google.com/storage/browser?project=proj-dev-demo000-aaaa
        3. GCP Cloud Build Github Connection For Infra Pipeline
                GCP Cloud Build Github Connection Console URL: https://console.cloud.google.com/cloud-build/repositories/2nd-gen?inv=1&invt=Abia9Q&project=proj-dev-demo000-aaaa
        4. GCP Cloud Build Trigger For Infra Pipeline
                GCP Cloud Build Trigger URL: https://console.cloud.google.com/cloud-build/triggers;region=us-central1?inv=1&invt=Abia9Q&project=proj-dev-demo000-aaaa
        5. GCP Artifact Registery For Application Code Images
                GCP Artifact Console URL: https://console.cloud.google.com/artifacts?referrer=search&authuser=2&inv=1&invt=Abia9Q&project=proj-dev-demo000-aaaa

Step 5: We need to run the cloud run infra pipeline in GCP Cloudbuild Console

            1. GCP Console URL To the cloud infra pipeline: https://console.cloud.google.com/cloud-build/triggers;region=us-central1?authuser=2&inv=1&invt=Abia5Q&project=proj-dev-demo000-aaaa
            2. GCP Pipeline Logs: https://console.cloud.google.com/cloud-build/builds;region=us-central1?authuser=2&inv=1&invt=Abia5Q&project=proj-dev-demo000-aaaa

Step 6: Afte Running Infra pipeline below GCP resource's will be created:

            1. GCP Service Account for the Application Deployment
                    GCP Sercice Account Console URL: https://console.cloud.google.com/iam-admin/serviceaccounts?referrer=search&authuser=2&project=proj-dev-demo000-aaaa
            2. GCP VPC Network
                    GCP VPC Network Console URL: https://console.cloud.google.com/networking/networks/list?referrer=search&authuser=2&project=proj-dev-demo000-aaaa
            3. GCP VPC Firewall rule
                    GCP VPC Firewall Console URL: https://console.cloud.google.com/networking/networks/details/default?project=proj-dev-demo000-aaaa&authuser=2&pageTab=FIREWALL_POLICIES
            4. GCP VPC Private Service Access for cloud sql
                    GCP VPC Private Sercvice Access Console URL: https://console.cloud.google.com/networking/networks/details/default?project=proj-dev-demo000-aaaa&authuser=2&pageTab=PRIVATE_SERVICES_ACCESS
            5. GCP VPC Network Peering for cloud sql
                    GCP VPC Network Peering Console URL: https://console.cloud.google.com/networking/networks/details/default?project=proj-dev-demo000-aaaa&authuser=2&pageTab=PEERINGS
            6. GCP Cloud SQL
                    GCP Cloud SQL Console URL: https://console.cloud.google.com/sql/instances?referrer=search&authuser=2&project=proj-dev-demo000-aaaa
            7. GCP Serverless VPC Access for Cloud Run
                    GCP Serverless VPC Access Console URL: https://console.cloud.google.com/networking/connectors/list?referrer=search&authuser=2&project=proj-dev-demo000-aaaa
            8. GCP Cloud Run
                    GCP Cloud Run Console URL: https://console.cloud.google.com/run?referrer=search&authuser=2&project=proj-dev-demo000-aaaa
            9. GCP Cloud Build Repository Connection for Application Deployment Pipeline
                    GCP Cloud Buil Repository Connection Console URL: https://console.cloud.google.com/cloud-build/repositories/2nd-gen?authuser=2&project=proj-dev-demo000-aaaa
            10. GCP Cloud Build Trigger for the Application Deployment Pipeline
                    GCP Cloud Build Trigger Console URL: https://console.cloud.google.com/cloud-build/triggers;region=us-central1?authuser=2&project=proj-dev-demo000-aaaa

Step 7: Once the GCP Infra pipeline is successfully executed in GCP Cloudbuild then run GCP Application Deployment Pipeline for deploying nodejs Application on Cloud Run

    1. It will build and push the nodejs docker image to the GCP Artifactery Registery with tag Build_ID and Latest 
    2. It will deploy the new cloud run revision with latest nodejs docker image 
    3. The latest docker image consist of nodejs application code that will deployed on GCP Cloud run and On Cloud Sql(MySql), database and table crearion is execuueted and store in the same image

Step 8: After Successfully deployment of image on the GCP Cloud Run, it will generate a default url in the gcp console: 
        Base Url: https://console.cloud.google.com/run?referrer=search&authuser=2&project=proj-dev-demo000-aaaa&inv=1&invt=Abia9Q


Step 9: For the destroying the entire infrastrure use below command
                ./destroy.sh

For the destroying the entire infrastrure including, project, backend, serivce account, artifact registery, cloudbuild registery connection for IAC, cloudbuild trigger for IAC as part of the core.
After successfully, it will start destroy cloud sql, cloud run, vpc serverless access connector, services account for application, firewall rule, vpc network peering, cloudbuild repository connection for the application pipeline and cloudbuild trigger for the application pipeline as part of services(IAC).


When you want to run terraform locallly we need use below commands

1. Terraform Init
        ./run.sh -w=dir init (if we want to run core folder then value for 'dir' will be 'core' and for the services folder value for 'dir' will be 'services')
        
        example for the core folder: ./run.sh -w=core inti

2. Terraform Plan
        ./run.sh -w=dir plan

3. Terraform Apply
        ./run.sh -w=dir apply

4. For the cleaning the repository 
        ./run.sh -w=dir reset (it will delete terraform local folders, cache)


