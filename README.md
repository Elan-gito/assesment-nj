# Node.js MySQL CRUD Application Deployment

A CRUD (Create, Read, Update, Delete) application developed using Node.js and MySQL, showcasing database management and API development skills.

Deployment of the application on the AWS ECS and the infra provisioning using terraform.

---

## Description

The Node.js MySQL CRUD Application is a dynamic and versatile project that demonstrates a proficient combination of Node.js and MySQL, highlighting the developer's prowess in database management and API development. This project offers a comprehensive solution for performing CRUD (Create, Read, Update, Delete) operations on a database, providing a solid foundation for building robust web applications.

Also this repo contains the code for the application deployment on the AWS ECS using gihub action as a CI?CD tool, and the infra provisioning will be handled by the terraform script with help of github action.

---

## Key Features

- **CRUD Operations:** This project encompasses all four essential database operations - Create, Read, Update, and Delete. Users can seamlessly interact with the database through a user-friendly interface.

- **Node.js:** Powered by Node.js, this application leverages the asynchronous, event-driven architecture of Node.js for efficient and responsive server-side operations. Node.js enables real-time updates and a high level of scalability.

- **MySQL Database:** The application is deeply integrated with MySQL, a powerful and widely-used relational database management system. It showcases effective data storage, retrieval, and management techniques.

- **API Development:** The project exposes a set of well-documented APIs, enabling developers to interact programmatically with the underlying database. This makes it suitable for building both web and mobile applications that require data manipulation.

- **User-Friendly Interface:** The project includes an intuitive user interface that allows users to easily create, read, update, and delete records within the database. This interface serves as an excellent reference for frontend development.

- **Scalable and Maintainable:** Designed with scalability and maintainability in mind, the project follows best practices for code organization and separation of concerns, making it adaptable to the evolving needs of your application.

- **Open Source:** This GitHub project is open-source, providing a valuable resource for developers to learn, explore, and contribute to the world of Node.js and MySQL application development.

- **Infrastructure:**  Infra provisioning is getting handled in a effective way as by creating separate modules for tha all major resources VPC, RDS, ECS.

- **Secrets:** Secrets and evn variables majorly handled by the Github secrets and AWS secret manager.

- **Deployment:** Deployment is getting handled by the github action CI/CD pipeline.

- **Local test:** Local test envirionment will be handled byt he docker compose file, the test application will be deployed on the docker containers, which can be accessed from the "hhtp://127.0.0.1:3000"

---

## Local Test

1. Clone this repository to your local machine:
```shell
git clone https://github.com/your-username/node-mysql-crud-app.git
```

Navigate to the project directory:

```shell
cd node-mysql-crud-app
```
Run the docker compose file:

```shell
docker comppose up
```
check for the the container status:
```shell
docker ps
```
check for the compose logs:

```shell
docker comppose logs app
```

Test the application:

HHP://127.0.0.1:3000

Run the application:

## Infra deployment
1. Check the github action workflow dispatch option for the infra provisioning.
2. Select the appropriate action "plan/apply"
3. Plan will not required any approval.
4. Apply will required approval, as we have added required reviewers for the "env: production"

## Application deployment
This is an automated process, will get triggered when there is a commit on the release branch.

## Usage

Access the application through your web browser or make API requests programmatically.

Use the user-friendly interface to perform CRUD operations on the database.

## API Endpoints

The following API endpoints are available:

GET /api/records: Retrieve all records from the database.
GET /api/records/:id: Retrieve a specific record by ID.
POST /api/records: Create a new record.
PUT /api/records/:id: Update an existing record by ID.
DELETE /api/records/:id: Delete a record by ID.
For detailed API documentation and usage examples, refer to the API Documentation.

License
This project is licensed under the MIT License.
