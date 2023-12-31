# AzureDiagnosticSettings

This project is designed to assist IT teams to rapidly configure security logging for core Azure resource types. It uses Azure Policy to ensure that all current & future Azure Resources are configured with the log collection standards.

Initial deployment takes about 30-45 minutes (larger tenants take longer). AzureDiagnosticSettings 2.0 also includes an Azure Automation Runbook that runs every 24 hours to ensure compliance with the logging standards of each tier.

The Log Analytics Workspace is parameterized so you can do a split schema and send Tier1/Tier2 logs to a Sentinel-enabled LAW and send Tier3 to a non-Sentinel-enabled LAW (Azure Monitor Workspace). This is strongly recommended if you are deploying Tier3. 

What are Azure Diagnostic Settings: https://learn.microsoft.com/en-us/azure/azure-monitor/essentials/diagnostic-settings

What is Azure Policy: https://learn.microsoft.com/en-us/azure/governance/policy/overview

## Deployment Noties:

🔻 By design, this deployment leverages the Tenant Root Managment Group to deploy to all Subscriptions in the Azure tenant.

🔻 Do not deploy Tier3 to a Log Analytics workspace that has Sentinel enabled. 

🔻 Owner permissions for Tenant Root Management Group + Global Administrator must be Active for the SPN/User doing the deployment. 

## Included Content:

-Custom Diagnostic Setting Category selection

-Azure Automation Runbook that runs daily Azure Policy Remediation Tasks

-Azure Monitor Agent & Security Data Collection Rule associations for Windows & Linux

-Azure Monitor-VM Insights, Container Insights & AKS syslog Data Collection Rule, Service Map, Application Insights (Tier3)

-Security Event Data Collection Rules for Windows & Linux


## Programing Notes:

-No warranties expressed or implied. If something breaks or you get a unexpected Azure bill, it's on you. 

## Deployment Guides:

- VS Code: https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/deploy-vscode
- Azure CLI: https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/deploy-cli
- Azure PowerShell: https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/deploy-powershell
- Azure Cloud Shell: https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/deploy-cloud-shell
- GitHub Actions: https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/deploy-github-actions



