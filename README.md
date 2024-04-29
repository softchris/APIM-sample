# Azure APIM Azure Open AI sample

This is a sample project that demonstrates how to use Azure API Management and Azure Open AI to create a simple chatbot.

## How to run

- Set the environment variables in the `.env` file, it should look like this:

    ```bash
    SUBSCRIBER_SECRET=your-subscription-secret
    ```

- Install the dependencies

    ```bash
    npm install
    ```

- Run the app

    ```bash
    npm start
    ```

    This will start a web server on `localhost:3000` and a REST API on `localhost:5000`.

## What's in this repo

|What  |Description  | Link |
|---------|---------|--|
|Frontend     | a frontend consisting of a `index.html` and `app.js` | [Link](./src/web/)        |
|Backend     | A backend written in Node.js and Express framework | [Link](./src/api/)        |
|Bicep     | Bicep files containing the needed information to deploy resources and configure them as needed        | [Link](./main.bicep) |


## Plan

 - [x] Create the app
 - [] Create either ARM or Bicep files
     - [x] create resources for APIM. 
     - [x] create resources for Azure Open AI instance.
     - [x] create API and operation pointing to the Azure Open AI instance.
     - [x] configure APIM to use managed identity.
     - [] create a product and a subscription.
     - [] apply policies to the API to share load between two Azure Open AI instances.

## Demo

![App running](app.gif)

## Deploy to Azure

TBD