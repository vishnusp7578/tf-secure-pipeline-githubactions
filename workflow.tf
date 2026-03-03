name: "Deploy VPC Infrastructure"

on:
  push:
    branches:
      - main
    paths:
      - '**.tf'           # Only trigger if TF files change
  pull_request:
    branches:
      - main

# Required for Workload Identity Federation (WIF)
permissions:
  contents: read
  id-token: write

jobs:
  terraform:
    name: "Terraform Action"
    runs-on: ubuntu-latest
    
    # Environment variables for the job
    env:
      PROJECT_ID: ${{ secrets.GCP_PROJECT_ID }}

    steps:
      - name: "Checkout Code"
        uses: actions/checkout@v4

      # 1. Authenticate with Google via WIF
      - id: "auth"
        name: "Authenticate to Google Cloud"
        uses: "google-github-actions/auth@v2"
        with:
          workload_identity_provider: "${{ secrets.GCP_WIF_PROVIDER }}"
          service_account: "${{ secrets.GCP_SA_EMAIL }}"

      # 2. Setup Terraform CLI
      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v3

      # 3. Terraform Init
      - name: Terraform Init
        run: terraform init

      # 4. Terraform Format Check (Security/Quality Best Practice)
      - name: Terraform Format
        run: terraform fmt -check

      # 5. Terraform Plan (Runs on PRs and Pushes)
      - name: Terraform Plan
        id: plan
        run: terraform plan -var="project_id=${{ secrets.GCP_PROJECT_ID }}" -no-color
        continue-on-error: true

      # 6. Terraform Apply (Runs ONLY on push to Main)
      - name: Terraform Apply
        if: github.ref == 'refs/heads/main' && github.event_name == 'push'
        run: terraform apply -auto-approve -var="project_id=${{ secrets.GCP_PROJECT_ID }}"
