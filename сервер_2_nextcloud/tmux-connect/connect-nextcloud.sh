#!/bin/bash

#------------------------------------------------------------------------------------
# Монтирую домашнюю директорию сервера как папку "~/mnt_user2_nextcloud"
#------------------------------------------------------------------------------------

# размонтирую папку, чтобы устранить ошибки
umount ~/mnt_user2_nextcloud

# монтирую папку с сервера
sshfs user2@85.159.231.218:/home/user2 ~/mnt_user2_nextcloud


#------------------------------------------------------------------------------------
# Создаю tmux-сессию с двумя окнами: для user2(группа docker без sudo), root
# а также окно в котором будет смонтирована домашняя директория сервера
#------------------------------------------------------------------------------------

# Если сессия существует - подключаюсь к ней, если нет то создаю сессию
tmux has-session -t Connected
if [ $? == 0 ];then
  tmux attach -t Connected
  exit
fi


# создаю сессию "Connected" и окно "user2"
tmux new-session -s Connected -n user2 -d

# Подключаюсь к серверу по ssh@user2
tmux send-keys -t Connected 'ssh user2@85.159.231.218' C-m

# Создаю окно "root"
tmux new-window -n root -t Connected

# Подключаюсь к серверу по ssh@root
tmux send-keys -t Connected:2.1 'ssh root@85.159.231.218' C-m

# создаю окно "mnt"
tmux new-window -n mnt -t Connected

# Перехожу в директорию смонтированной папки
tmux send-keys -t Connected:3.1 'cd ~/mnt_user2_nextcloud' C-m

# Переключаюсь в окно "user2"
tmux select-window -t Connected:1

# Подключаюсь к сессии "Connected"      
tmux attach -t Connected

