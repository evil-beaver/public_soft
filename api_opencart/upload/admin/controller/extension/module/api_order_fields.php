<?php
class ControllerExtensionModuleApiOrderFields extends Controller {
    public function index() {
        $this->load->language('extension/module/api_order_fields');
        $this->document->setTitle($this->language->get('heading_title'));

        $this->load->model('extension/module/api_order_fields');

        // Получаем список полей
        $data['fields'] = $this->model_extension_module_api_order_fields->getFields();

        // Подключаем шаблон
        $data['header'] = $this->load->controller('common/header');
        $data['column_left'] = $this->load->controller('common/column_left');
        $data['footer'] = $this->load->controller('common/footer');

        $this->response->setOutput($this->load->view('extension/module/api_order_fields', $data));
    }

    public function add() {
        $this->load->model('extension/module/api_order_fields');

        if ($this->request->server['REQUEST_METHOD'] == 'POST') {
            $field_name = $this->request->post['field_name'];
            $is_required = $this->request->post['is_required'] ?? 0;

            $this->model_extension_module_api_order_fields->addField($field_name, $is_required);
            $this->response->redirect($this->url->link('extension/module/api_order_fields', 'user_token=' . $this->session->data['user_token'], true));
        }
    }

    public function delete() {
        $this->load->model('extension/module/api_order_fields');

        if (isset($this->request->get['field_id'])) {
            $field_id = $this->request->get['field_id'];
            $this->model_extension_module_api_order_fields->deleteField($field_id);
            $this->response->redirect($this->url->link('extension/module/api_order_fields', 'user_token=' . $this->session->data['user_token'], true));
        }
    }
}
?>