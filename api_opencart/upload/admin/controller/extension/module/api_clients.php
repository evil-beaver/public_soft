<?php
class ControllerExtensionModuleApiClients extends Controller {
    public function index() {
        $this->load->language('extension/module/api_clients');
        $this->document->setTitle($this->language->get('heading_title'));

        $this->load->model('extension/module/api_clients');

        $data['clients'] = $this->model_extension_module_api_clients->getClients();
        $data['add_url'] = $this->url->link('extension/module/api_clients/add', 'user_token=' . $this->session->data['user_token'], true);
        $data['delete_url'] = $this->url->link('extension/module/api_clients/delete', 'user_token=' . $this->session->data['user_token'], true);

        $data['header'] = $this->load->controller('common/header');
        $data['column_left'] = $this->load->controller('common/column_left');
        $data['footer'] = $this->load->controller('common/footer');

        $this->response->setOutput($this->load->view('extension/module/api_clients', $data));
    }

    public function add() {
        $this->load->model('extension/module/api_clients');

        if ($this->request->server['REQUEST_METHOD'] == 'POST') {
            $client_name = $this->request->post['client_name'];
            $client_secret = bin2hex(random_bytes(16)); // Генерация случайного секрета
            $status = $this->request->post['status'];

            $this->model_extension_module_api_clients->addClient($client_name, $client_secret, $status);
            $this->response->redirect($this->url->link('extension/module/api_clients', 'user_token=' . $this->session->data['user_token'], true));
        }
    }

    public function delete() {
        $this->load->model('extension/module/api_clients');

        if (isset($this->request->get['client_id'])) {
            $client_id = $this->request->get['client_id'];
            $this->model_extension_module_api_clients->deleteClient($client_id);
            $this->response->redirect($this->url->link('extension/module/api_clients', 'user_token=' . $this->session->data['user_token'], true));
        }
    }
}
?>