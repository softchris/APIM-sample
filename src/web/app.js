const API_URL = 'http://localhost:5000/search';
const sendButton = document.getElementById('sendButton');
const inputBox = document.getElementById('inputBox');
const responseArea = document.getElementById('responseArea');

const spinner = document.getElementById('spinner');

function addMessage(username, message) {
    let div = document.createElement('div');
    div.style.height = '20px';
    div.style.margin = '20px';
    let span = document.createElement('span');
    span.classList.add('message');
    span.innerText = `${username}: ${message}`;
    div.appendChild(span);

    // Add class based on username
    if (username === 'YOU') {
        div.classList.add('user');
    } else {
        div.classList.add('server');
    }

    responseArea.appendChild(div);
    responseArea.scrollTop = responseArea.scrollHeight;
}

// click event send button
sendButton.addEventListener('click', async function() {
    let message = inputBox.value;
    if (message) {
        // send message
        console.log('send message: ' + message);
        addMessage('YOU', message); 
        spinner.style.display = 'block'; // Show the spinner

        try {
          
            // TODO: add call to APIM that in turn call Azure Open AI

            let response = await fetch(API_URL, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({ message: message })
            });

            if (!response.ok) {
                throw new Error(`HTTP error! status: ${response.status}`);
            }

            let data = await response.json();
            console.log(data);

            
            addMessage('SERVER', data.message);
            
            inputBox.value = '';
        } catch (err) {
            console.error(err);
        } finally {
            spinner.style.display = 'none'; // Hide the spinner
        }
    }
});