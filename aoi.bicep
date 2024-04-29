param openai_first_endpoint string = 'change me'
param openai_second_endpoint string = 'change me'
param location string = 'eastus'

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

// SECOND: creating Azure Cognitive Services account for second endpoint

resource cognitiveServicesAccount_2 'Microsoft.CognitiveServices/accounts@2023-10-01-preview' = {
  name: openai_second_endpoint
  location: location
  sku: {
    name: 'S0'
  }
  kind: 'OpenAI'
  properties: {
    customSubDomainName: openai_second_endpoint
    networkAcls: {
      defaultAction: 'Allow'
      virtualNetworkRules: []
      ipRules: []
    }
    publicNetworkAccess: 'Enabled'
  }
}

// creating a deployment for the OpenAI model

resource cognitiveServicesAccountDeployment_2 'Microsoft.CognitiveServices/accounts/deployments@2023-10-01-preview' = {
  parent: cognitiveServicesAccount_2
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

resource cognitiveServicesAccountRaiPolicies_2 'Microsoft.CognitiveServices/accounts/raiPolicies@2023-10-01-preview' = {
  parent: cognitiveServicesAccount_2
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

