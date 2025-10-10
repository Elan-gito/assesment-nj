const express = require("express");
const morgan = require("morgan");
const mysql = require("mysql");
const myConnection = require("express-myconnection");
const path = require('path');
const app = express();

const DB_CONFIG = {
    host: process.env.DB_HOST,
    user: process.env.DB_USER || 'root',
    password: process.env.DATABASE_PASSWORD,
    port: process.env.DB_PORT || '3306',
    database: process.env.DB_NAME || 'crudnodejsmysql'
};

const customerRoutes = require('./routes/customer');

const PORT = process.env.PORT || 3000;
app.set('port', PORT);
app.set('view engine', 'ejs');
app.set('views', path.join(__dirname, 'views'));

app.use(morgan('dev'));

function connectWithRetry(retries = 10, delay = 5000) {
    console.log(`Attempting database connection to ${DB_CONFIG.host}:${DB_CONFIG.port}. Retries left: ${retries}`);

    const testConnection = mysql.createConnection(DB_CONFIG);

    testConnection.connect(err => {
        if (err) {
            console.error(`DB Connection Failed: ${err.code}. Retrying in ${delay / 1000}s...`);
            testConnection.end();
            if (retries > 0) {
                setTimeout(() => connectWithRetry(retries - 1, delay), delay);
            } else {
                console.error("Exhausted all connection retries. Shutting down application.");
                process.exit(1);
            }
            return;
        }

        console.log("Database connection successful!");
        testConnection.end();

        app.use(myConnection(mysql, DB_CONFIG, 'single'));
        app.use(express.urlencoded({extended: false}));

        app.use('/', customerRoutes);

        app.use(express.static(path.join(__dirname, 'public')));

        app.listen(PORT, () => {
            console.log(`Server on port ${PORT}. Application is fully ready.`);
        });
    });
}

connectWithRetry();