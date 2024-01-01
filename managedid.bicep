//Scope
targetScope = 'resourceGroup'

//Variables
var storageaccountname = 'ntast${uniqueString(subscription().subscriptionId, resourceGroup().id, 'ntast')}'
var add4hour = dateTimeAdd(deploymenttime, 'PT4H')

//Parameters
param loganalyticsregion string
param deploymenttime string = utcNow('yyyy-MM-ddTHH:mm:ssZ')

//Resources

//Azure Policy Remeditation Task User Managed Identity
resource azdsmanagedidentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-07-31-preview' = {
  name: 'umi-azds-mgmt'
  location: loganalyticsregion
}

//This deploys the Storage Account for NSG Flow Logs.
resource stntaflow 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: storageaccountname
  location: loganalyticsregion
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${azdsmanagedidentity.id}': {}
    }
  }
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    supportsHttpsTrafficOnly: true
    publicNetworkAccess: 'Enabled'
    accessTier: 'Hot'
    minimumTlsVersion: 'TLS1_2'
  }
}

//This deploys the Azure Automation Account.
resource automationaccount 'Microsoft.Automation/automationAccounts@2023-11-01' = {
  name: 'auto-azds-mgmt'
  location: loganalyticsregion
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    sku: {
      name: 'Basic'
    }
  }
}

//This deploys the Azure Automation Runbook.
resource runbook 'Microsoft.Automation/automationAccounts/runbooks@2023-11-01' = {
  name: '${automationaccount.name}/remediate'
  location: loganalyticsregion
  properties: {
    logVerbose: false
    logProgress: false
    runbookType: 'PowerShell'
    publishContentLink: {
      uri: 'https://raw.githubusercontent.com/msdirtbag/AzureDiagnosticSettings/main/remediate.ps1'
      version: '1.0.0.0'
      contentHash: {
        algorithm: 'sha256'
        value: 'b7bce70d12ea35d618d4f2c667eea7332ca745014f8d8c6d2c409ebb860baa9a'
      }
    }
  }
  dependsOn: [
    automationaccount
  ]
}

//This deploys the Azure Automation Schedule.
resource schedule 'Microsoft.Automation/automationAccounts/schedules@2023-11-01' = {
  name: '${automationaccount.name}/daily'
  properties: {
    startTime: add4hour
    expiryTime: '9999-12-31T00:00:00+00:00'
    interval: 24
    frequency: 'Hour'
    timeZone: 'UTC'
  }
  dependsOn: [
    runbook
  ]
}

//This deploys the Azure Automation Job Schedule linking.
resource jobschedule 'Microsoft.Automation/automationAccounts/jobSchedules@2023-11-01' = {
  name: '${guid(runbook.name, schedule.name, deploymenttime)}'
  parent: automationaccount
  properties: {
    schedule: {
      name: 'daily'
    }
    runbook: {
      name: 'remediate'     
    }
    parameters: {}
  }
  dependsOn: [
    automationaccount
    schedule
    runbook
  ]
}

//This deploys the Azure Automation Az.Accounts Module.
resource azAccountsModule 'Microsoft.Automation/automationAccounts/modules@2023-11-01' = {
  name: '${automationaccount.name}/Az.Accounts'
  properties: {
    contentLink: {
      uri: 'https://www.powershellgallery.com/api/v2/package/Az.Accounts'
    }
  }
}

//This deploys the Azure Automation Az.Resources Module.
resource azResourcesModule 'Microsoft.Automation/automationAccounts/modules@2023-11-01' = {
  name: '${automationaccount.name}/Az.Resources'
  properties: {
    contentLink: {
      uri: 'https://www.powershellgallery.com/api/v2/package/Az.Resources'
    }
  }
  dependsOn: [
    azAccountsModule
  ]
}

//Outputs
output miresourcepid string = azdsmanagedidentity.properties.principalId
output mirid string = azdsmanagedidentity.id
output mirname string = azdsmanagedidentity.name
output stntaflowid string = stntaflow.id
output automationaccountpid string = automationaccount.identity.principalId








