#!/bin/sh
PROJECTS=$(gcloud projects list)

if [[ $PROJECTS == *${GCP_PROJECT_NAME}* ]]; then
    echo "The project ${GCP_PROJECT_NAME} already exists and will be used!"
else
    echo "Creating project ${GCP_PROJECT_NAME} on Google Cloud Platform..."
    gcloud projects create ${GCP_PROJECT_NAME} --organization $GCP_ORGANIZATION_ID

    gcloud beta billing projects link ${GCP_PROJECT_NAME} \
        --billing-account ${GCP_BILLING_ACCOUNT}

    echo "Enabling required services on project ${GCP_PROJECT_NAME}..."
    gcloud services enable cloudresourcemanager.googleapis.com --project ${GCP_PROJECT_NAME}
    gcloud services enable cloudbilling.googleapis.com --project ${GCP_PROJECT_NAME}
    gcloud services enable iam.googleapis.com --project ${GCP_PROJECT_NAME}
    gcloud services enable serviceusage.googleapis.com --project ${GCP_PROJECT_NAME}

    echo "Creating project bucket..."
    gsutil mb -p ${GCP_PROJECT_NAME} gs://${GCP_PROJECT_NAME}
    gsutil versioning set on gs://${GCP_PROJECT_NAME}
fi

SERVICE_ACCOUNT_NAME=terraform
SERVICE_ACCOUNTS=$(gcloud iam service-accounts list --project ${GCP_PROJECT_NAME})
IAM_ACCOUNT="${SERVICE_ACCOUNT_NAME}@${GCP_PROJECT_NAME}.iam.gserviceaccount.com"

if [[ $SERVICE_ACCOUNTS == *$SERVICE_ACCOUNT_NAME* ]]; then
    echo "The IAM account ${SERVICE_ACCOUNT_NAME} already exists and will be used!"
else
    echo "Creating IAM ${SERVICE_ACCOUNT_NAME} on project ${GCP_PROJECT_NAME}..."
    gcloud iam service-accounts create ${SERVICE_ACCOUNT_NAME} \
        --display-name ${SERVICE_ACCOUNT_NAME} \
        --project ${GCP_PROJECT_NAME}
fi

SERVICE_ACCOUNT_KEY=".config/${GCP_PROJECT_NAME}-tf-service-account-key.json"

if [ -f ${SERVICE_ACCOUNT_KEY} ]; then
    echo "The service account key located at ${SERVICE_ACCOUNT_KEY} will be used!"
else
    echo "Setting IAM policies for ${SERVICE_ACCOUNT_NAME}..."

    gcloud projects add-iam-policy-binding ${GCP_PROJECT_NAME} \
        --member serviceAccount:${IAM_ACCOUNT} \
        --role roles/owner

    gcloud projects add-iam-policy-binding ${GCP_PROJECT_NAME} \
        --member serviceAccount:${IAM_ACCOUNT} \
        --role roles/storage.admin

    echo "Creating service account key..."
    gcloud iam service-accounts keys create ${SERVICE_ACCOUNT_KEY} \
        --iam-account ${IAM_ACCOUNT} \
        --project ${GCP_PROJECT_NAME}
fi

cat > ./cloud-setup/backend.tf << EOF
terraform {
    backend "gcs" {
        bucket      = "${GCP_PROJECT_NAME}"
        prefix      = "terraform/state"
        credentials = "../${SERVICE_ACCOUNT_KEY}"
    }
}
EOF

cat > ./cloud-setup/terraform.tfvars << EOF
project_name = "${GCP_PROJECT_NAME}"
region = "${GCP_REGION}"
EOF

echo "\n"
echo "Your project on Google Cloud Platform is properly configured!"
