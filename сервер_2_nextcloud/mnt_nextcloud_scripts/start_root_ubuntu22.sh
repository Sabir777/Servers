#!/bin/bash

# запускаю ssh-сервер
sshd

# запускаю tmux
tmux has-session -t Mnt
if [ $? == 0 ]; then
  tmux attach -t Mnt
  exit
fi

# создаю сессию "Mnt" и окно "mnt"
tmux new-session -s Mnt -n mnt -d

# запускаю ubuntu с правами root
tmux send-keys -t Mnt 'sudo bash start-ubuntu22.sh' C-m

# Подключаюсь к сессии "Mnt"      
tmux attach -t Mnt
