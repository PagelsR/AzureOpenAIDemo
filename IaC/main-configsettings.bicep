param keyvaultName string
param webappName string
param functionAppName string
param kvValue_AzureWebJobsStorageName string
param kvValue_ApimSubscriptionKeyName string
param kvValue_WebsiteContentAzureFileConnectionStringName string
param appInsightsInstrumentationKey string
param appInsightsConnectionString string
//param webhookEndpoint string
param ApimWebServiceURL string
param Deployed_Environment string
param kvValue_OpenAIAPIKeyStringName string
param apiServiceName string

@secure()
param appServiceprincipalId string

@secure()
param funcAppServiceprincipalId string

@secure()
param ApiManagementprincipalId string

@secure()
param kvValue_AzureWebJobsStorageValue string

@secure()
param kvValue_ApimSubscriptionKeyValue string

@secure()
param kvValue_OpenAIAPIKeyValue string

param tenant string = subscription().tenantId

@secure()
param AzObjectIdPagels string

@secure()
param ADOServiceprincipalObjectId string

// Define KeyVault accessPolicies
param accessPolicies array = [
  {
    tenantId: tenant
    objectId: appServiceprincipalId
    permissions: {
      keys: [
        'get'
        'list'
      ]
      secrets: [
        'get'
        'list'
      ]
    }
  }
  {
    tenantId: tenant
    objectId: funcAppServiceprincipalId
    permissions: {
      keys: [
        'get'
        'list'
      ]
      secrets: [
        'get'
        'list'
      ]
    }
  }
  {
    tenantId: tenant
    objectId: ApiManagementprincipalId
    permissions: {
      keys: [
        'get'
        'list'
      ]
      secrets: [
        'get'
        'list'
      ]
    }
  }
  {
    tenantId: tenant
    objectId: AzObjectIdPagels
    permissions: {
      keys: [
        'get'
        'list'
      ]
      secrets: [
        'get'
        'list'
        'set'
        'delete'
      ]
    }
  }
  {
    tenantId: tenant
    objectId: ADOServiceprincipalObjectId
    permissions: {
      keys: [
        'get'
        'list'
      ]
      secrets: [
        'get'
        'list'
        'set'
      ]
    }
  }
]

// Reference Existing resource
resource existing_keyvault 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
  name: keyvaultName
}

// Create KeyVault accessPolicies
resource keyvaultaccessmod 'Microsoft.KeyVault/vaults/accessPolicies@2022-07-01' = {
  name: 'add'
  parent: existing_keyvault
  properties: {
    accessPolicies: accessPolicies
  }
}

// Create KeyVault Secrets

//create secret for Func App
resource secret3 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  name: kvValue_AzureWebJobsStorageName
  parent: existing_keyvault
  properties: {
    contentType: 'text/plain'
    value: kvValue_AzureWebJobsStorageValue
  }
}
// create secret for Func App
resource secret4 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  name: kvValue_WebsiteContentAzureFileConnectionStringName
  parent: existing_keyvault
  properties: {
    contentType: 'text/plain'
    value: kvValue_AzureWebJobsStorageValue
  }
}
// create secret for APIM
resource secret5 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  name: kvValue_ApimSubscriptionKeyName
  parent: existing_keyvault
  properties: {
    contentType: 'text/plain'
    value: kvValue_ApimSubscriptionKeyValue
  }
}
// create secret for APIM
resource secret6 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  name: kvValue_OpenAIAPIKeyStringName
  parent: existing_keyvault
  properties: {
    contentType: 'text/plain'
    value: kvValue_OpenAIAPIKeyValue
  }
}

// Reference Existing resource
resource existing_appService 'Microsoft.Web/sites@2022-03-01' existing = {
  name: webappName
}

