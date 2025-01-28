<?php
class ControllerExtensionModuleApiClients extends Controller {

    public function index() {
        // Загружаем языковой файл
        $this->load->language('extension/module/api_clients');

        // Устанавливаем заголовок страницы
        $this->document->setTitle($this->language->get('heading_title'));

        // Проверяем, авторизован ли пользователь
        if (!isset($this->session->data['user_token'])) {
            $this->response->redirect($this->url->link('common/login', '', true));
            return;
        }

        // Загружаем модель
        $this->load->model('extension/module/api_clients');

        // Получаем список клиентов
        $data['clients'] = $this->model_extension_module_api_clients->getClients();

        // Генерируем URL с user_token
        $data['user_token'] = $this->session->data['user_token'];
        $data['add_url'] = $this->url->link('extension/module/api_clients/add', 'user_token=' . $this->session->data['user_token'], true);
        $data['delete_url'] = $this->url->link('extension/module/api_clients/delete', 'user_token=' . $this->session->data['user_token'], true);

        // Загружаем стандартные элементы интерфейса
        $data['header'] = $this->load->controller('common/header');
        $data['column_left'] = $this->load->controller('common/column_left');
        $data['footer'] = $this->load->controller('common/footer');

        // Выводим шаблон
        $this->response->setOutput($this->load->view('extension/module/api_clients', $data));
    }

    public function add() {
        // Проверяем, авторизован ли пользователь
        if (!isset($this->session->data['user_token'])) {
            $this->response->redirect($this->url->link('common/login', '', true));
            return;
        }

        // Загружаем модель
        $this->load->model('extension/module/api_clients');

        // Обрабатываем POST-запрос
        if ($this->request->server['REQUEST_METHOD'] == 'POST' && $this->validateForm()) {
            $client_name = $this->request->post['client_name'];
            $client_secret = bin2hex(random_bytes(16)); // Генерация случайного секрета
            $status = $this->request->post['status'];

            // Добавляем клиента
            $this->model_extension_module_api_clients->addClient($client_name, $client_secret, $status);

            // Перенаправляем на страницу списка клиентов
            $this->response->redirect($this->url->link('extension/module/api_clients', 'user_token=' . $this->session->data['user_token'], true));
        }
    }

    public function delete() {
        // Проверяем, авторизован ли пользователь
        if (!isset($this->session->data['user_token'])) {
            $this->response->redirect($this->url->link('common/login', '', true));
            return;
        }

        // Загружаем модель
        $this->load->model('extension/module/api_clients');

        // Удаляем клиента, если передан client_id
        if (isset($this->request->get['client_id'])) {
            $client_id = (int)$this->request->get['client_id'];
            $this->model_extension_module_api_clients->deleteClient($client_id);
        }

        // Перенаправляем на страницу списка клиентов
        $this->response->redirect($this->url->link('extension/module/api_clients', 'user_token=' . $this->session->data['user_token'], true));
    }

    protected function validateForm() {
        // Проверяем права доступа
        if (!$this->user->hasPermission('modify', 'extension/module/api_clients')) {
            $this->error['warning'] = $this->language->get('error_permission');
        }

        // Проверяем, заполнено ли поле client_name
        if (empty($this->request->post['client_name'])) {
            $this->error['client_name'] = $this->language->get('error_client_name');
        }

        return !$this->error;
    }
}
?>