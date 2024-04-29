// express api, should a POST route "search" that takes a message and returns a response
let express = require('express');
let cors = require('cors');
let port = process.env.PORT || 5000;

const { message } = require('statuses');
let app = express();

app.use(cors());
app.use(express.json());


// generate a list with 10 different greetings
let greetings = ['Hello', 'Hi', 'Hey', 'Hola', 'Bonjour', 'Ciao', 'Namaste', 'Salaam', 'Konnichiwa', 'Shalom'];

// express add route
app.get('/', function(req, res) {
    res.json({ message: 'Hello World' });
});

app.post('/search', function(req, res) {
    let message = req.body.message;
    console.log('[API] message: ' + message);

    // Add a delay of 2 seconds before responding
    setTimeout(function() {
        res.json({ message: greetings[Math.floor(Math.random() * greetings.length)]});
    }, 2000);
});


app.listen(port, function() {
    console.log('Server started on http://localhost:' + port);
});
