# Ansible Lab

Учебная лабораторная работа по циклам, условиям и обработке ошибок в Ansible.

## Состав

- `ansible.cfg` — локальная конфигурация Ansible.
- `inventory.ini` — inventory с узлами `node1` и `node2`.
- `basic_loops.yml` — установка пакетов в цикле.
- `basic_loops_practice.yml` — практические примеры простых и сложных циклов.
- `create_users.yml` — создание групп и пользователей из списка словарей.
- `conditions.yml` — условия `when`, операторы сравнения и фильтр `ternary`.
- `error_handling.yml` — примеры `ignore_errors`, `failed_when` и `changed_when`.
- `block_rescue.yml` — обработка ошибок через `block`, `rescue` и `always`.

## Запуск

Команды выполняются из этой директории в Linux или WSL с установленным Ansible:

```bash
ansible-playbook basic_loops.yml
ansible-playbook basic_loops_practice.yml
ansible-playbook create_users.yml
ansible-playbook conditions.yml
ansible-playbook error_handling.yml
ansible-playbook block_rescue.yml
```

## Проверка синтаксиса

```bash
for playbook in *.yml; do
  ansible-playbook --syntax-check "$playbook"
done
```

Повторный запуск идемпотентных playbook должен завершаться без лишних изменений (`changed=0`).
