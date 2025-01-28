<?php
class ModelExtensionModuleApiOrderFields extends Model {
    private $data_file = DIR_STORAGE . 'api_data/order_fields.json';

    // Метод для получения всех полей
    public function getFields() {
        if (!file_exists($this->data_file)) {
            return []; // Если файла нет, возвращаем пустой массив
        }
        $fields = json_decode(file_get_contents($this->data_file), true);
        return $fields ?: []; // Возвращаем массив или пустое значение
    }

    // Метод для добавления нового поля
    public function addField($field_name, $is_required) {
        $fields = $this->getFields(); // Получаем текущие поля

        // Добавляем новое поле
        $fields[] = [
            'field_id' => count($fields) + 1, // Генерация ID
            'field_name' => $field_name,
            'is_required' => (bool)$is_required,
            'date_added' => date('Y-m-d H:i:s'),
            'date_modified' => date('Y-m-d H:i:s')
        ];

        // Сохраняем данные обратно в файл
        file_put_contents($this->data_file, json_encode($fields, JSON_PRETTY_PRINT));
    }

    // Метод для удаления поля по ID
    public function deleteField($field_id) {
        $fields = $this->getFields(); // Получаем текущие поля

        // Фильтруем массив, исключая поле с указанным ID
        $fields = array_filter($fields, function($field) use ($field_id) {
            return $field['field_id'] != $field_id;
        });

        // Сохраняем изменения в файл
        file_put_contents($this->data_file, json_encode(array_values($fields), JSON_PRETTY_PRINT));
    }
}
?>
