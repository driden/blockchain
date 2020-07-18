const express = require('express');
const contractRoute = require('./routes/contract.route');

const port = process.env.port || 3000;
const app = express();

//routes
app.use('/api/contract', contractRoute);

app.listen(port, () => console.log(`Listening on port ${port}`));