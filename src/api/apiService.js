let dotenv = require('dotenv');

// NOTE: remove this when deploying as it will read from App Service configuration
dotenv.config();

const URL = `${process.env.APIM_ENDPOINT}/${process.env.API_SUFFIX}/deployments/${process.env.DEPLOYMENT_ID}/completions?api-version=${process.env.API_VERSION}`;

console.log("[API] URL: ",URL);

module.exports = {
    getCompletion(prompt) {
        let body = {
            "prompt":prompt,
            "max_tokens":50
        };
        
        return fetch(URL, {
            method: "POST",
            headers: {
                "Ocp-Apim-Subscription-Key": process.env.SUBSCRIPTION_KEY,
                "Content-Type": "application/json"
            },
            body: JSON.stringify(body)
        }).then(response => {
            return response.json();
        }).then(data => { 
            // throw if choices is empty
            if (data.choices.length === 0) {
                throw new Error('No completion choices');
            } else {
                console.log("[API] responses: ",data.choices);
                return data.choices[0].text;
            }
        });
    }
}