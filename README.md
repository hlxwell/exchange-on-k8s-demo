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
- GET /api/v1/accounts/my_balance?currency=*

# Alpine options

```
$ apk add docker --update-cache --repository http://mirrors.ustc.edu.cn/alpine/v3.4/main/ --allow-untrusted
--update-cache
--repository http://mirrors.ustc.edu.cn/alpine/v3.4/main/
--allow-untrusted
```

```
kubectl label namespace exchange-on-k8s-v1 istio-injection=enabled
```