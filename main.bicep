//     AzureDignosticSettings 
//     v-2.0.0
//     *See README file for usage information
//     *This bicep template will generate Log Analytics Ingest charges.

//Scope
targetScope = 'managementGroup'

//Parameters
param loganalyticsregion string
param loganalytics1rid string
param loganalytics2rid string
param loganalytics3rid string
param nsgflowlogworkspaceid string
param mgmtsubscription string
param mgmtresourcegroup string
param deploytier2 bool
param deploytier3 bool

//Variables
var managementgroup = tenant().tenantId

//Modules

//This module deploys the Azure Diagnostic Resource Group.
module azdsresourcegroup './resourcegroup.bicep' = {
  name: 'AZDSResourceGroups'
  scope:subscription(mgmtsubscription)
  params:{
    loganalyticsregion: loganalyticsregion
    mgmtresourcegroup: mgmtresourcegroup
  }
}

//This module deploys the Azure Diagnostic Managed Identity.
module azdsmanagedidentity './managedid.bicep' = {
  name: 'AZDSUserManagedIdentity'
  scope: resourceGroup('${mgmtsubscription}', '${mgmtresourcegroup}')
  params:{
    loganalyticsregion:loganalyticsregion
  }
  dependsOn: [
    azdsresourcegroup
  ]
}

//This module deploys the Azure Diagnostic Role Assignments.
module azdsroleassignment './roleassign.bicep' = {
  name: 'AZDSRoleAssignment'
  scope: managementGroup(managementgroup)
  params:{
    principalId:azdsmanagedidentity.outputs.miresourcepid
    automationaccountpid:azdsmanagedidentity.outputs.automationaccountpid
  }
}

//This module deploys the Azure Diagnostic Data Collection Rules.
module azdsdcr './dcr.bicep' = {
  name: 'AZDSDataCollectionRule'
  scope: resourceGroup('${mgmtsubscription}', '${mgmtresourcegroup}')
  params:{
    loganalyticsregion: loganalyticsregion
    loganalytics1rid: loganalytics1rid
    loganalytics2rid: loganalytics2rid
    azdsumiid: azdsmanagedidentity.outputs.mirid
  }
  dependsOn: [
    azdsroleassignment
  ]
}

//This module deploys the DCR Azure Policies.
module azdsazpolicy './policy.bicep' = {
  name: 'AZDSAzurePolicy'
  scope: managementGroup(managementgroup)
  params:{
    loganalyticsregion: loganalyticsregion
    azmanagedidentity: azdsmanagedidentity.outputs.mirid
    mgmtresourcegroup: mgmtresourcegroup
    muasminame: azdsmanagedidentity.outputs.mirname
    linuxdcrid: azdsdcr.outputs.mdcdcrid02
    commondcrid: azdsdcr.outputs.mdcdcrid01
    vmiid: azdsdcr.outputs.mdcdcrid03
  }
  dependsOn: [
    azdsroleassignment
  ]
}

//This module deploys the Activation script.
module azdsdeploymentscript './activation.bicep' = {
  name: 'AZDSDeploymentScript'
  scope: resourceGroup('${mgmtsubscription}', '${mgmtresourcegroup}')
  params:{
    location: loganalyticsregion
    azdsumiid: azdsmanagedidentity.outputs.mirid
  }
  dependsOn: [
    azdsmanagedidentity
    azdsdcr
    azdsazpolicy
    azactivitydeploy
    azkvdeploy
    azbasdeploy
    azrsvdeploy
    azacrdeploy
    azagdeploy
    azfddeploy
    azfwdeploy
    aznsgdeploy
    aznsgflowdeploy
    azautodeploy
  ]
}

//ARM Templates

//Tier 1 - Required for production workloads

//This module deploys the Entra Diagnostic settings.
module entradiag './tier1/entra.bicep' = {
  name: 'AZDSEntraIDDiagnosticSettings'
  scope: tenant()
  params:{
    laworkspacerid: loganalytics1rid
  }
}

