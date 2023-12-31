//This bicep configures the Entra Diagnotic Settings.

//Scope
targetScope = 'tenant'

//Variables

//Parameters
param laworkspacerid string

//Resources
resource entradiagsettings 'microsoft.aadiam/diagnosticSettings@2017-04-01' = {
  name: 'AZDS_EntraID'
  scope: tenant()
  properties: {
    logs: [
      {
        category: 'AuditLogs'
        enabled: true
      }
      {
        category: 'SignInLogs'
        enabled: true
      }
      {
        category: 'ADFSSignInLogs'
        enabled: true
      }
      {
        category: 'NonInteractiveUserSignInLogs'
        enabled: true
      }
      {
        category: 'ManagedIdentitySignInLogs'
        enabled: true
      }
      {
        category: 'ServicePrincipalSignInLogs'
        enabled: true
      }
      {
        category: 'EnrichedOffice365AuditLogs'
        enabled: true
      }
      {
        category: 'MicrosoftGraphActivityLogs'
        enabled: true
      }
      {
        category: 'NetworkAccessTrafficLogs'
        enabled: true
      }
      {
        category: 'RiskyServicePrincipals'
        enabled: true
      }
      {
        category: 'RiskyUsers'
        enabled: true
      }
      {
        category: 'UserRiskEvents'
        enabled: true
      }
      {
        category: 'ServicePrincipalRiskEvents'
        enabled: true
      }
    ]
    workspaceId: laworkspacerid
  }
}


