
// parameters

param apimServiceName string = 'myAPIMService'
param location string = 'eastus'
param publisherName string = 'myPublisherName'
param publisherEmail string = 'myPublisherEmail@example.com'
param apiName string = 'myAPI'
param apiPath string = 'myAPIPath'

// GetCompletion
param operationName string = 'GetCompletion'
param operationDisplayName string = 'GetCompletion'

// is this correct?
param operationUrlTemplate string = '/v1/engines/davinci-codex/completions'
param OAI_KEY_VALUE string = 'change this to Azure Open AI key'


param productName string
param productDescription string


param openai_first_endpoint string = 'change me'
// param openai_second_endpoint string = 'change me'


// FIRST: creating Azure Cognitive Services account for OpenAI

resource cognitiveServicesAccount 'Microsoft.CognitiveServices/accounts@2023-10-01-preview' = {
  name: openai_first_endpoint
  location: location
  sku: {
    name: 'S0'
  }
  kind: 'OpenAI'
  properties: {
    customSubDomainName: openai_first_endpoint
    networkAcls: {
      defaultAction: 'Allow'
      virtualNetworkRules: []
      ipRules: []
    }
    publicNetworkAccess: 'Enabled'
  }
  identity: {
    type: 'SystemAssigned'
  }
}

// creating a deployment for the OpenAI model

resource cognitiveServicesAccountDeployment 'Microsoft.CognitiveServices/accounts/deployments@2023-10-01-preview' = {
  parent: cognitiveServicesAccount
  name: 'conversation-model'
  sku: {
    name: 'Standard'
    capacity: 120
  }
  properties: {
    model: {
      format: 'OpenAI'
      name: 'gpt-35-turbo'
      version: '0301'
    }
    versionUpgradeOption: 'OnceNewDefaultVersionAvailable'
    currentCapacity: 120
    raiPolicyName: 'Microsoft.Default'
  }
}

// creating a resource for the RAI policy and assigning it to the Cognitive Services account

resource cognitiveServicesAccountRaiPolicies 'Microsoft.CognitiveServices/accounts/raiPolicies@2023-10-01-preview' = {
  parent: cognitiveServicesAccount
  name: 'Microsoft.Default'
  properties: {
    mode: 'Blocking'
    contentFilters: [
      {
        name: 'Hate'
        allowedContentLevel: 'Medium'
        blocking: true
        enabled: true
        source: 'Prompt'
      }
      {
        name: 'Hate'
        allowedContentLevel: 'Medium'
        blocking: true
        enabled: true
        source: 'Completion'
      }
      {
        name: 'Sexual'
        allowedContentLevel: 'Medium'
        blocking: true
        enabled: true
        source: 'Prompt'
      }
      {
        name: 'Sexual'
        allowedContentLevel: 'Medium'
        blocking: true
        enabled: true
        source: 'Completion'
      }
      {
        name: 'Violence'
        allowedContentLevel: 'Medium'
        blocking: true
        enabled: true
        source: 'Prompt'
      }
      {
        name: 'Violence'
        allowedContentLevel: 'Medium'
        blocking: true
        enabled: true
        source: 'Completion'
      }
      {
        name: 'Selfharm'
        allowedContentLevel: 'Medium'
        blocking: true
        enabled: true
        source: 'Prompt'
      }
      {
        name: 'Selfharm'
        allowedContentLevel: 'Medium'
        blocking: true
        enabled: true
        source: 'Completion'
      }
    ]
  }
}

// create API Management service

resource apimService 'Microsoft.ApiManagement/service@2020-06-01-preview' = {
  name: apimServiceName
  location: location
  sku: {
    name: 'Consumption'
    capacity: 0
  }
  properties: {
    publisherEmail: publisherEmail
    publisherName: publisherName
  }
  identity: {
    type: 'SystemAssigned'
  }
  dependsOn: [
    cognitiveServicesAccount
  ]
}

// adding Managed Identity connection between APIM and Azure Open AI by adding a role assignment

// Cognitive Services API Management Contributor role ID 
param roleDefinitionId string = '5e0bd9bd-7b93-4f28-af87-19fc36ad61bd'

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(apimService.id, roleDefinitionId)
  scope: cognitiveServicesAccount
  properties: {
    roleDefinitionId: roleDefinitionId
    principalType: 'ServicePrincipal'
    principalId: apimService.identity.principalId
  }
}

// create API

resource api 'Microsoft.ApiManagement/service/apis@2020-06-01-preview' = {
  parent: apimService
  name: apiName
  properties: {
    displayName: apiName
    path: apiPath
    protocols: [
      'https'
    ]
    serviceUrl: cognitiveServicesAccount.properties.endpoint
  }
}


// create operation, using POST method

resource operation 'Microsoft.ApiManagement/service/apis/operations@2020-06-01-preview' = {
  parent: api
  name: operationName
  properties: {
    displayName: operationDisplayName
    method: 'POST'
    urlTemplate: '${cognitiveServicesAccount.properties.endpoint}${operationUrlTemplate}'
    responses: []
  }
}

// create policy that adds the Azure Open AI key to the Authorization header
var headerPolicyXml = '''
<policies>
  <inbound>
    <base />
    <authentication-managed-identity resource="https://cognitiveservices.azure.com" output-token-variable-name="managed-id-access-token" ignore-error="false" /> 
<set-header name="Authorization" exists-action="override"> 
    <value>@("Bearer " + (string)context.Variables["managed-id-access-token"])</value> 
</set-header> 
    <rate-limit-by-key calls="1000" renewal-period="3600" />
  </inbound>
  <backend>
    <base />
  </backend>
  <outbound>
    <base />
  </outbound>
  <on-error>
    <base />
  </on-error>
</policies>
'''

resource apiPolicy 'Microsoft.ApiManagement/service/apis/policies@2020-06-01-preview' = {
  parent: api
  name: 'policy'
  properties: {
    format: 'rawxml'
    value: headerPolicyXml
  }
}


// declares a product instance that ensures that a subscription is required to access the API

resource product 'Microsoft.ApiManagement/service/products@2020-06-01-preview' = {
  parent: apimService
  name: productName
  properties: {
    displayName: productName
    description: productDescription
    subscriptionRequired: true
  }
}

//  associate the API with the product

resource productApi 'Microsoft.ApiManagement/service/products/apis@2020-06-01-preview' = {
  parent: product
  name: api.name
}


