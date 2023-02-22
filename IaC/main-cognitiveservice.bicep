param cognitiveServiceName string
param location string
param defaultTags object
param sku string = 'S0'

resource cognitiveServiceOpenAI 'Microsoft.CognitiveServices/accounts@2022-12-01' = {
  name: cognitiveServiceName
  location: location
  tags: defaultTags
  sku: {
    name: sku
  }
  //kind: 'OpenAI'
  properties: {
    customSubDomainName: 'openaidemo-rpagels'
    publicNetworkAccess: 'Enabled'
  }
}

resource cognitiveServiceOpenAI_Code_Davinci_002 'Microsoft.CognitiveServices/accounts/deployments@2022-12-01' = {
  parent: cognitiveServiceOpenAI
  name: 'Code-Davinci-002-TestRun'
  properties: {
    model: {
      format: 'OpenAI'
      name: 'code-davinci-002'
      version: '1'
    }
    scaleSettings: {
      scaleType: 'Standard'
    }
  }
}

resource cognitiveServiceOpenAI_Code_Davinci_003 'Microsoft.CognitiveServices/accounts/deployments@2022-12-01' = {
  parent: cognitiveServiceOpenAI
  name: 'Text-Davinci-003-TestRun'
  properties: {
    model: {
      format: 'OpenAI'
      name: 'text-davinci-003'
      version: '1'
    }
    scaleSettings: {
      scaleType: 'Standard'
    }
  }
}

// resource cognitiveService 'Microsoft.CognitiveServices/accounts@2022-12-01' = {
//   name: cognitiveServiceName
//   tags: defaultTags
//   location: location
//   sku: {
//     name: sku
//   }
//   kind: 'CognitiveServices'
//   identity: {
//     type:'SystemAssigned'
//   }
//   properties: {
//     //customSubDomainName: 'imageprocessing-${uniqueString(resourceGroup().id)}'
//     networkAcls: {
//       defaultAction: 'Allow'
//       virtualNetworkRules: []
//       ipRules: []
//     }
//     apiProperties: {
//       statisticsEnabled: false
//     }
//     publicNetworkAccess: 'Enabled'
//   }
// }

var cognitiveServiceKeyString = cognitiveServiceOpenAI.listKeys().key1
output out_cognitiveServiceKeyString string = cognitiveServiceKeyString
