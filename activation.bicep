//This bicep deploys the Azure Policy remediation tasks.

//Scope
targetScope = 'resourceGroup'

//Variables

//Parameters
param location string
param azdsumiid string

//Resources

resource compliancescanscript 'Microsoft.Resources/deploymentScripts@2023-08-01' = {
  name: 'deployscript-compliance-azds-azpolicy'
  location: location
  kind: 'AzurePowerShell'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${azdsumiid}' : {}
    }
  }
  properties: {
    azPowerShellVersion: '11.0.0'
    retentionInterval: 'P1D'
    scriptContent: '''
      $TenantRoot = (Get-AzContext).Tenant.Id
      $Subscriptions = Get-AzSubscription
      foreach ($sub in $Subscriptions) {
        Get-AzSubscription -SubscriptionName $sub.Name | Set-AzContext
        Start-AzPolicyComplianceScan -AsJob | Wait-Job
      }
    '''
  }
}

resource remediationscript 'Microsoft.Resources/deploymentScripts@2023-08-01' = {
  name: 'deployscript-remediation-azds-azpolicy'
  location: location
  kind: 'AzurePowerShell'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${azdsumiid}' : {}
    }
  }
  properties: {
    azPowerShellVersion: '11.0.0'
    retentionInterval: 'P1D'
    scriptContent: '''
      $TenantRoot = (Get-AzContext).Tenant.Id
      Start-AzPolicyRemediation -ManagementGroupName $TenantRoot -Name 'AMA_Windows' -PolicyAssignmentId /providers/Microsoft.Management/managementGroups/$TenantRoot/providers/Microsoft.Authorization/policyAssignments/AMA_Windows -ResourceCount 10000 -ParallelDeploymentCount 30 -AsJob | Wait-Job
      Start-AzPolicyRemediation -ManagementGroupName $TenantRoot -Name 'AMA_Linux' -PolicyAssignmentId /providers/Microsoft.Management/managementGroups/$TenantRoot/providers/Microsoft.Authorization/policyAssignments/AMA_Linux -ResourceCount 10000 -ParallelDeploymentCount 30 -AsJob | Wait-Job
      Start-AzPolicyRemediation -ManagementGroupName $TenantRoot -Name 'DCR_Windows' -PolicyAssignmentId /providers/Microsoft.Management/managementGroups/$TenantRoot/providers/Microsoft.Authorization/policyAssignments/DCR_Windows -ResourceCount 10000 -ParallelDeploymentCount 30 -AsJob | Wait-Job
      Start-AzPolicyRemediation -ManagementGroupName $TenantRoot -Name 'DCR_Linux' -PolicyAssignmentId /providers/Microsoft.Management/managementGroups/$TenantRoot/providers/Microsoft.Authorization/policyAssignments/DCR_Linux -ResourceCount 10000 -ParallelDeploymentCount 30 -AsJob | Wait-Job
      Start-AzPolicyRemediation -ManagementGroupName $TenantRoot -Name 'VMI_DCR_Windows' -PolicyAssignmentId /providers/Microsoft.Management/managementGroups/$TenantRoot/providers/Microsoft.Authorization/policyAssignments/VMI_DCR_Windows -ResourceCount 10000 -ParallelDeploymentCount 30 -AsJob | Wait-Job
      Start-AzPolicyRemediation -ManagementGroupName $TenantRoot -Name 'VMI_DCR_Linux' -PolicyAssignmentId /providers/Microsoft.Management/managementGroups/$TenantRoot/providers/Microsoft.Authorization/policyAssignments/VMI_DCR_Linux -ResourceCount 10000 -ParallelDeploymentCount 30 -AsJob | Wait-Job
      Start-AzPolicyRemediation -ManagementGroupName $TenantRoot -Name 'AZDS_AzActivity' -PolicyAssignmentId /providers/Microsoft.Management/managementGroups/$TenantRoot/providers/Microsoft.Authorization/policyAssignments/AZDS_AzActivity -ResourceCount 10000 -ParallelDeploymentCount 30 -AsJob | Wait-Job
      Start-AzPolicyRemediation -ManagementGroupName $TenantRoot -Name 'AZDS_AKST1' -PolicyAssignmentId /providers/Microsoft.Management/managementGroups/$TenantRoot/providers/Microsoft.Authorization/policyAssignments/AZDS_AKST1 -ResourceCount 10000 -ParallelDeploymentCount 30 -AsJob | Wait-Job
      Start-AzPolicyRemediation -ManagementGroupName $TenantRoot -Name 'AZDS_BAS' -PolicyAssignmentId /providers/Microsoft.Management/managementGroups/$TenantRoot/providers/Microsoft.Authorization/policyAssignments/AZDS_BAS -ResourceCount 10000 -ParallelDeploymentCount 30 -AsJob | Wait-Job
      Start-AzPolicyRemediation -ManagementGroupName $TenantRoot -Name 'AZDS_RSV' -PolicyAssignmentId /providers/Microsoft.Management/managementGroups/$TenantRoot/providers/Microsoft.Authorization/policyAssignments/AZDS_RSV -ResourceCount 10000 -ParallelDeploymentCount 30 -AsJob | Wait-Job
      Start-AzPolicyRemediation -ManagementGroupName $TenantRoot -Name 'AZDS_ACR' -PolicyAssignmentId /providers/Microsoft.Management/managementGroups/$TenantRoot/providers/Microsoft.Authorization/policyAssignments/AZDS_ACR -ResourceCount 10000 -ParallelDeploymentCount 30 -AsJob | Wait-Job
      Start-AzPolicyRemediation -ManagementGroupName $TenantRoot -Name 'AZDS_KV' -PolicyAssignmentId /providers/Microsoft.Management/managementGroups/$TenantRoot/providers/Microsoft.Authorization/policyAssignments/AZDS_KV -ResourceCount 10000 -ParallelDeploymentCount 30 -AsJob | Wait-Job
      Start-AzPolicyRemediation -ManagementGroupName $TenantRoot -Name 'AZDS_AG' -PolicyAssignmentId /providers/Microsoft.Management/managementGroups/$TenantRoot/providers/Microsoft.Authorization/policyAssignments/AZDS_AG -ResourceCount 10000 -ParallelDeploymentCount 30 -AsJob | Wait-Job
      Start-AzPolicyRemediation -ManagementGroupName $TenantRoot -Name 'AZDS_FD' -PolicyAssignmentId /providers/Microsoft.Management/managementGroups/$TenantRoot/providers/Microsoft.Authorization/policyAssignments/AZDS_FD -ResourceCount 10000 -ParallelDeploymentCount 30 -AsJob | Wait-Job
      Start-AzPolicyRemediation -ManagementGroupName $TenantRoot -Name 'AZDS_Firewall' -PolicyAssignmentId /providers/Microsoft.Management/managementGroups/$TenantRoot/providers/Microsoft.Authorization/policyAssignments/AZDS_Firewall -ResourceCount 10000 -ParallelDeploymentCount 30 -AsJob | Wait-Job
      Start-AzPolicyRemediation -ManagementGroupName $TenantRoot -Name 'AZDS_NSG' -PolicyAssignmentId /providers/Microsoft.Management/managementGroups/$TenantRoot/providers/Microsoft.Authorization/policyAssignments/AZDS_NSG -ResourceCount 10000 -ParallelDeploymentCount 30 -AsJob | Wait-Job
      Start-AzPolicyRemediation -ManagementGroupName $TenantRoot -Name 'AZDS_NSGFLOW' -PolicyAssignmentId /providers/Microsoft.Management/managementGroups/$TenantRoot/providers/Microsoft.Authorization/policyAssignments/AZDS_NSGFLOW -ResourceCount 10000 -ParallelDeploymentCount 30 -AsJob | Wait-Job
      Start-AzPolicyRemediation -ManagementGroupName $TenantRoot -Name 'AZDS_ACI' -PolicyAssignmentId /providers/Microsoft.Management/managementGroups/$TenantRoot/providers/Microsoft.Authorization/policyAssignments/AZDS_ACI -ResourceCount 10000 -ParallelDeploymentCount 30 -AsJob | Wait-Job
      Start-AzPolicyRemediation -ManagementGroupName $TenantRoot -Name 'AZDS_APIM' -PolicyAssignmentId /providers/Microsoft.Management/managementGroups/$TenantRoot/providers/Microsoft.Authorization/policyAssignments/AZDS_APIM -ResourceCount 10000 -ParallelDeploymentCount 30 -AsJob | Wait-Job
      Start-AzPolicyRemediation -ManagementGroupName $TenantRoot -Name 'AZDS_APPI' -PolicyAssignmentId /providers/Microsoft.Management/managementGroups/$TenantRoot/providers/Microsoft.Authorization/policyAssignments/AZDS_APPI -ResourceCount 10000 -ParallelDeploymentCount 30 -AsJob | Wait-Job
      Start-AzPolicyRemediation -ManagementGroupName $TenantRoot -Name 'AZDS_AppService' -PolicyAssignmentId /providers/Microsoft.Management/managementGroups/$TenantRoot/providers/Microsoft.Authorization/policyAssignments/AZDS_AppService -ResourceCount 10000 -ParallelDeploymentCount 30 -AsJob | Wait-Job
      Start-AzPolicyRemediation -ManagementGroupName $TenantRoot -Name 'AZDS_CosmosDB' -PolicyAssignmentId /providers/Microsoft.Management/managementGroups/$TenantRoot/providers/Microsoft.Authorization/policyAssignments/AZDS_CosmosDB -ResourceCount 10000 -ParallelDeploymentCount 30 -AsJob | Wait-Job
      Start-AzPolicyRemediation -ManagementGroupName $TenantRoot -Name 'AZDS_Func' -PolicyAssignmentId /providers/Microsoft.Management/managementGroups/$TenantRoot/providers/Microsoft.Authorization/policyAssignments/AZDS_Func -ResourceCount 10000 -ParallelDeploymentCount 30 -AsJob | Wait-Job
      Start-AzPolicyRemediation -ManagementGroupName $TenantRoot -Name 'AZDS_LA' -PolicyAssignmentId /providers/Microsoft.Management/managementGroups/$TenantRoot/providers/Microsoft.Authorization/policyAssignments/AZDS_LA -ResourceCount 10000 -ParallelDeploymentCount 30 -AsJob | Wait-Job
      Start-AzPolicyRemediation -ManagementGroupName $TenantRoot -Name 'AZDS_PIP' -PolicyAssignmentId /providers/Microsoft.Management/managementGroups/$TenantRoot/providers/Microsoft.Authorization/policyAssignments/AZDS_PIP -ResourceCount 10000 -ParallelDeploymentCount 30 -AsJob | Wait-Job
      Start-AzPolicyRemediation -ManagementGroupName $TenantRoot -Name 'AZDS_PSQL' -PolicyAssignmentId /providers/Microsoft.Management/managementGroups/$TenantRoot/providers/Microsoft.Authorization/policyAssignments/AZDS_PSQL -ResourceCount 10000 -ParallelDeploymentCount 30 -AsJob | Wait-Job
      Start-AzPolicyRemediation -ManagementGroupName $TenantRoot -Name 'AZDS_SQL' -PolicyAssignmentId /providers/Microsoft.Management/managementGroups/$TenantRoot/providers/Microsoft.Authorization/policyAssignments/AZDS_SQL -ResourceCount 10000 -ParallelDeploymentCount 30 -AsJob | Wait-Job
      Start-AzPolicyRemediation -ManagementGroupName $TenantRoot -Name 'AZDS_SQLM' -PolicyAssignmentId /providers/Microsoft.Management/managementGroups/$TenantRoot/providers/Microsoft.Authorization/policyAssignments/AZDS_SQLM -ResourceCount 10000 -ParallelDeploymentCount 30 -AsJob | Wait-Job
      Start-AzPolicyRemediation -ManagementGroupName $TenantRoot -Name 'AZDS_Storage' -PolicyAssignmentId /providers/Microsoft.Management/managementGroups/$TenantRoot/providers/Microsoft.Authorization/policyAssignments/AZDS_Storage -ResourceCount 10000 -ParallelDeploymentCount 30 -AsJob | Wait-Job
      Start-AzPolicyRemediation -ManagementGroupName $TenantRoot -Name 'AZDS_Auto' -PolicyAssignmentId /providers/Microsoft.Management/managementGroups/$TenantRoot/providers/Microsoft.Authorization/policyAssignments/AZDS_Auto -ResourceCount 10000 -ParallelDeploymentCount 30 -AsJob | Wait-Job
      Start-AzPolicyRemediation -ManagementGroupName $TenantRoot -Name 'AZDS_AKST3' -PolicyAssignmentId /providers/Microsoft.Management/managementGroups/$TenantRoot/providers/Microsoft.Authorization/policyAssignments/AZDS_AKST3 -ResourceCount 10000 -ParallelDeploymentCount 30 -AsJob | Wait-Job
      '''
  }
  dependsOn: [
    compliancescanscript
  ]
}

//Outputs
