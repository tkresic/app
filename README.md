# App

Cash register application.

## Create .env file in assets/env with following setup
```
CASH_REGISTER_ID=<cash_register_id>
SHOP_API_URI=<shop_api_uri>
FINANCE_API_URI=<finance_api_uri>
CORPORATE_API_URI=<corporate_api_uri>
ACCOUNTS_API_URI=<accounts_api_uri>
AUTH0_DOMAIN=<auth_domain>
AUTH0_AUDIENCE=<auth_audience>
AUTH0_CLIENT_ID=<auth_client_id>
AUTH0_CLIENT_SECRET=<auth_client_secret>
```

## Start the Shop microservice
`php -S localhost:8000 -t public`

## Start the Finance microservice
`php -S localhost:8002 -t public`

## Start the Corporate microservice
`./gradlew bootRun`

## Start the Accounts microservice
`./gradlew bootRun`

## Run the app and choose the platform (Linux or Web)

`flutter run`

## Run the app directly on web with images enabled

`flutter run -d chrome --web-port 5555 --web-renderer html`