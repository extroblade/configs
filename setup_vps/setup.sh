#!/bin/bash

# Проверяем, что передан файл конфигурации
if [ -z "$1" ]; then
    echo "Не передан файл с конфигурацией. Используйте --file file.name"
    exit 1
fi

# Путь к файлу конфигурации
FILE=$1
SSH_KEY_STRING=""
FAIL2BAN_CONFIG_FILE=""

# Проверяем, что файл существует
if [ ! -f "$FILE" ]; then
    echo "Файл $FILE не существует!"
    exit 1
fi

# Чтение данных из файла конфигурации
source "$FILE"

# Проверка, что все необходимые переменные заданы
if [ -z "$username" ] || [ -z "$password" ] || [ -z "$ssh" ]; then
    echo "Некоторые обязательные параметры отсутствуют в файле конфигурации!"
    exit 1
fi

# Проверка наличия публичного ключа
if [ -z "$ssh" ]; then
    echo "Публичный ключ не указан!"
    exit 1
fi

# Создание пользователя
echo "Создаем пользователя $username..."
sudo useradd -m -s /bin/bash "$username"

# Устанавливаем пароль для нового пользователя
echo "$username:$password" | sudo chpasswd

# Добавляем пользователя в группу sudo
echo "Добавляем пользователя $username в группу sudo..."
sudo usermod -aG sudo "$username"

# Создание папки .ssh и добавление публичного ключа
echo "Настроим SSH для пользователя $username..."
sudo mkdir -p /home/$username/.ssh
echo "$ssh" | sudo tee /home/$username/.ssh/authorized_keys > /dev/null
sudo chown -R "$username":"$username" /home/$username/.ssh
sudo chmod 700 /home/$username/.ssh
sudo chmod 600 /home/$username/.ssh/authorized_keys

# Настройка SSH для отказа от root и разрешения входа только для пользователя
echo "Настроим SSH для авторизации только через $username..."
# Резервируем оригинальный конфиг
sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak

# Отключаем вход root, разрешаем авторизацию через пароль
sudo sed -i 's/^PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
sudo sed -i 's/^PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config

# Разрешим доступ только указанному пользователю
echo "AllowUsers $username" | sudo tee -a /etc/ssh/sshd_config > /dev/null

# Перезапускаем SSH для применения изменений
echo "Перезапускаем SSH для применения изменений..."
sudo systemctl restart sshd

# Установка Fail2Ban
echo "Устанавливаем Fail2Ban..."
sudo apt update
sudo apt install -y fail2ban

# Проверка, передан ли файл с конфигом для Fail2Ban
if [ -z "$fail2ban_config" ]; then
    # Используем стандартный конфиг из ./fail2ban_default
    echo "Не передан файл с конфигурацией Fail2Ban. Используется стандартный конфиг."
    
    FAIL2BAN_CONFIG_FILE="./fail2ban_default"
    
    # Проверка существования дефолтного конфига
    if [ ! -d "$FAIL2BAN_CONFIG_FILE" ]; then
        echo "Дефолтный конфиг Fail2Ban не найден в $FAIL2BAN_CONFIG_FILE!"
        exit 1
    fi

    # Копируем дефолтный конфиг в нужное место
    sudo cp "$FAIL2BAN_CONFIG_FILE/jail.local" /etc/fail2ban/jail.local
else
    # Используем указанный файл конфигурации для Fail2Ban
    echo "Используется конфигурация Fail2Ban из файла $fail2ban_config."
    sudo cp "$fail2ban_config" /etc/fail2ban/jail.local
fi

# Перезапуск Fail2Ban
echo "Перезапускаем Fail2Ban..."
sudo systemctl restart fail2ban

echo "Настройка завершена успешно. Параметры: username=$username, password=******, ssh=$ssh"
