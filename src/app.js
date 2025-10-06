const express = require("express");
const morgan = require("morgan");
const mysql = require("mysql");
const myConnection = require("express-myconnection");
const path = require('path');
const app = express();
// require('dotenv').config(); // Removing dotenv for Docker (environment variables handle this)

// To get the database password (now confirmed to be 'sec123' or from env)
const DB_CONFIG = {
    host: process.env.DB_HOST,
    user: process.env.DB_USER || 'root',
    password: process.env.DATABASE_PASSWORD || 'mysecretpassword',
    port: process.env.DB_PORT || '3306',
    database: process.env.DB_NAME || 'crudnodejsmysql'
};

// Importing routes
const customerRoutes = require('./routes/customer');

// settings
const PORT = process.env.PORT || 3000;
app.set('port', PORT);
app.set('view engine', 'ejs');
app.set('views', path.join(__dirname, 'views'));

// middlewares
app.use(morgan('dev'));

// CRITICAL FIX: The app starts ONLY after a successful database connection.
function connectWithRetry(retries = 10, delay = 5000) {
    console.log(`Attempting database connection to ${DB_CONFIG.host}:${DB_CONFIG.port}. Retries left: ${retries}`);

    // Create a temporary connection just to test the connectivity
    const testConnection = mysql.createConnection(DB_CONFIG);

    testConnection.connect(err => {
        if (err) {
            console.error(`DB Connection Failed: ${err.code}. Retrying in ${delay / 1000}s...`);
            testConnection.end(); // Ensure the failed connection is closed
            if (retries > 0) {
                setTimeout(() => connectWithRetry(retries - 1, delay), delay);
            } else {
                console.error("Exhausted all connection retries. Shutting down application.");
                // Exit with a failure code if connection cannot be established
                process.exit(1);
            }
            return;
        }

        console.log("Database connection successful!");
        testConnection.end(); // Close the test connection

        // Only after the connection is confirmed, add the middleware and start the server
        app.use(myConnection(mysql, DB_CONFIG, 'single'));
        app.use(express.urlencoded({extended: false}));

        // Routes
        app.use('/', customerRoutes);

        // Static files
        app.use(express.static(path.join(__dirname, 'public')));

        // Starting the server
        app.listen(PORT, () => {
            console.log(`Server on port ${PORT}. Application is fully ready.`);
        });
    });
}

// Start the connection attempt loop
connectWithRetry();