// Create Web sites/config 'appsettings' - Web App
resource webSiteAppSettingsStrings 'Microsoft.Web/sites/config@2022-03-01' = {
  name: 'appsettings'
  parent: existing_appService
  properties: {
    DeployedEnvironment: Deployed_Environment
    WEBSITE_RUN_FROM_PACKAGE: '1'
    WEBSITE_SENTINEL: '1'
    APPINSIGHTS_INSTRUMENTATIONKEY: appInsightsInstrumentationKey
    APPINSIGHTS_PROFILERFEATURE_VERSION: '1.0.0'
    APPINSIGHTS_SNAPSHOTFEATURE_VERSION: '1.0.0'
    APPLICATIONINSIGHTS_CONNECTION_STRING: appInsightsConnectionString
    OpenAIAPIKey: '@Microsoft.KeyVault(VaultName=${keyvaultName};SecretName=${kvValue_OpenAIAPIKeyStringName})'
    WebAppUrl: 'https://${existing_appService.name}.azurewebsites.net/'
    ASPNETCORE_ENVIRONMENT: 'Development'
    WEBSITE_ENABLE_SYNC_UPDATE_SITE: 'true'
  }
}

// Reference Existing resource
resource existing_funcAppService 'Microsoft.Web/sites@2022-03-01' existing = {
  name: functionAppName
}
// Create Web sites/config 'appsettings' - Function App
resource funcAppSettingsStrings 'Microsoft.Web/sites/config@2022-03-01' = {
  name: 'appsettings'
  kind: 'string'
  parent: existing_funcAppService
  properties: {
    AzureWebJobsStorage: '@Microsoft.KeyVault(VaultName=${keyvaultName};SecretName=${kvValue_AzureWebJobsStorageName})'
    WebsiteContentAzureFileConnectionString: '@Microsoft.KeyVault(VaultName=${keyvaultName};SecretName=${kvValue_WebsiteContentAzureFileConnectionStringName})'
    ApimSubscriptionKey: '@Microsoft.KeyVault(VaultName=${keyvaultName};SecretName=${kvValue_ApimSubscriptionKeyName})'
    ApimWebServiceURL: ApimWebServiceURL
    OpenAIAPIKey: '@Microsoft.KeyVault(VaultName=${keyvaultName};SecretName=${kvValue_OpenAIAPIKeyStringName})'
    APPINSIGHTS_INSTRUMENTATIONKEY: appInsightsInstrumentationKey
    APPLICATIONINSIGHTS_CONNECTION_STRING: appInsightsConnectionString
    FUNCTIONS_WORKER_RUNTIME: 'dotnet'
    FUNCTIONS_EXTENSION_VERSION: '~4'
  }
  dependsOn: [
    secret3
    secret4
  ]
}

// Reference Existing resource
resource existing_apiManagement 'Microsoft.ApiManagement/service@2022-04-01-preview' existing = {
  name: apiServiceName
}
// Create API Management Named Values
resource apiManagementNamedValuesOpenAIAPIKey 'Microsoft.ApiManagement/service/namedValues@2022-04-01-preview' = {
  parent: existing_apiManagement
  name: 'OpenAIAPIKey'
  properties: {
    displayName: 'OpenAIAPIKey'
    keyVault: {
      secretIdentifier: 'https://${existing_keyvault.name}.vault.azure.net/secrets/OpenAIAPIKey'
    }
    tags: []
    secret: true
  }
}

// Reference Existing resource
resource existing_apiManagementOpenAIAPIs 'Microsoft.ApiManagement/service/apis@2022-04-01-preview' existing = {
  name: apiServiceName
}

// Create API Management API Policy
resource apiPolicy 'Microsoft.ApiManagement/service/apis/policies@2022-04-01-preview' = {
  parent: existing_apiManagementOpenAIAPIs
  name: 'policy'
  properties: {
    format: 'rawxml'
    value: loadTextContent('./policy_API.xml')
  }
  dependsOn: [
    apiManagementNamedValuesOpenAIAPIKey
  ]
}

