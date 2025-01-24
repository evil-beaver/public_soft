<?php
class ModelAccountApi extends Model {
    // Метод для получения клиента по Client-ID и Client-Secret
    public function getClient($client_id, $client_secret) {
        $query = $this->db->query("
            SELECT * FROM `" . DB_PREFIX . "api_clients`
            WHERE client_id = '" . (int)$client_id . "'
            AND client_secret = '" . $this->db->escape($client_secret) . "'
            AND status = 1
        ");

        return $query->row;
    }
}
?>