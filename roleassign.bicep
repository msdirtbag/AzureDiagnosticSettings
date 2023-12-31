//Scope
targetScope = 'managementGroup'

//Variables
var contributorrole = '/providers/Microsoft.Authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c'
var monitoringrole = '/providers/Microsoft.Authorization/roleDefinitions/749f88d5-cbae-40b8-bcfc-e573ddc772fa'
var lacontributor = '/providers/Microsoft.Authorization/roleDefinitions/92aaf0da-9dab-42b6-94a3-d43ce8d16293'

//Parameters
param principalId string 
param automationaccountpid string

//Resources

//This deploys the Contributor role assignment.
resource umicontributorroleassign 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(principalId, contributorrole, managementGroup().id)
  properties: {
    roleDefinitionId: contributorrole
    principalId: principalId
    principalType: 'ServicePrincipal'
  }
}

//This deploys the Contributor role assignment.
resource autocontributorroleassign 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(automationaccountpid, contributorrole, managementGroup().id)
  properties: {
    roleDefinitionId: contributorrole
    principalId: principalId
    principalType: 'ServicePrincipal'
  }
}

//This deploys the Monitoring Contributor role assignment.
resource monitoringroleassign 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(principalId, monitoringrole, managementGroup().id)
  properties: {
    roleDefinitionId: monitoringrole
    principalId: principalId
    principalType: 'ServicePrincipal'
  }
}

//This deploys the Log Analytics Contributor role assignment.
resource lacontributorroleassign 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(principalId, lacontributor, managementGroup().id)
  properties: {
    roleDefinitionId: lacontributor
    principalId: principalId
    principalType: 'ServicePrincipal'
  }
}
