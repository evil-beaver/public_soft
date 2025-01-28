<?php
class ModelExtensionModuleApiClients extends Model {
    private $data_file = DIR_STORAGE . 'api_data/clients.json';

    // Получение всех клиентов
    public function getClients() {
        if (!file_exists($this->data_file)) {
            return []; // Если файл отсутствует, возвращаем пустой массив
        }

        $clients = json_decode(file_get_contents($this->data_file), true);
        return $clients ?: []; // Возвращаем массив или пустой результат
    }

    // Добавление нового клиента
    public function addClient($client_name, $client_secret, $status) {
        $clients = $this->getClients(); // Читаем текущие данные

        // Добавляем нового клиента
        $clients[] = [
            'client_id' => count($clients) + 1, // Генерация нового ID
            'client_name' => $client_name,
            'client_secret' => $client_secret,
            'status' => (int)$status,
            'date_added' => date('Y-m-d H:i:s'),
        ];

        // Сохраняем данные обратно в файл
        file_put_contents($this->data_file, json_encode($clients, JSON_PRETTY_PRINT));
    }

    // Удаление клиента по ID
    public function deleteClient($client_id) {
        $clients = $this->getClients(); // Читаем текущие данные

        // Фильтруем клиентов, исключая нужный ID
        $clients = array_filter($clients, function($client) use ($client_id) {
            return (int)$client['client_id'] !== (int)$client_id;
        });

        // Сохраняем изменённые данные обратно в файл
        file_put_contents($this->data_file, json_encode(array_values($clients), JSON_PRETTY_PRINT));
    }
}
?>