//This deploy Azure Activity Diagnostic Settings.
var AZDS_AzActivity = json(loadTextContent('./tier1/AZDS_AzActivity.json'))
resource azactivitypolicy 'Microsoft.Authorization/policyDefinitions@2023-04-01' = {
  name: 'AZDS_AzActivity'
  properties: AZDS_AzActivity.properties
}
module azactivitydeploy './polassign.bicep' = {
  name: 'AZDS_AzActivityDeployment'
  scope: managementGroup(managementgroup)
  params:{
    policyassignname: 'AZDS_AzActivity'
    policydefinitionid: azactivitypolicy.id
    policydescription: azactivitypolicy.properties.description
    azdsumiid: azdsmanagedidentity.outputs.mirid
    loganalyticsregion: loganalyticsregion
    loganalyticsrid: loganalytics1rid
  }
  dependsOn: [
    azactivitypolicy
  ]
}

//This deploys AKS Diagnostic Settings.
var AZDS_AKST1 = json(loadTextContent('./tier1/AZDS_AKS.json'))
resource akst1policy 'Microsoft.Authorization/policyDefinitions@2023-04-01' = {
  name: 'AZDS_AKST1'
  properties: AZDS_AKST1.properties
}
module azaksdeploy './polassign.bicep' = {
  name: 'AZDS_AKST1Deployment'
  scope: managementGroup(managementgroup)
  params:{
    policyassignname: 'AZDS_AKST1'
    policydefinitionid: akst1policy.id
    policydescription: akst1policy.properties.description
    azdsumiid: azdsmanagedidentity.outputs.mirid
    loganalyticsregion: loganalyticsregion
    loganalyticsrid: loganalytics1rid
  }
  dependsOn: [
    akst1policy
  ]
}

//This deploys Key Vault Diagnostic Settings.
var AZDS_KV = json(loadTextContent('./tier1/AZDS_KV.json'))
resource kvpolicy 'Microsoft.Authorization/policyDefinitions@2023-04-01' = {
  name: 'AZDS_KV'
  properties: AZDS_KV.properties
}
module azkvdeploy './polassign.bicep' = {
  name: 'AZDS_KVDeployment'
  scope: managementGroup(managementgroup)
  params:{
    policyassignname: 'AZDS_KV'
    policydefinitionid: kvpolicy.id
    policydescription: kvpolicy.properties.description
    azdsumiid: azdsmanagedidentity.outputs.mirid
    loganalyticsregion: loganalyticsregion
    loganalyticsrid: loganalytics1rid
  }
  dependsOn: [
    kvpolicy
  ]
}

//This deploys Bastion Diagnostic Settings.
var AZDS_BAS = json(loadTextContent('./tier1/AZDS_BAS.json'))
resource baspolicy 'Microsoft.Authorization/policyDefinitions@2023-04-01' = {
  name: 'AZDS_BAS'
  properties: AZDS_BAS.properties
}
module azbasdeploy './polassign.bicep' = {
  name: 'AZDS_BASDeployment'
  scope: managementGroup(managementgroup)
  params:{
    policyassignname: 'AZDS_BAS'
    policydefinitionid: baspolicy.id
    policydescription: baspolicy.properties.description
    azdsumiid: azdsmanagedidentity.outputs.mirid
    loganalyticsregion: loganalyticsregion
    loganalyticsrid: loganalytics1rid
  }
  dependsOn: [
    baspolicy
  ]
}

//This deploys Recovery Vault Diagnostic Settings.
var AZDS_RSV = json(loadTextContent('./tier1/AZDS_RSV.json'))
resource rsvpolicy 'Microsoft.Authorization/policyDefinitions@2023-04-01' = {
  name: 'AZDS_RSV'
  properties: AZDS_RSV.properties
}
module azrsvdeploy './polassign.bicep' = {
  name: 'AZDS_RSVDeployment'
  scope: managementGroup(managementgroup)
  params:{
    policyassignname: 'AZDS_RSV'
    policydefinitionid: rsvpolicy.id
    policydescription: rsvpolicy.properties.description
    azdsumiid: azdsmanagedidentity.outputs.mirid
    loganalyticsregion: loganalyticsregion
    loganalyticsrid: loganalytics1rid
  }
  dependsOn: [
    rsvpolicy
  ]
}

