#!/bin/bash

# размонтирую папку, чтобы устранить ошибки
umount ~/Server_connect/mnt_user2_nextcloud

# монтирую папку с сервера
sshfs user2@85.159.231.218:/home/user2 ~/Server_connect/mnt_user2_nextcloud

