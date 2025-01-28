<?php
class ModelAccountApi extends Model {
    private $data_file = DIR_STORAGE . 'api_data/clients.json';

    // Метод для получения клиента по Client-ID и Client-Secret
    public function getClient($client_id, $client_secret) {
        if (!file_exists($this->data_file)) {
            return null; // Если файл не найден, возвращаем null
        }

        $clients = json_decode(file_get_contents($this->data_file), true);
        if (!$clients) {
            return null; // Если файл пуст или данные невалидны
        }

        // Поиск клиента по ID и секрету
        foreach ($clients as $client) {
            if ((int)$client['client_id'] === (int)$client_id 
                && $client['client_secret'] === $client_secret 
                && (int)$client['status'] === 1) {
                return $client;
            }
        }

        return null; // Если клиент не найден
    }
}
?>
