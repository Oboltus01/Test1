# Ansible Homework — Multi-Environment Nginx

Учебный проект автоматического развёртывания и настройки двух Nginx-серверов с помощью Ansible и Docker Compose.

## Цель проекта

Проект повторяет материалы урока:

- inventory и группы хостов;
- переменные групп и отдельных хостов;
- сбор системных фактов;
- Jinja2-шаблоны;
- условия и циклы;
- Ansible handlers;
- установка и запуск Nginx;
- проверка идемпотентности.

## Дополнительный challenge

В проект добавлены:

- два разных окружения: Production и Development;
- разные цвета страниц для окружений;
- разные значения `client_max_body_size`;
- endpoint `/health`;
- автоматическая HTTP-проверка через модуль `uri`;
- проверка содержимого ответа через модуль `assert`;
- воспроизводимый стенд Docker Compose.

## Структура проекта

```text
ansible_homework/
├── group_vars/
│   └── webservers.yml
├── host_vars/
│   ├── node1.yml
│   └── node2.yml
├── templates/
│   ├── index.html.j2
│   └── nginx.conf.j2
├── deploy_custom_site.yml
├── docker-compose.yml
├── inventory.ini
└── README.md
```

## Окружения

| Контейнер | Окружение | Внешний порт | Цвет | Body size |
|---|---|---:|---|---|
| node1 | Production | 8081 | Синий | 10M |
| node2 | Development | 8082 | Зелёный | 50M |

## Требования

- Windows с Docker Desktop;
- WSL2 с Ubuntu 24.04;
- Ansible внутри WSL;
- Docker Compose.

## Запуск контейнеров

В PowerShell:

```powershell
Set-Location "H:\2079-DEVOPS ANTON\Lesson16_07.08.26\ansible_homework"

docker compose up -d
docker compose ps
```

Ожидаемый результат: контейнеры `node1` и `node2` находятся в состоянии `Up`.

## Запуск Ansible

Переход в WSL:

```powershell
wsl -d Ubuntu-24.04
```

Переход в каталог проекта:

```bash
cd "/mnt/h/2079-DEVOPS ANTON/Lesson16_07.08.26/ansible_homework"
```

Проверка соединения:

```bash
ansible all -i inventory.ini -m ping
```

Проверка inventory:

```bash
ansible-inventory -i inventory.ini --graph
ansible-inventory -i inventory.ini --host node1
ansible-inventory -i inventory.ini --host node2
```

Проверка синтаксиса playbook:

```bash
ansible-playbook -i inventory.ini deploy_custom_site.yml --syntax-check
```

Запуск playbook:

```bash
ansible-playbook -i inventory.ini deploy_custom_site.yml
```

## Проверка идемпотентности

Playbook необходимо запустить повторно:

```bash
ansible-playbook -i inventory.ini deploy_custom_site.yml
```

При повторном запуске ожидается:

```text
changed=0
failed=0
```

## Проверка сайта

Production:

```text
http://localhost:8081
```

Development:

```text
http://localhost:8082
```

Health endpoints:

```text
http://localhost:8081/health
http://localhost:8082/health
```

Ожидаемые ответы:

```text
healthy: node1 (Production)
healthy: node2 (Development)
```

## Остановка стенда

Выйти из WSL:

```bash
exit
```

Затем в PowerShell:

```powershell
Set-Location "H:\2079-DEVOPS ANTON\Lesson16_07.08.26\ansible_homework"

docker compose down
```

## Результат

Ansible автоматически:

1. собирает системные факты;
2. устанавливает Nginx;
3. создаёт индивидуальную HTML-страницу для каждого узла;
4. создаёт конфигурацию Nginx из Jinja2-шаблона;
5. перезапускает Nginx только при изменении конфигурации;
6. проверяет главную страницу и endpoint `/health`;
7. подтверждает правильность возвращённого содержимого.