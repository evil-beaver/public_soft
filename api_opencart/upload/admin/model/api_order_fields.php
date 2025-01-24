<?php
class ModelExtensionModuleApiOrderFields extends Model {
    public function getFields() {
        $query = $this->db->query("SELECT * FROM `" . DB_PREFIX . "api_order_fields`");
        return $query->rows;
    }

    public function addField($field_name, $is_required) {
        $this->db->query("
            INSERT INTO `" . DB_PREFIX . "api_order_fields`
            SET field_name = '" . $this->db->escape($field_name) . "',
                is_required = " . (int)$is_required . ",
                date_added = NOW(),
                date_modified = NOW()
        ");
    }

    public function deleteField($field_id) {
        $this->db->query("DELETE FROM `" . DB_PREFIX . "api_order_fields` WHERE field_id = " . (int)$field_id);
    }
}
?>