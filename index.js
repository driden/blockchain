const express = require('express');
const bodyParser = require('body-parser');

const contractRoute = require('./routes/contract.route');
const managersRoutes = require('./routes/manager.route');

const port = process.env.port || 3000;
const app = express();

// middleware
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

//routes
app.use('/api/contract', contractRoute);
app.use('/api/managers', managersRoutes);

app.listen(port, () => console.log(`Listening on port ${port}`));