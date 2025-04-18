#!/bin/bash

# размонтирую папку, чтобы устранить ошибки
umount ~/mnt_user2_nextcloud

# монтирую папку с сервера
sshfs user2@85.159.231.218:/home/user2 ~/mnt_user2_nextcloud

