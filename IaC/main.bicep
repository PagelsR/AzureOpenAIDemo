// Deploy Azure infrastructure for app + data + monitoring

//targetScope = 'subscription'
// Region for all resources
param location string = resourceGroup().location
param appName string = 'Azure OpenAI Demo'
param createdBy string = 'Randy Pagels'
param costCenter string = 'Visual Studio Ent – MPN - RPagels'
param Deployed_Environment string

// Variables for Recommended abbreviations for Azure resource types
// https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations
var webAppPlanName = 'plan-${uniqueString(resourceGroup().id)}'
var webSiteName = 'app-${uniqueString(resourceGroup().id)}'
var appInsightsName = 'appi-${uniqueString(resourceGroup().id)}'
var appInsightsWorkspaceName = 'appw-${uniqueString(resourceGroup().id)}'
var appInsightsAlertName = 'ResponseTime-${uniqueString(resourceGroup().id)}'
var functionAppName = 'func-${uniqueString(resourceGroup().id)}'
var functionAppServiceName = 'funcplan-${uniqueString(resourceGroup().id)}'
var apiServiceName = 'apim-${uniqueString(resourceGroup().id)}'
var keyvaultName = 'kv-${uniqueString(resourceGroup().id)}'
var cognitiveServiceName = 'openai-${uniqueString(resourceGroup().id)}'

// Tags
var defaultTags = {
  Env: Deployed_Environment
  App: appName
  CostCenter: costCenter
  CreatedBy: createdBy
}

// KeyVault Secret Names
param kvValue_ApimSubscriptionKeyName string = 'ApimSubscriptionKey'
param kvValue_OpenAIAPIKeyName string = 'OpenAIAPIKey'
param kvValue_OpenAIAPIKeyValue string = 'OpenAIAPIKeyGoesHere'
param kvValue_AzureWebJobsStorageName string = 'AzureWebJobsStorage'
param kvValue_WebsiteContentAzureFileConnectionString string = 'WebsiteContentAzureFileConnectionString'

// Create Azure KeyVault
module keyvaultmod './main-keyvault.bicep' = {
  name: keyvaultName
  params: {
    location: location
    vaultName: keyvaultName
    }
 }
 
// Create Web App
module webappmod './main-webapp.bicep' = {
  name: 'webappdeploy'
  params: {
    webAppPlanName: webAppPlanName
    webSiteName: webSiteName
    resourceGroupName: resourceGroup().name
    Deployed_Environment: Deployed_Environment
    appInsightsName: appInsightsName
    location: location
    appInsightsInstrumentationKey: appinsightsmod.outputs.out_appInsightsInstrumentationKey
    appInsightsConnectionString: appinsightsmod.outputs.out_appInsightsConnectionString
    defaultTags: defaultTags
  }
}

// Create Application Insights
module appinsightsmod './main-appinsights.bicep' = {
  name: 'appinsightsdeploy'
  params: {
    location: location
    appInsightsName: appInsightsName
    defaultTags: defaultTags
    appInsightsAlertName: appInsightsAlertName
    appInsightsWorkspaceName: appInsightsWorkspaceName
  }
}

// Create Function App
module functionappmod './main-funcapp.bicep' = {
  name: 'functionappdeploy'
  params: {
    location: location
    functionAppServiceName: functionAppServiceName
    functionAppName: functionAppName
    defaultTags: defaultTags
  }
  dependsOn:  [
    appinsightsmod
  ]
}

// Create API Management
module apimservicemod './main-apimanagement.bicep' = {
  name: apiServiceName
    params: {
    location: location
    defaultTags: defaultTags
    apiServiceName: apiServiceName
    appInsightsName: appInsightsName
    applicationInsightsID: appinsightsmod.outputs.out_applicationInsightsID
    appInsightsInstrumentationKey: appinsightsmod.outputs.out_appInsightsInstrumentationKey
  }
  dependsOn:  [
    appinsightsmod
    keyvaultmod
  ]
}