//This deploys Container Registry Diagnostic Settings.
var AZDS_ACR = json(loadTextContent('./tier1/AZDS_ACR.json'))
resource acrpolicy 'Microsoft.Authorization/policyDefinitions@2023-04-01' = {
  name: 'AZDS_ACR'
  properties: AZDS_ACR.properties
}
module azacrdeploy './polassign.bicep' = {
  name: 'AZDS_ACRDeployment'
  scope: managementGroup(managementgroup)
  params:{
    policyassignname: 'AZDS_ACR'
    policydefinitionid: acrpolicy.id
    policydescription: acrpolicy.properties.description
    azdsumiid: azdsmanagedidentity.outputs.mirid
    loganalyticsregion: loganalyticsregion
    loganalyticsrid: loganalytics1rid
  }
  dependsOn: [
    acrpolicy
  ]
}

//This deploys Azure Automation Diagnostic Settings.
var AZDS_Auto = json(loadTextContent('./tier1/AZDS_Auto.json'))
resource autopolicy 'Microsoft.Authorization/policyDefinitions@2023-04-01' = {
  name: 'AZDS_Auto'
  properties: AZDS_Auto.properties
}
module azautodeploy './polassign.bicep' = {
  name: 'AZDS_AutoDeployment'
  scope: managementGroup(managementgroup)
  params:{
    policyassignname: 'AZDS_Auto'
    policydefinitionid: autopolicy.id
    policydescription: autopolicy.properties.description
    azdsumiid: azdsmanagedidentity.outputs.mirid
    loganalyticsregion: loganalyticsregion
    loganalyticsrid: loganalytics1rid
  }
  dependsOn: [
    autopolicy
  ]
}

//Tier 2 - Recommended for production workloads

//This deploys App Gateway Diagnostic Settings.
var AZDS_AG = json(loadTextContent('./tier2/AZDS_AG.json'))
resource agpolicy 'Microsoft.Authorization/policyDefinitions@2023-04-01' = if (deploytier2) {
  name: 'AZDS_AG'
  properties: AZDS_AG.properties
}
module azagdeploy './polassign.bicep' = if (deploytier2) {
  name: 'AZDS_AGDeployment'
  scope: managementGroup(managementgroup)
  params:{
    policyassignname: 'AZDS_AG'
    policydefinitionid: agpolicy.id
    policydescription: agpolicy.properties.description
    azdsumiid: azdsmanagedidentity.outputs.mirid
    loganalyticsregion: loganalyticsregion
    loganalyticsrid: loganalytics1rid
  }
  dependsOn: [
    agpolicy
  ]
}

//This deploys Front Door Diagnostic Settings.
var AZDS_FD = json(loadTextContent('./tier2/AZDS_FD.json'))
resource fdpolicy 'Microsoft.Authorization/policyDefinitions@2023-04-01' = if (deploytier2) {
  name: 'AZDS_FD'
  properties: AZDS_FD.properties
}
module azfddeploy './polassign.bicep' = if (deploytier2) {
  name: 'AZDS_FDDeployment'
  scope: managementGroup(managementgroup)
  params:{
    policyassignname: 'AZDS_FD'
    policydefinitionid: fdpolicy.id
    policydescription: fdpolicy.properties.description
    azdsumiid: azdsmanagedidentity.outputs.mirid
    loganalyticsregion: loganalyticsregion
    loganalyticsrid: loganalytics1rid
  }
  dependsOn: [
    fdpolicy
  ]
}

//This deploys Firewall Diagnostic Settings.
var AZDS_Firewall = json(loadTextContent('./tier2/AZDS_Firewall.json'))
resource fwpolicy 'Microsoft.Authorization/policyDefinitions@2023-04-01' = if (deploytier2) {
  name: 'AZDS_Firewall'
  properties: AZDS_Firewall.properties
}
module azfwdeploy './polassign.bicep' = if (deploytier2) {
  name: 'AZDS_FWDeployment'
  scope: managementGroup(managementgroup)
  params:{
    policyassignname: 'AZDS_Firewall'
    policydefinitionid: fwpolicy.id
    policydescription: fwpolicy.properties.description
    azdsumiid: azdsmanagedidentity.outputs.mirid
    loganalyticsregion: loganalyticsregion
    loganalyticsrid: loganalytics1rid
  }
  dependsOn: [
    fwpolicy
  ]
}

