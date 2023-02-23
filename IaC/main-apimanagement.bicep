// The following will create an Azure APIM instance

param location string = resourceGroup().location
param apiServiceName string
param appInsightsName string
param applicationInsightsID string
param appInsightsInstrumentationKey string
param webSiteName string

param defaultTags object

@minLength(1)
param publisherEmail string = 'rpagels@microsoft.com'

@minLength(1)
param publisherName string = 'Randy Pagels'

// Use 'Developer' or 'Consumption'
@allowed([
  'Consumption'
  'Developer'
  'Basic'
  'Standard'
  'Premium'
])
param sku string = 'Developer'

// Developer = 1, Consumption = 0
param skuCount int = 1

///////////////////////////////////////////
// Create API Management Service Definition
///////////////////////////////////////////
resource apiManagement 'Microsoft.ApiManagement/service@2022-04-01-preview' = {
  name: apiServiceName
  location: location
  tags: defaultTags
  sku: {
    name: sku
    capacity: skuCount
  }
  properties: {
    publisherEmail: publisherEmail
    publisherName: publisherName
  }
  identity: {
    type: 'SystemAssigned'
  }
}

///////////////////////////////////////////
// Create the Subscription for Developers
///////////////////////////////////////////
resource apiManagementSubscription 'Microsoft.ApiManagement/service/subscriptions@2022-04-01-preview' = {
  parent: apiManagement
  name: 'Developers'
  properties: {
    scope: '/apis'
    displayName: 'OpenAI Developers'
    state: 'active'
  }
}

///////////////////////////////////////////
// Create a Product
///////////////////////////////////////////
resource apiManagementProduct 'Microsoft.ApiManagement/service/products@2022-04-01-preview' = {
  parent: apiManagement
  name: 'Development'
  properties: {
    approvalRequired: false
    state: 'published'
    subscriptionRequired: true
    subscriptionsLimit: 1
    description: 'Product used for OpenAI Development Teams'
    displayName: 'OpenAI Developers'
     terms: 'These are the terms of use ... .etc'
  }
}

///////////////////////////////////////////
// Create Policy for Product Definitions 
///////////////////////////////////////////
// resource apiManagementProductPolicies 'Microsoft.ApiManagement/service/products/policies@2022-04-01-preview' = {
//   parent: apiManagementProduct
//   name: 'policy'
//   properties: {
//     format: 'rawxml'
//     value: loadTextContent('./policy_Products.xml')
//   }
// }

///////////////////////////////////////////
// Create API Service Definition
///////////////////////////////////////////
resource apiManagementOpenAIAPIs 'Microsoft.ApiManagement/service/apis@2022-04-01-preview' = {
  parent: apiManagement
  name: 'openai-team'
  properties: {
    displayName: 'OpenAI Team'
    description: 'A sample API that uses a OpenAI as an example to demonstrate features.'
    serviceUrl: 'https://api.openai.com/v1' //'https://${webSiteName}.azurewebsites.net/'
    path: ''
    subscriptionRequired: true
    protocols: [
      'https'
    ]
  }
}

///////////////////////////////////////////
// Create the API for Product
///////////////////////////////////////////
resource apiManagementProductApi 'Microsoft.ApiManagement/service/products/apis@2022-04-01-preview' = {
  parent: apiManagementProduct
  name: 'openai-team'
  dependsOn: [
    apiManagementOpenAIAPIs
  ]
}

///////////////////////////////////////////
// Create the API Logger for Application Insights
///////////////////////////////////////////
resource appInsightsAPILogger 'Microsoft.ApiManagement/service/loggers@2022-04-01-preview' = {
  parent: apiManagement
  name: appInsightsName
  properties: {
    loggerType: 'applicationInsights'
    description: 'OpenAI Application Insights instance.'
    resourceId: applicationInsightsID
    credentials: {
      instrumentationKey: appInsightsInstrumentationKey
    }
  }
}

///////////////////////////////////////////
// Configure logging for the API Service
///////////////////////////////////////////
resource appInsightsAPIMercuryHealthdiagnostics 'Microsoft.ApiManagement/service/apis/diagnostics@2022-04-01-preview' = {
  parent: apiManagementOpenAIAPIs
  name: 'applicationinsights'
  properties: {
    loggerId: appInsightsAPILogger.id
    alwaysLog: 'allErrors'
    logClientIp: true
    sampling: {
      samplingType: 'fixed'
      percentage: 100
    }
    verbosity: 'information'
    httpCorrelationProtocol: 'Legacy'
    frontend: {
      request: {
        headers: []
        body: {
          bytes: 0
        }
      }
      response: {
        headers: []
        body: {
          bytes: 0
        }
      }
    }
    backend: {
      request: {
        headers: []
        body: {
          bytes: 0
        }
      }
      response: {
        headers: []
        body: {
          bytes: 0
        }
      }
    }
  }
}

