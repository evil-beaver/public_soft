<?php
class ModelCheckoutOrder extends Model {
    // Метод для получения заказов с фильтрами
    public function getOrdersByFilters($filters = []) {
        $sql = "SELECT * FROM `" . DB_PREFIX . "order` WHERE 1";
        $params = [];

        // Фильтр по дате начала
        if (!empty($filters['date_start'])) {
            $sql .= " AND DATE(date_added) >= ?";
            $params[] = $filters['date_start'];
        }

        // Фильтр по дате окончания
        if (!empty($filters['date_end'])) {
            $sql .= " AND DATE(date_added) <= ?";
            $params[] = $filters['date_end'];
        }

        // Фильтр по статусам заказов
        if (!empty($filters['status_ids'])) {
            $placeholders = implode(',', array_fill(0, count($filters['status_ids']), '?'));
            $sql .= " AND order_status_id IN ($placeholders)";
            $params = array_merge($params, $filters['status_ids']);
        }

        // Фильтр по email клиента
        if (!empty($filters['customer_email'])) {
            $sql .= " AND email = ?";
            $params[] = $filters['customer_email'];
        }

        // Фильтр по ID заказа
        if (!empty($filters['order_id'])) {
            $sql .= " AND order_id = ?";
            $params[] = (int)$filters['order_id'];
        }

        // Выполняем запрос
        $query = $this->db->query($sql, $params);
        return $query->rows;
    }

    // Метод для получения товаров в заказе
    public function getOrderProducts($order_id) {
        $query = $this->db->query("
            SELECT * FROM `" . DB_PREFIX . "order_product`
            WHERE order_id = ?
        ", [(int)$order_id]);
        return $query->rows;
    }

    // Метод для получения итоговых сумм заказа
    public function getOrderTotals($order_id) {
        $query = $this->db->query("
            SELECT * FROM `" . DB_PREFIX . "order_total`
            WHERE order_id = ?
            ORDER BY sort_order
        ", [(int)$order_id]);
        return $query->rows;
    }

    // Метод для получения истории заказа
    public function getOrderHistories($order_id) {
        $query = $this->db->query("
            SELECT * FROM `" . DB_PREFIX . "order_history`
            WHERE order_id = ?
            ORDER BY date_added
        ", [(int)$order_id]);
        return $query->rows;
    }

    public function updateOrderData($order_id, $order_data) {
        $sql = "UPDATE `" . DB_PREFIX . "order` SET ";
        $updates = [];
        $params = [];

        foreach ($order_data as $key => $value) {
            $updates[] = "$key = ?";
            $params[] = $value;
        }

        if (empty($updates)) {
            return; // Нет данных для обновления
        }

        $sql .= implode(", ", $updates) . " WHERE order_id = ?";
        $params[] = (int)$order_id;

        $this->db->query($sql, $params);
    }

    public function updateOrderProducts($order_id, $products) {
        // Удаляем старые товары из заказа
        $this->db->query("DELETE FROM `" . DB_PREFIX . "order_product` WHERE order_id = ?", [(int)$order_id]);

        // Добавляем новые товары
        foreach ($products as $product) {
            $this->db->query("
                INSERT INTO `" . DB_PREFIX . "order_product`
                SET order_id = ?,
                    product_id = ?,
                    name = ?,
                    model = ?,
                    quantity = ?,
                    price = ?,
                    total = ?
            ", [
                (int)$order_id,
                (int)$product['product_id'],
                $this->db->escape($product['name']),
                $this->db->escape($product['model']),
                (int)$product['quantity'],
                (float)$product['price'],
                (float)$product['total']
            ]);
        }
    }

    public function calculateOrderTotal($products) {
        $total = 0;
        foreach ($products as $product) {
            $total += (float)$product['price'] * (int)$product['quantity'];
        }
        return $total;
    }

    public function updateOrderTotal($order_id, $total) {
        // Обновляем общую сумму в таблице `order`
        $this->db->query("
            UPDATE `" . DB_PREFIX . "order`
            SET total = ?
            WHERE order_id = ?
        ", [(float)$total, (int)$order_id]);

        // Обновляем Sub-Total в таблице `order_total`
        $this->db->query("
            UPDATE `" . DB_PREFIX . "order_total`
            SET value = ?
            WHERE order_id = ?
            AND code = 'sub_total'
        ", [(float)$total, (int)$order_id]);

        // Обновляем Total в таблице `order_total`
        $this->db->query("
            UPDATE `" . DB_PREFIX . "order_total`
            SET value = ?
            WHERE order_id = ?
            AND code = 'total'
        ", [(float)$total, (int)$order_id]);
    }

    public function deleteOrder($order_id) {
        // Удаление данных заказа с использованием безопасных параметризированных запросов
        $this->db->query("DELETE FROM `" . DB_PREFIX . "order` WHERE order_id = ?", [(int)$order_id]);
        $this->db->query("DELETE FROM `" . DB_PREFIX . "order_product` WHERE order_id = ?", [(int)$order_id]);
        $this->db->query("DELETE FROM `" . DB_PREFIX . "order_history` WHERE order_id = ?", [(int)$order_id]);
        $this->db->query("DELETE FROM `" . DB_PREFIX . "order_total` WHERE order_id = ?", [(int)$order_id]);
    }
}
?>
