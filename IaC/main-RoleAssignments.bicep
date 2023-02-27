// param principalId string
param keyvaultName string
// param apiServiceName string
@secure()
param ApiManagementprincipalId string


// Add role assigment for Service Identity - acrPull
// Azure built-in roles - https://docs.microsoft.com/en-us/azure/role-based-access-control/built-in-roles
param roleDefinitionIdForReader string = 'acdd72a7-3385-48ef-bd42-f606fba81ae7'
var secretUserRole = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleDefinitionIdForReader)

// Reference Existing resource
resource existing_keyvault 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
  name: keyvaultName
}

// Add role assignment to Key Value
resource roleAssignmentForKeyVault 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(existing_keyvault.id, secretUserRole)
  scope: existing_keyvault
  properties: {
    principalId: ApiManagementprincipalId
    roleDefinitionId: secretUserRole
  }
}
