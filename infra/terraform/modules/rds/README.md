# Module: rds

Creates the private MySQL database used by the application:

- DB subnet group
- RDS MySQL instance with the `app_db` database
- Application username and password supplied by the environment stack

The MySQL port is restricted to the WebLogic and EKS security groups defined in `modules/security`.

Output: database endpoint.