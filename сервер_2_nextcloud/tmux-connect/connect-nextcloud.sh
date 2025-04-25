#!/bin/bash

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

# Переключаюсь в окно "user2"
tmux select-window -t Connected:1

# Подключаюсь к сессии "Connected"      
tmux attach -t Connected

