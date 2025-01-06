# Cookbook AI

This repository contains applications for the frontend and backend of Cookbook AI.

For more details about each component, please refer to their respective README files:

- [Frontend](./frontend/README.md)
- [Backend](./backend/README.md)

The general idea behind this application is to provide a simple interface where you can input ingredients and get matching recipe as a result.

## Environment variables for development

Check .env.sample for needed environment variables for each application.
To not duplicate .env files during development it's good to use some tool like [direnv](https://direnv.net).


## Running both apps in docker:

Simply run `docker compose up --build` and frontend will be available under [5173 port](http://localhost:5173) and backend under [9292 port](http://localhost:9292).
