//Scope
targetScope = 'subscription'
//Variables

//Parameters
param loganalyticsregion string
param mgmtresourcegroup string

//Resources

//This is the resource group that holds the AZDS resources.
resource managmentresourcegroup 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: mgmtresourcegroup
  location: loganalyticsregion
}


