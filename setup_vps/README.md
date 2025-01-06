# Скрипт для настройки SSH и Fail2Ban

Этот скрипт позволяет создать нового пользователя с указанным паролем, настроить SSH для работы с публичным ключом, настроить разрешение на подключение только этого пользователя (без root), и установить Fail2Ban для защиты от несанкционированных попыток входа.

## Требования

- Ubuntu/Debian-система.
- Публичный SSH-ключ в строковом формате.
- Файл конфигурации Fail2Ban, если требуется кастомизация (опционально).

## Структура проекта

./fail2ban_default/jail.local # Дефолтный конфиг Fail2Ban ./config.txt # Файл с настройками пользователя и SSH ./setup_ssh.sh # Скрипт для настройки

arduino
Копировать код

## Использование

1. Создайте файл конфигурации, например `config.txt`:

   Пример:
   ```bash
   username="newuser"
   password="userpassword"
   ssh="ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEArYyGZKAl62q9VnzJGgLt8NEwpYZJkX7l1lbV4owQWgKzJ78P3PijCxE4NMbJeD3FiYUn3Y5cXfR8MQm1KFOghC7qBYAXkFH41swOIfm62kddpIcYcGr5El68vFfh65n9M4h0K1D1drYrVydn9bh9bdUSKgsu3tX3_2JOpwHmWhdlOrUBGRVxj8qoaKkxVdwRVDfF5w5Q2Hvn78b68EjjWqgQ=="
   fail2ban_config="./fail2ban_config/jail.local"
Запустите скрипт:

bash
Копировать код
./setup_ssh.sh config.txt
Если файл конфигурации для Fail2Ban не указан, будет использован дефолтный конфиг из ./fail2ban_default/jail.local.

Скрипт создаст нового пользователя, настроит SSH для авторизации с публичным ключом, настроит доступ только для этого пользователя, установит Fail2Ban и применит конфигурацию.

Примечания
Публичный ключ в конфигурационном файле должен быть строкой, как указано в примере.
Fail2Ban будет настроен с дефолтной конфигурацией, если файл конфигурации для Fail2Ban не передан.