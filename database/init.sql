-- creating the database
use crudnodejsmysql;

-- creating a table
CREATE TABLE IF NOT EXISTS customer (
    id INT(6) UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    address VARCHAR(100) NOT NULL,
    phone VARCHAR(15)
);

-- Optional: Insert a sample record for testing
INSERT INTO customer (name, address, phone) VALUES 
('Elavarasan', '123 Main St', '000-1234');

-- Show all tables
SHOW TABLES;

-- To describe the table
describe customer;