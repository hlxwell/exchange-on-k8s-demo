# API design

## auth-service
- POST /api/v1/sessions {email, password} return :token
- DELETE /api/v1/sessions {token}

## trade-service
- GET /api/v1/trades

## order-service
- POST /api/v1/orders {pair,side,price,volume}
- GET /api/v1/orders

## account-service
- GET /api/v1/my_balance?currency=*