// Errors out during deployment.
// "UpdatingCustomDomainNotAllowed", "message": "Updating or disabling sub domain is not supported."***
//
// module cognitiveservicemod './main-cognitiveservice.bicep' = {
//   name: cognitiveServiceName
//   params: {
//     defaultTags: defaultTags
//     cognitiveServiceName: cognitiveServiceName
//     location: location
//   }
// }

//param AzObjectIdPagels string = 'b6be0700-1fda-4f88-bf20-1aa508a91f73'
param AzObjectIdPagels string = '197b8610-80f8-4317-b9c4-06e5b3246e87'

// Application Id of Service Principal "ServicePrincipal_FullSubscriptionAccess"
param ADOServiceprincipalObjectId string = 'd589e43b-c408-431e-bb55-73232bab26a3'

// Create Configuration Entries
module configsettingsmod './main-configsettings.bicep' = {
  name: 'configSettings'
  params: {
    keyvaultName: keyvaultName
    appServiceprincipalId: webappmod.outputs.out_appServiceprincipalId
    webappName: webSiteName
    functionAppName: functionAppName
    funcAppServiceprincipalId: functionappmod.outputs.out_funcAppServiceprincipalId
    ApiManagementprincipalId: apimservicemod.outputs.out_ApiManagementprincipalId
    kvValue_AzureWebJobsStorageName: kvValue_AzureWebJobsStorageName
    kvValue_AzureWebJobsStorageValue: functionappmod.outputs.out_AzureWebJobsStorage
    kvValue_WebsiteContentAzureFileConnectionStringName: kvValue_WebsiteContentAzureFileConnectionString
    kvValue_ApimSubscriptionKeyName: kvValue_ApimSubscriptionKeyName
    kvValue_ApimSubscriptionKeyValue: apimservicemod.outputs.out_ApimSubscriptionKeyString
    kvValue_OpenAIAPIKeyStringName: kvValue_OpenAIAPIKeyName
    kvValue_OpenAIAPIKeyValue: kvValue_OpenAIAPIKeyValue
    appInsightsInstrumentationKey: appinsightsmod.outputs.out_appInsightsInstrumentationKey
    appInsightsConnectionString: appinsightsmod.outputs.out_appInsightsConnectionString
    Deployed_Environment: Deployed_Environment
    ApimWebServiceURL: apimservicemod.outputs.out_ApimWebServiceURL
    AzObjectIdPagels: AzObjectIdPagels
    ADOServiceprincipalObjectId: ADOServiceprincipalObjectId
    apiServiceName: apiServiceName
    }
    dependsOn:  [
     keyvaultmod
     webappmod
     functionappmod
     apimservicemod
   ]
 }

 // NOT NEEDED! Using Key Vault Access Policies instead
 // Add Role Assignments
// module roleAssignments './main-RoleAssignments.bicep' = {
//   name: 'addRoleAssignments'
//   params: {
//     keyvaultName: keyvaultName
//     ApiManagementprincipalId: apimservicemod.outputs.out_ApiManagementprincipalId
//   }
//   dependsOn:  [
//     keyvaultmod
//     apimservicemod
//   ]
// }

// Output Params used for IaC deployment in pipeline
output out_webSiteName string = webSiteName
output out_appInsightsName string = appInsightsName
output out_functionAppName string = functionAppName
output out_apiServiceName string = apiServiceName
output out_apimSubscriptionKey string = apimservicemod.outputs.out_ApimSubscriptionKeyString
output out_OpenAIKeyValue string = kvValue_OpenAIAPIKeyValue
//output out_AzureOpenAIKeyValue string = cognitiveservicemod.outputs.out_cognitiveServiceKeyString
output out_keyvaultName string = keyvaultName
output out_appInsightsApplicationId string = appinsightsmod.outputs.out_appInsightsApplicationId
output out_appInsightsAPIApplicationId string = appinsightsmod.outputs.out_appInsightsAPIApplicationId

