# Continuous Deployment on Google Cloud Platform

This project aims to configure a continuous deployment pipeline using Jenkins as CI tool and Kubernetes as application manager. All resources will be provided on Google Cloud Platform.

### Requirements
- a valid Google Cloud Platform account
- [Google Cloud SDK CLI Tool](https://cloud.google.com/sdk/docs/quickstarts) (`gcloud`)
- [Terraform CLI Tool](https://www.terraform.io/)

#### Step 1 - Bootstrap a GCP project
Using `gcloud` this will programatically bootstrap a new GCP project and enable the basic services to enable Terraform usage.

- Export your organization ID in the variable `GCP_ORGANIZATION_ID`
- Export your billing account ID in the variable `GCP_BILLING_ACCOUNT`
- Export the project name in the variable `GCP_PROJECT_NAME`
- Export the region in the variable `GCP_REGION`
- Run `make bootstrap` to:
    - create a new project on GCP;
    - generate an IAM account;
    - generate a new service account key that will be store in `.config/<project_name>-tf-service-account-key.json`;
    - create a new bucket;
    - generate the `cloud-setup/backend.tf` file;
    - generate the `cloud-setup/terraform.tfvars` file

#### Step 2 - Configure the GCP project
Using `terraform` this will create the default network and enable the required services to setup Kubernetes clusters.

From inside the `cloud-setup` folder, initialize Terraform with `terraform init`, plan the changes with `terraform plan`, and apply them by running `terraform apply --auto-approve`.

This will