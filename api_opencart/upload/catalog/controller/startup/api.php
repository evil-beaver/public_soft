<?php
$this->route['api/orders'] = 'api/order/getOrders';
$this->route['api/orders/create'] = 'api/order/createOrder';
$this->route['api/orders/update/{order_id}'] = 'api/order/updateOrder';
$this->route['api/orders/delete/{order_id}'] = 'api/order/deleteOrder'; 
if (!isset($this->route[$requested_route])) {
    $this->response->addHeader('HTTP/1.1 404 Not Found');
    $this->response->setOutput(json_encode(['success' => false, 'error' => 'Route not found']));
    return;
}
?>
