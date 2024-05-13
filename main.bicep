
// parameters

param publisherName string = 'myPublisherName'
param publisherEmail string = 'myPublisherEmail@example.com'
param apiName string = 'myAPI'

param productName string = 'myProduct'
param productDescription string

param openai_first_endpoint_name string = 'change me'
param openai_second_endpoint_name string = 'change me'

param location string = resourceGroup().location
param resourceGroupName string = resourceGroup().name


var serviceName = 'service${uniqueString(resourceGroup().id)}'

// START, AI creating resources

// FIRST: creating Azure Cognitive Services account for OpenAI

resource cognitiveServicesAccount1 'Microsoft.CognitiveServices/accounts@2023-10-01-preview' = {
  name: openai_first_endpoint_name
  location: location
  sku: {
    name: 'S0'
  }
  kind: 'OpenAI'
  properties: {
    customSubDomainName: openai_first_endpoint_name
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

// SECOND: creating Azure Cognitive Services account for OpenAI

resource cognitiveServicesAccount2 'Microsoft.CognitiveServices/accounts@2023-10-01-preview' = {
  name: openai_second_endpoint_name
  location: location
  sku: {
    name: 'S0'
  }
  kind: 'OpenAI'
  properties: {
    customSubDomainName: openai_second_endpoint_name
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


// creating 2 deployments for the OpenAI model

resource cognitiveServicesAccountDeployment1 'Microsoft.CognitiveServices/accounts/deployments@2023-10-01-preview' = {
  parent: cognitiveServicesAccount1
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

resource cognitiveServicesAccountDeployment2 'Microsoft.CognitiveServices/accounts/deployments@2023-10-01-preview' = {
  parent: cognitiveServicesAccount2
  name: 'conversation-model-2'
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
  parent: cognitiveServicesAccount1
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

resource cognitiveServicesAccountRaiPolicies2 'Microsoft.CognitiveServices/accounts/raiPolicies@2023-10-01-preview' = {
  parent: cognitiveServicesAccount2
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

// END AI resources creation


// create API Management service

resource apimService 'Microsoft.ApiManagement/service@2020-06-01-preview' = {
  name: serviceName
  location: location
  sku: {
    name: 'Developer' // TODO, 
    capacity: 0
  }
  properties: {
    publisherEmail: publisherEmail
    publisherName: publisherName
  }
  identity: {
    type: 'SystemAssigned'
  }
}

// adding Managed Identity connection between APIM and Azure Open AI by adding a role assignment

// TODO Cognitive Services API Management Contributor role ID 
param roleDefinitionId string = '5e0bd9bd-7b93-4f28-af87-19fc36ad61bd'

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(apimService.id, roleDefinitionId)
  scope: cognitiveServicesAccount1
  properties: {
    roleDefinitionId: roleDefinitionId
    principalType: 'ServicePrincipal'
    principalId: apimService.identity.principalId
  }
}

resource roleAssignment2 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(apimService.id, roleDefinitionId)
  scope: cognitiveServicesAccount2
  properties: {
    roleDefinitionId: roleDefinitionId
    principalType: 'ServicePrincipal'
    principalId: apimService.identity.principalId
  }
}

// POLICY1/BACKEND: create a backend that wires up "circuit breaker policy" to the Cognitive Services account
resource backend1 'Microsoft.ApiManagement/service/backends@2023-03-01-preview' = {
  name: 'myEndpoint/api'
  properties: {
    url: cognitiveServicesAccount1.properties.endpoint
    protocol: 'https'
    circuitBreaker: {
      rules: [
        {
          failureCondition: {
            count: 3
            errorReasons: [
              'Server errors'
            ]
            interval: 'P1D'
            statusCodeRanges: [
              {
                min: 500
                max: 599
              }
            ]
          }
          name: 'myBreakerRule'
          tripDuration: 'PT1H'
        }
      ]
    }
   }
 }

 // POLICY/BACKEND: create a backend that wires up "circuit breaker policy" to the Cognitive Services account
resource backend2 'Microsoft.ApiManagement/service/backends@2023-03-01-preview' = {
  name: 'myEndpoint/api2'
  properties: {
    url: cognitiveServicesAccount2.properties.endpoint
    protocol: 'https'
    circuitBreaker: {
      rules: [
        {
          failureCondition: {
            count: 3
            errorReasons: [
              'Server errors'
            ]
            interval: 'P1D'
            statusCodeRanges: [
              {
                min: 500
                max: 599
              }
            ]
          }
          name: 'myBreakerRule'
          tripDuration: 'PT1H'
        }
      ]
    }
   }
 }

 var subscriptionId = az.subscription().subscriptionId

// POLICY, load balancing
resource loadBalancing 'Microsoft.ApiManagement/service/backends@2023-05-01-preview' = {
  name: 'myBackendPool/LoadBalancer'
  properties: {
    description: 'Load balancer for multiple backends'
    type: 'Pool'
    protocol: 'http' // TODO, maybe not required
    url: 'https://example.com' // TODO, maybe not required
    pool: {
      services: [
        {
          id: '/subscriptions/${subscriptionId}/resourceGroups/${resourceGroupName}/providers/Microsoft.ApiManagement/service/${serviceName}/backends/${backend1.id}'
        }
        {
          id: '/subscriptions/${subscriptionId}/resourceGroups/${resourceGroupName}/providers/Microsoft.ApiManagement/service/${serviceName}/backends/${backend1.id}'
        }
      ]
    }
  }
}

// TODO, user needs to change the endpoints in the JSON file

// API, creating the API

// TODO, try deploy, endpoint resources should be used and override wha'ts in there

resource api1 'Microsoft.ApiManagement/service/apis@2020-06-01-preview' = {
  parent: apimService
  name: apiName
  properties: {
    displayName: apiName
    apiType: 'http'
    path: '${apiName}/openai'
    format: 'openapi+json-link'
    value: 'https://raw.githubusercontent.com/Azure/azure-rest-api-specs/main/specification/cognitiveservices/data-plane/AzureOpenAI/inference/preview/2024-03-01-preview/inference.json'
    subscriptionKeyParameterNames: {
      header: 'api-key'
    }
  }
}

// POLICY DEFINITION, see inbound section Andrei is sharing

var headerPolicyXml = '''
<policies>
  <inbound>
    <base />

    <authentication-managed-identity resource="https://cognitiveservices.azure.com" output-token-variable-name="managed-id-access-token" ignore-error="false" /> 
<set-header name="Authorization" exists-action="override"> 
    <value>@("Bearer " + (string)context.Variables["managed-id-access-token"])</value> 
</set-header> 
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

// POLICY adding rate limit policy to APIs

resource apiPolicy 'Microsoft.ApiManagement/service/apis/policies@2020-06-01-preview' = {
  parent: api1
  name: 'policy'
  properties: {
    format: 'rawxml'
    value: headerPolicyXml
  }
}

// PRODUCT declares a product instance that ensures that a subscription is required to access the API

resource product 'Microsoft.ApiManagement/service/products@2020-06-01-preview' = {
  parent: apimService
  name: productName
  properties: {
    displayName: productName
    description: productDescription
    subscriptionRequired: true
  }
}

// PRODUCT-API associate the API with the product

resource productApi1 'Microsoft.ApiManagement/service/products/apis@2020-06-01-preview' = {
  parent: product
  name: api1.name
}

// USER creating a user
resource user 'Microsoft.ApiManagement/service/users@2020-06-01-preview' = {
  parent: apimService
  name: 'userName'
  properties: {
    firstName: 'User'
    lastName: 'Name'
    email: 'user@example.com'
    state: 'active'
  }
}

// SUBSCRIPTION creating a subscription, ID

resource subscription 'Microsoft.ApiManagement/service/subscriptions@2020-06-01-preview' = {
  parent: apimService
  name: 'subscriptionAIProduct'
  properties: {
    displayName: 'Subscribing to AI services'
    state: 'active'
    ownerId: user.id
    scope: product.id
  }
}