//This deploys Network Security Group Diagnostic Settings.
var AZDS_NSG = json(loadTextContent('./tier2/AZDS_NSG.json'))
resource nsgpolicy 'Microsoft.Authorization/policyDefinitions@2023-04-01' = if (deploytier2) {
  name: 'AZDS_NSG'
  properties: AZDS_NSG.properties
}
module aznsgdeploy './polassign.bicep' = if (deploytier2) {
  name: 'AZDS_NSGDeployment'
  scope: managementGroup(managementgroup)
  params:{
    policyassignname: 'AZDS_NSG'
    policydefinitionid: nsgpolicy.id
    policydescription: nsgpolicy.properties.description
    azdsumiid: azdsmanagedidentity.outputs.mirid
    loganalyticsregion: loganalyticsregion
    loganalyticsrid: loganalytics1rid
  }
  dependsOn: [
    nsgpolicy
  ]
}

//This deploys NSG Flow Logs.
var AZDS_NSGFLOW = json(loadTextContent('./tier2/AZDS_NSGFLOW.json'))
resource nsgflowpolicy 'Microsoft.Authorization/policyDefinitions@2023-04-01' = if (deploytier2) {
  name: 'AZDS_NSGFLOW'
  properties: AZDS_NSGFLOW.properties
}
module aznsgflowdeploy './ntaassign.bicep' = if (deploytier2) {
  name: 'AZDS_NSGFLOWDeployment'
  scope: managementGroup(managementgroup)
  params:{
    policyassignname: 'AZDS_NSGFLOW'
    policydefinitionid: nsgflowpolicy.id
    policydescription: nsgflowpolicy.properties.description
    azdsumiid: azdsmanagedidentity.outputs.mirid
    loganalyticsregion: loganalyticsregion
    loganalyticsrid: loganalytics1rid
    nsgflowlogworkspaceid: nsgflowlogworkspaceid
    ntastorageid: azdsmanagedidentity.outputs.stntaflowid
  }
  dependsOn: [
    nsgflowpolicy
  ]
}

//Tier 3 - Recommended for Azure Forensics

//This deploys API Gateway Diagnostic Settings.
var AZDS_APIM = json(loadTextContent('./tier3/AZDS_APIM.json'))
resource apimpolicy 'Microsoft.Authorization/policyDefinitions@2023-04-01' = if (deploytier3) {
  name: 'AZDS_APIM'
  properties: AZDS_APIM.properties
}
module azapimdeploy './polassign.bicep' = if (deploytier3) {
  name: 'AZDS_APIMDeployment'
  scope: managementGroup(managementgroup)
  params:{
    policyassignname: 'AZDS_APIM'
    policydefinitionid: apimpolicy.id
    policydescription: apimpolicy.properties.description
    azdsumiid: azdsmanagedidentity.outputs.mirid
    loganalyticsregion: loganalyticsregion
    loganalyticsrid: loganalytics3rid
  }
  dependsOn: [
    apimpolicy
  ]
}

//This deploys App Service Diagnostic Settings.
var AZDS_AppService = json(loadTextContent('./tier3/AZDS_AppService.json'))
resource appservicepolicy 'Microsoft.Authorization/policyDefinitions@2023-04-01' = if (deploytier3) {
  name: 'AZDS_AppService'
  properties: AZDS_AppService.properties
}
module azappservicedeploy './polassign.bicep' = if (deploytier3) {
  name: 'AZDS_AppServiceDeployment'
  scope: managementGroup(managementgroup)
  params:{
    policyassignname: 'AZDS_AppService'
    policydefinitionid: appservicepolicy.id
    policydescription: appservicepolicy.properties.description
    azdsumiid: azdsmanagedidentity.outputs.mirid
    loganalyticsregion: loganalyticsregion
    loganalyticsrid: loganalytics3rid
  }
  dependsOn: [
    appservicepolicy
  ]
}

