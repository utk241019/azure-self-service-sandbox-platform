# Automated Self-Service Cloud Sandbox Provisioning Platform

## Project Overview

This project demonstrates an automated cloud infrastructure provisioning workflow using **Azure Bicep** and **GitHub Actions**.

The goal is to create a self-service sandbox environment where Azure resources can be provisioned automatically through a CI/CD pipeline instead of manually creating resources from the Azure Portal.

The workflow automates the creation of:

- Azure Resource Group
- Virtual Machine
- Storage Account
- Supporting Azure resources defined in Bicep templates

This project follows Infrastructure as Code (IaC) practices to make cloud deployments repeatable, consistent, and version controlled.

---

## Technologies Used

- Microsoft Azure
- Azure Bicep
- GitHub Actions
- Azure CLI
- GitHub Secrets
- YAML
- Infrastructure as Code (IaC)

---

## Project Architecture

```
Developer
    |
    |
    v
GitHub Repository
    |
    |
    v
GitHub Actions Workflow
    |
    |
    v
Azure Service Principal Authentication
    |
    |
    v
Azure Subscription
    |
    |
    +----------------+
    |                |
    v                v
Resource Group   Storage Account
    |
    |
    v
Virtual Machine
```

---

## Repository Structure

```
Automated-Sandbox-Provisioning/
│
├── .github/
│   └── workflows/
│       └── deploy.yml
│
├── infra/
│   ├── main.bicep
│   └── main.bicepparam
│
└── README.md
```

---

# GitHub Actions Workflow

The GitHub Actions workflow performs the following steps:

1. Validates the Bicep template
2. Authenticates with Azure using Service Principal
3. Creates the Resource Group if it does not exist
4. Deploys Azure infrastructure using Bicep
5. Provides deployment status in GitHub Actions

---

# Azure Authentication Setup

This project uses an Azure Service Principal for secure authentication between GitHub Actions and Azure.

The workflow does not use individual user accounts. It uses the Azure credentials stored in GitHub Secrets.

## Create Azure Service Principal

Run the following command:

```bash
az ad sp create-for-rbac \
--name github-sandbox-sp \
--role Contributor \
--scopes /subscriptions/<YOUR_SUBSCRIPTION_ID>
```

The command will generate:

- Client ID
- Client Secret
- Tenant ID
- Subscription ID

Save these values securely.

---

# Configure GitHub Secrets

In your GitHub repository:

```
Settings
   |
   └── Secrets and variables
            |
            └── Actions
```

Create the following repository secrets:

```
AZURE_CLIENT_ID

AZURE_CLIENT_SECRET

AZURE_TENANT_ID

AZURE_SUBSCRIPTION_ID
```

These secrets are used by GitHub Actions to authenticate with Azure.

---

# Deploy Infrastructure

After configuring GitHub Secrets:

1. Open the repository
2. Navigate to:

```
Actions → Deploy Azure Sandbox
```

3. Select:

```
Run workflow
```

The pipeline will automatically deploy the Azure resources defined in the Bicep template.

---

# Using This Project With Another Azure Account

This repository can be reused by other users with their own Azure subscription.

To deploy into another Azure account, the user must:

1. Fork this repository
2. Create their own Azure Service Principal
3. Add their Azure credentials as GitHub Secrets
4. Run the GitHub Actions workflow

The resources will then be created inside their Azure subscription.

The workflow always deploys resources to the Azure account associated with the configured Service Principal.

---

# Infrastructure Deployment Example

The workflow can automatically provision:

```
Azure Resource Group

        |
        |
        +---- Virtual Machine

        |
        |
        +---- Storage Account
```

All infrastructure is defined using Bicep templates and deployed automatically through GitHub Actions.

---

# Cleanup Resources

To remove the deployed resources:

```bash
az group delete \
--name <RESOURCE_GROUP_NAME> \
--yes \
--no-wait
```

This removes all resources created inside the Resource Group.

---

# Key Learning Outcomes

Through this project, the following DevOps concepts were implemented:

- Infrastructure as Code using Azure Bicep
- Automated Azure deployments using GitHub Actions
- CI/CD pipeline creation
- Azure Service Principal authentication
- Secure credential management using GitHub Secrets
- Cloud resource provisioning automation

---

# Future Improvements

Possible enhancements:

- Add approval gates before production deployments
- Add automated testing for infrastructure templates
- Implement Terraform alternative deployment
- Add monitoring and cost tracking
- Add automatic sandbox expiration and cleanup

---

## Author

**Utkarsh Paighan**

DevOps / Cloud Engineering Learning Project
