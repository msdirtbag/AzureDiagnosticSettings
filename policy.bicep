//Scope
targetScope = 'managementGroup'

//Variables

//Parameters
param loganalyticsregion string
param azmanagedidentity string
param mgmtresourcegroup string
param muasminame string
param commondcrid string
param linuxdcrid string
param vmiid string

//Resources

//Azure Policy Assignments (built-in)
resource Policy1 'Microsoft.Authorization/policyAssignments@2023-04-01' = {
  name: 'AMA_Windows'
  location: loganalyticsregion
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${azmanagedidentity}': {}
    }
  }
  properties: {
    displayName: 'AMA_Windows'
    parameters: {
      bringYourOwnUserAssignedManagedIdentity:{
        value: true
      }
      userAssignedManagedIdentityName:{
        value: muasminame
      }
      userAssignedManagedIdentityResourceGroup:{
        value: mgmtresourcegroup
      }
      scopeToSupportedImages:{
        value: true
      }
    }
    policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/637125fd-7c39-4b94-bb0a-d331faf333a9'
  }
}

resource Policy2 'Microsoft.Authorization/policyAssignments@2023-04-01' = {
  name: 'AMA_Linux'
  location: loganalyticsregion
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${azmanagedidentity}': {}
    }
  }
  properties: {
    displayName: 'AMA_Linux'
    parameters: {
      bringYourOwnUserAssignedManagedIdentity:{
        value: true
      }
      userAssignedManagedIdentityName:{
        value: muasminame
      }
      userAssignedManagedIdentityResourceGroup:{
        value: mgmtresourcegroup
      }
      scopeToSupportedImages:{
        value: true
      }
    }
    policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/ae8a10e6-19d6-44a3-a02d-a2bdfc707742'
  }
}

resource Policy3 'Microsoft.Authorization/policyAssignments@2023-04-01' = {
  name: 'DCR_Windows'
  location: loganalyticsregion
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${azmanagedidentity}': {}
    }
  }
  properties: {
    displayName: 'DCR_Windows'
    parameters: {
      dcrResourceId:{
        value: commondcrid
      }
    }
    policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/244efd75-0d92-453c-b9a3-7d73ca36ed52'
  }
}

resource Policy4 'Microsoft.Authorization/policyAssignments@2023-04-01' = {
  name: 'DCR_Linux'
  location: loganalyticsregion
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${azmanagedidentity}': {}
    }
  }
  properties: {
    displayName: 'DCR_Linux'
    parameters: {
      dcrResourceId:{
        value: linuxdcrid
      }
    }
    policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/58e891b9-ce13-4ac3-86e4-ac3e1f20cb07'
  }
}

resource Policy5 'Microsoft.Authorization/policyAssignments@2023-04-01' = {
  name: 'VMI_DCR_Linux'
  location: loganalyticsregion
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${azmanagedidentity}': {}
    }
  }
  properties: {
    displayName: 'VMI_DCR_Linux'
    parameters: {
      dcrResourceId:{
        value: vmiid
      }
    }
    policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/58e891b9-ce13-4ac3-86e4-ac3e1f20cb07'
  }
}

resource Policy6 'Microsoft.Authorization/policyAssignments@2023-04-01' = {
  name: 'VMI_DCR_Windows'
  location: loganalyticsregion
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${azmanagedidentity}': {}
    }
  }
  properties: {
    displayName: 'VMI_DCR_Windows'
    parameters: {
      dcrResourceId:{
        value: vmiid
      }
    }
    policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/244efd75-0d92-453c-b9a3-7d73ca36ed52'
  }
}