//This deploys CosmosDB Diagnostic Settings.
var AZDS_CosmosDB = json(loadTextContent('./tier3/AZDS_CosmosDB.json'))
resource cosmosdbpolicy 'Microsoft.Authorization/policyDefinitions@2023-04-01' = if (deploytier3) {
  name: 'AZDS_CosmosDB'
  properties: AZDS_CosmosDB.properties
}
module azcosmosdbdeploy './polassign.bicep' = if (deploytier3) {
  name: 'AZDS_CosmosDBDeployment'
  scope: managementGroup(managementgroup)
  params:{
    policyassignname: 'AZDS_CosmosDB'
    policydefinitionid: cosmosdbpolicy.id
    policydescription: cosmosdbpolicy.properties.description
    azdsumiid: azdsmanagedidentity.outputs.mirid
    loganalyticsregion: loganalyticsregion
    loganalyticsrid: loganalytics3rid
  }
  dependsOn: [
    cosmosdbpolicy
  ]
}

//This deploys Function Diagnostic Settings.
var AZDS_Func = json(loadTextContent('./tier3/AZDS_Func.json'))
resource funcpolicy 'Microsoft.Authorization/policyDefinitions@2023-04-01' = if (deploytier3) {
  name: 'AZDS_Func'
  properties: AZDS_Func.properties
}
module azfuncdeploy './polassign.bicep' = if (deploytier3) {
  name: 'AZDS_FuncDeployment'
  scope: managementGroup(managementgroup)
  params:{
    policyassignname: 'AZDS_Func'
    policydefinitionid: funcpolicy.id
    policydescription: funcpolicy.properties.description
    azdsumiid: azdsmanagedidentity.outputs.mirid
    loganalyticsregion: loganalyticsregion
    loganalyticsrid: loganalytics3rid
  }
  dependsOn: [
    funcpolicy
  ]
}

//This deploys Logic App Diagnostic Settings.
var AZDS_LA= json(loadTextContent('./tier3/AZDS_LA.json'))
resource lapolicy 'Microsoft.Authorization/policyDefinitions@2023-04-01' = if (deploytier3) {
  name: 'AZDS_LA'
  properties: AZDS_LA.properties
}
module azladeploy './polassign.bicep' = {
  name: 'AZDS_LA'
  scope: managementGroup(managementgroup)
  params:{
    policyassignname: 'AZDS_LA'
    policydefinitionid: lapolicy.id
    policydescription: lapolicy.properties.description
    azdsumiid: azdsmanagedidentity.outputs.mirid
    loganalyticsregion: loganalyticsregion
    loganalyticsrid: loganalytics3rid
  }
  dependsOn: [
    lapolicy
  ]
}

//This deploys Public IP Diagnostic Settings.
var AZDS_PIP = json(loadTextContent('./tier3/AZDS_PIP.json'))
resource pippolicy 'Microsoft.Authorization/policyDefinitions@2023-04-01' = if (deploytier3) {
  name: 'AZDS_PIP'
  properties: AZDS_PIP.properties
}
module azpipdeploy './polassign.bicep' = {
  name: 'AZDS_PIPDeployment'
  scope: managementGroup(managementgroup)
  params:{
    policyassignname: 'AZDS_PIP'
    policydefinitionid: pippolicy.id
    policydescription: pippolicy.properties.description
    azdsumiid: azdsmanagedidentity.outputs.mirid
    loganalyticsregion: loganalyticsregion
    loganalyticsrid: loganalytics3rid
  }
  dependsOn: [
    pippolicy
  ]
}

