<?php
class ModelExtensionModuleApiClients extends Model {
    public function getClients() {
        $query = $this->db->query("SELECT * FROM `" . DB_PREFIX . "api_clients`");
        return $query->rows;
    }

    public function addClient($client_name, $client_secret, $status) {
        $this->db->query("
            INSERT INTO `" . DB_PREFIX . "api_clients`
            SET client_name = '" . $this->db->escape($client_name) . "',
                client_secret = '" . $this->db->escape($client_secret) . "',
                status = " . (int)$status . ",
                date_added = NOW()
        ");
    }

    public function deleteClient($client_id) {
        $this->db->query("DELETE FROM `" . DB_PREFIX . "api_clients` WHERE client_id = " . (int)$client_id);
    }
}
?>