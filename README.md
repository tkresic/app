# App

Cash register application for restaurants & coffee shops.

## Create .env file in assets/env with following setup
```
APP_ENV=dev
SHOP_API_URI=http://localhost:8000
FINANCE_API_URI=http://localhost:8002
CORPORATE_API_URI=http://localhost:8080
ACCOUNTS_API_URI=http://localhost:8081
```

## Start the Shop microservice
`php -S localhost:8000 -t public`

## Start the Finance microservice
`php -S localhost:8002 -t public`

## Start the Corporate microservice
`./mvnw spring-boot:run`

## Run the app and choose the platform (Linux or Web)

`flutter run`

## Run the app directly on web with images enabled

`flutter run -d chrome --web-renderer html`