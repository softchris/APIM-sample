
// sample js for calling Azure Management API (APIM) using DefaultAzureCredential and a subscription key


const { DefaultAzureCredential } = require("@azure/identity");
const { ServiceClient, WebResourceLike } = require("@azure/core-http");

// Instantiate the DefaultAzureCredential
const credential = new DefaultAzureCredential();

// Define the scope for Azure Management
const scope = "https://management.azure.com/.default";

// Get the access token
credential.getToken(scope).then(token => {
  // Create a ServiceClient
  const client = new ServiceClient(credential, {
    baseUri: "<api-endpoint>"
  });

  // Create a WebResourceLike for the request
  const request: WebResourceLike = {
    url: "<api-endpoint>",
    method: "GET",
    headers: {
      "Ocp-Apim-Subscription-Key": "<subscription-key>"
    }
  };

  // Send the request
  client.sendRequest(request).then(response => {
    console.log(response.bodyAsText);
  });
});