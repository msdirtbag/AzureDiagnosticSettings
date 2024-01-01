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

## Log Documentation:

### Tier 1:

Background: These logs are inexpensive to collect and should be collected in every Azure tenant regardless of the tenant’s purpose or risk tolerance.

Resource Type + Log Analytics Table:

Azure Container Registry
•	ContainerRegistryRepositoryEvents
•	ContainerRegistryLoginEvents

Azure Kubernetes Service
•	kube-audit-admin
•	guard

Azure Automation
•	AzureDiagnostics-AuditEvent

Azure Activity
•	AzureActivity-Administrative, Security, ServiceHealth, Alert, Recommendation, Policy, Autoscale, ResourceHealth

Azure Bastion
•	MicrosoftAzureBastionAuditLogs

Azure Key Vault
•	AzureDiagnostics-AuditEvent

Azure Recovery Vault
•	CoreAzureBackup
•	AddonAzureBackupAlerts
•	AddonAzureBackupPolicy
•	AddonAzureBackupStorage

### Tier 2:

Background: This tier includes the Network telemetry logs that should provide broad Ingress/Egress & East/West visibility into Azure network communications. (In Azure deployments that follow CAF/WAF design standards)

Resource Type + Log Analytics Table:

Azure Application Gateway
•	ApplicationGatewayFirewallLog
•	ApplicationGatewayAccessLog

Azure Front Door
•	FrontdoorWebApplicationFirewallLog
•	FrontdoorAccessLog

Azure Firewall
•	AZFWDnsQuery
•	AZFWIdpsSignature
•	AZFWApplicationRule
•	AZFWNetworkRule
•	AZFWThreatIntel

Azure Network Security Group
•	NetworkSecurityGroupEvent

Azure NSG Flow Log
•	AzureNetworkAnalytics_CL

### Tier 3:

Background: This tier is mostly the Application and Performance logs that enhance security incident investigations. These logs should be stored in a non-Sentinel-enabled LAW that can be queried from Sentinel via cross workspace KQL queries. 

Resource Type + Log Analytics Table:

Azure Kubernetes Service
•	kube-apiserver
•	kube-audit
•	kube-controller-manager
•	kube-scheduler 
•	cluster-autoscaler
•	cloud-controller-manager
•	csi-azuredisk-controller
•	csi-azurefile-controller
•	csi-snapshot-controller

Azure API Gateway
•	ApiManagementGatewayLogs

Azure Application Insights
•	availabilityResults
•	browserTimings
•	customEvents
•	customMetrics
•	dependencies
•	exceptions
•	pageViews
•	performanceCounters
•	requests
•	traces

Azure App Service
•	AppServiceAntivirusScanAuditLogs
•	AppServiceConsoleLogs
•	AppServiceAppLogs
•	AppServiceFileAuditLogs
•	AppServiceAuditLogs
•	AppServiceIPSecAuditLogs
•	AppServicePlatformLogs

Azure Function
•	FunctionAppLogs

Azure CosmosDB
•	DataPlaneRequests
•	MongoRequests
•	QueryRuntimeStatistics
•	PartitionKeyStatistics
•	PartitionKeyRUConsumption
•	ControlPlaneRequests
•	CassandraRequests
•	GremlinRequests
•	TableApiRequests

Azure Logic App
•	AzureDiagnostics-WorkflowRuntime

Azure Public IP
•	AzureDiagnostics-DDoSProtectionNotifications

Azure SQL
•	AzureDiagnostics-SQLSecurityAuditEvents, DevOpsOperationsAudit

Azure SQL Managed Instance
•	AzureDiagnostics-SQLSecurityAuditEvents, DevOpsOperationsAudit

Azure Storage Account
•	StorageTableLogs
•	StorageQueueLogs
•	StorageFileLogs
•	StorageBlobLogs