///////////////////////////////////////////
// Create User Account for the API Service
///////////////////////////////////////////
// resource apiManagementServiceName_User1 'Microsoft.ApiManagement/service/users@2022-04-01-preview' = {
//   parent: apiManagement
//   name: 'User1'
//   properties: {
//     firstName: 'FirstName'
//     lastName: 'LastName'
//     email: 'FirstName.LastName@example.com'
//     state: 'active'
//     note: 'Note for example user 1'
//   }
// }

///////////////////////////////////////////
///////////////////////////////////////////
// Create ALL Operation Definitions 
///////////////////////////////////////////
///////////////////////////////////////////

// Create Operation Definitions - Image generation
resource apiManagementOpenAIAPIs_AccessLogsGETMany 'Microsoft.ApiManagement/service/apis/operations@2022-04-01-preview' = {
  parent: apiManagementOpenAIAPIs
  name: 'ImageGenerationCreateGET'
  properties: {
    displayName: 'Creating images'
    method: 'GET'
    urlTemplate: '/images/generations'
    description: 'Creating images from scratch based on a text prompt'
  }
}
// Create Operation Definitions - Image generation
resource apiManagementOpenAIAPIs_AccessLogsGETSingle 'Microsoft.ApiManagement/service/apis/operations@2022-04-01-preview' = {
  parent: apiManagementOpenAIAPIs
  name: 'ImageGenerationEditsGET'
  properties: {
    displayName: 'Editing Images'
    method: 'GET'
    urlTemplate: '/images/generations/{id}'
    description: 'Creating edits of an existing image based on a new text prompt'
    templateParameters: [
      {
        name: 'id'
        required: true
        type: 'string'
      }
    ]
  }
}


///////////////////////////////////////////
// Create Policy for Operation Definitions 
///////////////////////////////////////////

// // Apply policy GET operations - Nutritions
// resource apiManagementOpenAIAPIs_NutritionsGETMany_policy 'Microsoft.ApiManagement/service/apis/operations/policies@2022-04-01-preview' = {
//   parent: apiManagementOpenAIAPIs_NutritionsGETMany
//   name: 'policy'
//   properties: {
//     format: 'rawxml'
//     value: loadTextContent('./policy_NutritionsGETMany.xml')
//   }
// }
// // Apply policy GET operations - Exercises
// resource apiManagementOpenAIAPIs_ExercisesGETMany_policy 'Microsoft.ApiManagement/service/apis/operations/policies@2022-04-01-preview' = {
//   parent: apiManagementOpenAIAPIs_ExercisesGETMany
//   name: 'policy'
//   properties: {
//     format: 'rawxml'
//     value: loadTextContent('./policy_ExercisesGETMany.xml')
//   }
// }
// // Apply policy for DELETE operations - Nutritions
// resource apiManagementOpenAIAPIs_NutritionsDELETE_policy 'Microsoft.ApiManagement/service/apis/operations/policies@2022-04-01-preview' = {
//   parent: apiManagementOpenAIAPIs_NutritionsDELETESingle
//   name: 'policy'
//   properties: {
//     format: 'rawxml'
//     value: loadTextContent('./policy_NutritionsDELETE.xml')
//   }
// }
// // Apply policy for DELETE operations - Exercises
// resource apiManagementOpenAIAPIs_ExercisesDELETE_policy 'Microsoft.ApiManagement/service/apis/operations/policies@2022-04-01-preview' = {
//   parent: apiManagementOpenAIAPIs_ExercisesDELETESingle
//   name: 'policy'
//   properties: {
//     format: 'rawxml'
//     value: loadTextContent('./policy_ExercisesDELETE.xml')
//   }
// }

//////////////////////////////////////////////
// Add Pet Store APIs for example
//////////////////////////////////////////////
resource petStoreApiExample 'Microsoft.ApiManagement/service/apis@2022-04-01-preview' = {
  name: '${apiManagement.name}/PetStoreSwaggerImportExample'
  properties: {
    format: 'swagger-link-json'
    value: 'http://petstore.swagger.io/v2/swagger.json'
    path: 'examplepetstore'
  }
}

var ApimSubscriptionKeyString = apiManagementSubscription.listSecrets().primaryKey

output out_ApimSubscriptionKeyString string = ApimSubscriptionKeyString
output out_ApimWebServiceURL string = apiManagement.properties.gatewayUrl
