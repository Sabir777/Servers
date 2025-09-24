#!/data/data/com.termux/files/usr/bin/env bash
#------------------------------------------------------------------------------------
# Создаю tmux-сессию с двумя окнами: для user2(группа docker без sudo), root
# а также окно в котором будет смонтирована домашняя директория сервера
#------------------------------------------------------------------------------------

SESSION_NAME="Connected"
SERVER_IP="85.159.231.218"

# Функция для безопасного выполнения команд с таймаутом
safe_send_keys() {
    local window=$1
    local command=$2
    local timeout=${3:-10}
    
    echo "Выполняю в окне $window: $command"
    tmux send-keys -t "$window" "$command" C-m
    
    # Даем время на выполнение команды
    sleep $timeout
}

# Проверяем доступность сервера
echo "Проверяю доступность сервера $SERVER_IP..."
if ! ping -c 1 -W 3 "$SERVER_IP" > /dev/null 2>&1; then
    echo "Ошибка: Сервер $SERVER_IP недоступен!"
    exit 1
fi

# Если сессия существует - подключаюсь к ней
if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
    echo "Сессия $SESSION_NAME уже существует, подключаюсь..."
    tmux attach -t "$SESSION_NAME"
    exit 0
fi

echo "Создаю новую tmux сессию..."

# Создаю сессию и первое окно "user2"
tmux new-session -s "$SESSION_NAME" -n user2 -d

# Ждем создания сессии
sleep 1

# Подключаюсь к серверу по ssh@user2 с таймаутом
echo "Подключаюсь к user2@$SERVER_IP..."
safe_send_keys "$SESSION_NAME:user2" "ssh -o ConnectTimeout=10 -o ServerAliveInterval=30 user2@$SERVER_IP" 5

# Создаю окно "root"
tmux new-window -n root -t "$SESSION_NAME"

# Подключаюсь к серверу по ssh@root с таймаутом
echo "Подключаюсь к root@$SERVER_IP..."
safe_send_keys "$SESSION_NAME:root" "ssh -o ConnectTimeout=10 -o ServerAliveInterval=30 root@$SERVER_IP" 5

# Создаю окно "mnt"
tmux new-window -n mnt -t "$SESSION_NAME"

# Проверяем существование директории mount
echo "Настраиваю SSHFS монтирование..."
safe_send_keys "$SESSION_NAME:mnt" "mkdir -p ~/mnt_user2_nextcloud" 2

# Размонтируем если уже смонтировано и монтируем заново
MOUNT_COMMAND="sudo umount ~/mnt_user2_nextcloud 2>/dev/null; sshfs -o reconnect,ServerAliveInterval=15,ServerAliveCountMax=3 user2@$SERVER_IP:/home/user2 ~/mnt_user2_nextcloud && cd ~/mnt_user2_nextcloud && ls -la"
safe_send_keys "$SESSION_NAME:mnt" "$MOUNT_COMMAND" 8

# Переключаюсь в окно "user2"
tmux select-window -t "$SESSION_NAME:user2"

echo "Подключаюсь к сессии $SESSION_NAME..."
# Подключаюсь к сессии
tmux attach -t "$SESSION_NAME"
