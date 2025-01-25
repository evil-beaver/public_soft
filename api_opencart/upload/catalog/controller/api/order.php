<?php
class ControllerApiOrder extends Controller {
    // Метод для получения заказов
    public function getOrders() {
        // Проверяем авторизацию
        if (!$this->authenticate()) {
            $this->response->addHeader('HTTP/1.1 401 Unauthorized');
            return;
        }

        // Получаем фильтры из JSON-тела запроса
        $input = json_decode(file_get_contents('php://input'), true);
        $filters = [
            'date_start' => $input['date_start'] ?? null,
            'date_end'   => $input['date_end'] ?? null,
            'status_ids' => $input['status_ids'] ?? [],
            'customer_email' => $input['customer_email'] ?? null,
            'order_id'   => $input['order_id'] ?? null,
        ];

        // Загружаем модель заказов
        $this->load->model('checkout/order');

        // Получаем заказы с учетом фильтров
        $orders = $this->model_checkout_order->getOrdersByFilters($filters);

        // Формируем результат
        $result = [];
        foreach ($orders as $order) {
            $order_id = $order['order_id'];

            // Получаем товары в заказе
            $order_products = $this->model_checkout_order->getOrderProducts($order_id);

            // Получаем итоговые суммы заказа
            $order_totals = $this->model_checkout_order->getOrderTotals($order_id);

            // Получаем историю заказа
            $order_history = $this->model_checkout_order->getOrderHistories($order_id);

            // Добавляем заказ в результат
            $result[] = [
                'order'    => $order,
                'products' => $order_products,
                'totals'   => $order_totals,
                'history'  => $order_history,
            ];
        }

        // Возвращаем результат в формате JSON
        $this->response->addHeader('Content-Type: application/json');
        $this->response->setOutput(json_encode($result, JSON_PRETTY_PRINT));
    }

    // Метод для измнения заказов
    public function updateOrder() {
        // Проверяем авторизацию
        if (!$this->authenticate()) {
            $this->response->addHeader('HTTP/1.1 401 Unauthorized');
            return;
        }
    
        // Получаем данные из JSON-тела запроса
        $input = json_decode(file_get_contents('php://input'), true);
        $order_id = $input['order_id'] ?? null;
    
        if (!$order_id) {
            $this->response->setOutput(json_encode(['error' => 'Order ID is required']));
            return;
        }
    
        // Загружаем модель заказов
        $this->load->model('checkout/order');
    
        // Обновляем основные данные заказа (таблица `order`)
        if (isset($input['order'])) {
            $this->model_checkout_order->updateOrderData($order_id, $input['order']);
        }
    
        // Обновляем товары в заказе (таблица `order_product`)
        if (isset($input['products'])) {
            $this->model_checkout_order->updateOrderProducts($order_id, $input['products']);
    
            // Пересчитываем итоговую сумму заказа
            $total = $this->model_checkout_order->calculateOrderTotal($input['products']);
            $this->model_checkout_order->updateOrderTotal($order_id, $total);
        }
    
        // Возвращаем успешный ответ
        $this->response->addHeader('Content-Type: application/json');
        $this->response->setOutput(json_encode(['status' => 'success']));
    }

    public function createOrder() {
        // Проверяем авторизацию
        if (!$this->authenticate()) {
            $this->response->addHeader('HTTP/1.1 401 Unauthorized');
            return;
        }
    
        // Получаем данные из JSON-тела запроса
        $input = json_decode(file_get_contents('php://input'), true);
    
        // Загружаем модель заказов
        $this->load->model('checkout/order');
    
        // Получаем ключевые поля из базы данных
        $required_fields = $this->model_checkout_order->getRequiredFields();
    
        // Проверяем обязательные поля
        foreach ($required_fields as $field) {
            if (!isset($input['order'][$field])) {
                $this->response->setOutput(json_encode(['error' => "Field '{$field}' is required"]));
                return;
            }
        }
    
        // Создаем заказ
        $order_id = $this->model_checkout_order->createOrder($input);
    
        if (!$order_id) {
            $this->response->setOutput(json_encode(['error' => 'Failed to create order']));
            return;
        }
    
        // Возвращаем успешный ответ с ID заказа
        $this->response->addHeader('Content-Type: application/json');
        $this->response->setOutput(json_encode(['order_id' => $order_id]));
    }
    // Метод для проверки авторизации
    private function authenticate() {
        // Получаем заголовки запроса
        $client_id = $this->request->getHeader('Client-ID');
        $client_secret = $this->request->getHeader('Client-Secret');

        if (empty($client_id) || empty($client_secret)) {
            $this->response->setOutput(json_encode(['error' => 'Client-ID and Client-Secret are required']));
            return false;
        }

        // Проверяем клиента в базе данных
        $this->load->model('account/api');
        $client = $this->model_account_api->getClient($client_id, $client_secret);

        if (!$client) {
            $this->response->setOutput(json_encode(['error' => 'Unauthorized']));
            return false;
        }

        return true;
    }

    public function deleteOrder() {
        $this->load->language('api/order');
        $this->load->model('checkout/order');
    
        // Проверяем, передан ли order_id
        if (isset($this->request->get['order_id'])) {
            $order_id = (int)$this->request->get['order_id'];
        } else {
            $this->response->setOutput(json_encode(array('error' => 'Order ID is missing')));
            return;
        }
    
        // Проверяем, существует ли заказ
        $order_info = $this->model_checkout_order->getOrder($order_id);
        if (!$order_info) {
            $this->response->setOutput(json_encode(array('error' => 'Order not found')));
            return;
        }
    
        // Удаляем заказ
        $this->model_checkout_order->deleteOrder($order_id);
    
        // Возвращаем успешный ответ
        $this->response->setOutput(json_encode(array('success' => 'Order deleted')));
    }

}
?>