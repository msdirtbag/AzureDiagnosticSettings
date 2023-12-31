//This bicep deploys the Azure Policy.

//Scope
targetScope = 'managementGroup'

//Variables
var managementgroup = tenant().tenantId

//Parameters
param loganalyticsregion string
param loganalyticsrid string
param azdsumiid string
param policydefinitionid string
param policyassignname string
param policydescription string
param ntastorageid string
param nsgflowlogworkspaceid string

//Resources

//This deploys the Azure Policy Assignment.
resource policyas 'Microsoft.Authorization/policyAssignments@2022-06-01' = {
  name: '${policyassignname}'
  location: loganalyticsregion
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${azdsumiid}': {}
    }
  }
  properties: {
    description: policydescription
    displayName: '${policyassignname}'
    policyDefinitionId: policydefinitionid
    parameters: {
      workspaceResourceId: {
          value: loganalyticsrid
        } 
      nsgRegion: {
          value: loganalyticsregion
        }
      storageId: {
          value: ntastorageid
        }
      workspaceRegion: {
          value: loganalyticsregion
        }
      workspaceId: {
          value: nsgflowlogworkspaceid
        }
      networkWatcherRG: {
          value: 'NetworkWatcherRG'
        }
      networkWatcherName: {
          value: 'NetworkWatcher_${loganalyticsregion}'
        }
      }
    }
}