//This deploys SQL Diagnostic Settings.
var AZDS_SQL = json(loadTextContent('./tier3/AZDS_SQL.json'))
resource sqlpolicy 'Microsoft.Authorization/policyDefinitions@2023-04-01' = if (deploytier3) {
  name: 'AZDS_SQL'
  properties: AZDS_SQL.properties
}
module azsqldeploy './polassign.bicep' = if (deploytier3) {
  name: 'AZDS_SQLDeployment'
  scope: managementGroup(managementgroup)
  params:{
    policyassignname: 'AZDS_SQL'
    policydefinitionid: sqlpolicy.id
    policydescription: sqlpolicy.properties.description
    azdsumiid: azdsmanagedidentity.outputs.mirid
    loganalyticsregion: loganalyticsregion
    loganalyticsrid: loganalytics3rid
  }
  dependsOn: [
    sqlpolicy
  ]
}

//This deploys SQL Managed Instance Diagnostic Settings.
var AZDS_SQLM = json(loadTextContent('./tier3/AZDS_SQLM.json'))
resource sqlmpolicy 'Microsoft.Authorization/policyDefinitions@2023-04-01' = if (deploytier3) {
  name: 'AZDS_SQLM'
  properties: AZDS_SQLM.properties
}
module azsqlmdeploy './polassign.bicep' = if (deploytier3) {
  name: 'AZDS_SQLMDeployment'
  scope: managementGroup(managementgroup)
  params:{
    policyassignname: 'AZDS_SQLM'
    policydefinitionid: sqlmpolicy.id
    policydescription: sqlmpolicy.properties.description
    azdsumiid: azdsmanagedidentity.outputs.mirid
    loganalyticsregion: loganalyticsregion
    loganalyticsrid: loganalytics3rid
  }
  dependsOn: [
    sqlmpolicy
  ]
}

//This deploys Storage Diagnostic Settings.
var AZDS_Storage = json(loadTextContent('./tier3/AZDS_Storage.json'))
resource storagepolicy 'Microsoft.Authorization/policyDefinitions@2023-04-01' = if (deploytier3) {
  name: 'AZDS_Storage'
  properties: AZDS_Storage.properties
}
module azstoragedeploy './polassign.bicep' = if (deploytier3) {
  name: 'AZDS_StorageDeployment'
  scope: managementGroup(managementgroup)
  params:{
    policyassignname: 'AZDS_Storage'
    policydefinitionid: storagepolicy.id
    policydescription: storagepolicy.properties.description
    azdsumiid: azdsmanagedidentity.outputs.mirid
    loganalyticsregion: loganalyticsregion
    loganalyticsrid: loganalytics3rid
  }
  dependsOn: [
    storagepolicy
  ]
}

//This deploys Application Insights Diagnostic Settings.
var AZDS_APPI = json(loadTextContent('./tier3/AZDS_APPI.json'))
resource appipolicy 'Microsoft.Authorization/policyDefinitions@2023-04-01' = if (deploytier3) {
  name: 'AZDS_APPI'
  properties: AZDS_APPI.properties
}
module azappideploy './polassign.bicep' = if (deploytier3) {
  name: 'AZDS_APPIDeployment'
  scope: managementGroup(managementgroup)
  params:{
    policyassignname: 'AZDS_APPI'
    policydefinitionid: appipolicy.id
    policydescription: appipolicy.properties.description
    azdsumiid: azdsmanagedidentity.outputs.mirid
    loganalyticsregion: loganalyticsregion
    loganalyticsrid: loganalytics3rid
  }
  dependsOn: [
    appipolicy
  ]
}

//This deploys AKS Diagnostic Settings.
var AZDS_AKST3 = json(loadTextContent('./tier3/AZDS_AKS.json'))
resource akst3policy 'Microsoft.Authorization/policyDefinitions@2023-04-01' = {
  name: 'AZDS_AKST3'
  properties: AZDS_AKST3.properties
}
module azakst3deploy './polassign.bicep' = {
  name: 'AZDS_AKST3Deployment'
  scope: managementGroup(managementgroup)
  params:{
    policyassignname: 'AZDS_AKST3'
    policydefinitionid: akst3policy.id
    policydescription: akst3policy.properties.description
    azdsumiid: azdsmanagedidentity.outputs.mirid
    loganalyticsregion: loganalyticsregion
    loganalyticsrid: loganalytics1rid
  }
  dependsOn: [
    akst3policy
  ]
}
