<?php
// Маршруты для управления ключами доступа
$route['api/clients'] = 'api/client/index'; // Получить список клиентов
$route['api/clients/add'] = 'api/client/add'; // Добавить клиента
$route['api/clients/delete/(:num)'] = 'api/client/delete/$1'; // Удалить клиента

// Маршруты для управления ключевыми полями заказа
$route['api/order/fields'] = 'api/order/fields/index'; // Получить список ключевых полей
$route['api/order/fields/add'] = 'api/order/fields/add'; // Добавить ключевое поле
$route['api/order/fields/delete/(:num)'] = 'api/order/fields/delete/$1'; // Удалить ключевое поле

// Маршруты для работы с заказами
$route['api/orders'] = 'api/order/index'; // Получить список заказов
$route['api/orders/(:num)'] = 'api/order/get/$1'; // Получить заказ по ID
$route['api/orders/create'] = 'api/order/create'; // Создать заказ
$route['api/orders/update/(:num)'] = 'api/order/update/$1'; // Обновить заказ
$route['api/orders/delete/(:num)'] = 'api/order/delete/$1'; // Удалить заказ
$this->route['api/orders/delete/{order_id}'] = 'api/order/deleteOrder';
?>