# OpenCart API Module

Этот модуль предоставляет REST API для управления заказами в OpenCart.

---

## Установка

1. Загрузите файлы модуля в корневую директорию вашего OpenCart.
2. Установите модуль через админ панель: **Extensions > Installer**.
3. Настройте модуль через админ панель: **Extensions > Modules > API Module**.

---

## Настройка

### 1. Ключи доступа

Для использования API необходимо настроить ключи доступа:
- **Client-ID** — уникальный идентификатор клиента.
- **Client-Secret** — секретный ключ клиента.

Эти ключи используются для аутентификации всех запросов к API.

### 2. Ключевые поля заказа

Вы можете настроить ключевые поля для заказов через админ панель:
- Перейдите в **Extensions > Modules > API Module**.
- Добавьте или удалите ключевые поля, которые будут использоваться при создании и обновлении заказов.

---

## Использование API

API поддерживает следующие методы для работы с заказами:
- Получение списка заказов.
- Получение заказа по ID.
- Создание нового заказа.
- Обновление существующего заказа.
- Удаление заказа.

Подробное описание методов API см. в файле [openapi.yaml](openapi.yaml).

---

## Работа с заказами
Получить список заказов
Метод: GET

URL: /api/orders

Заголовки:

Client-ID: ваш_client_id

Client-Secret: ваш_client_secret

Пример запроса:
---
```bash
Copy
curl -X GET http://your-opencart-site.com/api/orders \
-H "Client-ID: 123" \
-H "Client-Secret: your_secret_key"
```
Получить заказ по ID
Метод: GET

URL: /api/orders/{order_id}

Заголовки:

Client-ID: ваш_client_id

Client-Secret: ваш_client_secret

Пример запроса:

bash
Copy
curl -X GET http://your-opencart-site.com/api/orders/1 \
-H "Client-ID: 123" \
-H "Client-Secret: your_secret_key"
Создать заказ
Метод: POST

URL: /api/orders/create

Заголовки:

Client-ID: ваш_client_id

Client-Secret: ваш_client_secret

Content-Type: application/json

Тело запроса:

json
Copy
{
    "order": {
        "firstname": "John",
        "lastname": "Doe",
        "email": "john.doe@example.com",
        "telephone": "123456789",
        "shipping_address_1": "123 Main Street",
        "shipping_city": "New York",
        "shipping_country": "United States",
        "shipping_method": "Flat Rate"
    },
    "products": [
        {
            "product_id": 42,
            "name": "Example Product",
            "model": "Model 123",
            "quantity": 2,
            "price": 50.00,
            "total": 100.00
        }
    ]
}
Пример запроса:

bash
Copy
curl -X POST http://your-opencart-site.com/api/orders/create \
-H "Client-ID: 123" \
-H "Client-Secret: your_secret_key" \
-H "Content-Type: application/json" \
-d '{
    "order": {
        "firstname": "John",
        "lastname": "Doe",
        "email": "john.doe@example.com",
        "telephone": "123456789",
        "shipping_address_1": "123 Main Street",
        "shipping_city": "New York",
        "shipping_country": "United States",
        "shipping_method": "Flat Rate"
    },
    "products": [
        {
            "product_id": 42,
            "name": "Example Product",
            "model": "Model 123",
            "quantity": 2,
            "price": 50.00,
            "total": 100.00
        }
    ]
}'
Обновить заказ
Метод: PUT

URL: /api/orders/update/{order_id}

Заголовки:

Client-ID: ваш_client_id

Client-Secret: ваш_client_secret

Content-Type: application/json

Тело запроса:

json
Copy
{
    "order": {
        "firstname": "John",
        "lastname": "Doe",
        "email": "john.doe@example.com",
        "telephone": "123456789",
        "shipping_method": "Express Shipping"
    },
    "products": [
        {
            "product_id": 42,
            "name": "Updated Product",
            "model": "Model 123",
            "quantity": 3,
            "price": 60.00,
            "total": 180.00
        }
    ]
}
Пример запроса:

bash
Copy
curl -X PUT http://your-opencart-site.com/api/orders/update/1 \
-H "Client-ID: 123" \
-H "Client-Secret: your_secret_key" \
-H "Content-Type: application/json" \
-d '{
    "order": {
        "firstname": "John",
        "lastname": "Doe",
        "email": "john.doe@example.com",
        "telephone": "123456789",
        "shipping_method": "Express Shipping"
    },
    "products": [
        {
            "product_id": 42,
            "name": "Updated Product",
            "model": "Model 123",
            "quantity": 3,
            "price": 60.00,
            "total": 180.00
        }
    ]
}'
Удалить заказ
Метод: DELETE

URL: /api/orders/delete/{order_id}

Заголовки:

Client-ID: ваш_client_id

Client-Secret: ваш_client_secret

Пример запроса:

bash
Copy
curl -X DELETE http://your-opencart-site.com/api/orders/delete/1 \
-H "Client-ID: 123" \
-H "Client-Secret: your_secret_key"


## Лицензия

Этот проект распространяется под лицензией MIT. Подробности см. в файле [LICENSE](LICENSE).
