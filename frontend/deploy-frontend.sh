#!/bin/bash

#Если свалится одна из команд, рухнет и весь скрипт
set -xe
# Перезаливаем дескриптор сервиса на ВМ для деплоя
sudo cp -rf sausage-store-frontend.service /etc/systemd/system/sausage-store-frontend.service
# Делаем бэкап старой версии, и удаляем файлы
sudo tar -czf /var/www-data/dist/frontend_old.tar.gz /var/www-data/dist/frontend||true # true" - если команда обвалится - продолжай
sudo rm -rf /var/www-data/dist/frontend
# Скачиваем артефакт новой версии
curl -u ${NEXUS_REPO_USER}:${NEXUS_REPO_PASS} -o sausage-store.tar.gz ${NEXUS_REPO_URL}/sausage-store-danil-kuznetsov-frontend/${VERSION}/sausage-store-${VERSION}.tar.gz
# Распаковываем и переносим файл в рабочую директорию
sudo tar -C /var/www-data/dist/ -xzvf sausage-store.tar.gz||true
# Устанавливаем необходимые права на файлы
sudo chown -R front-user:front-user /var/www-data/dist/frontend
# Записываем версию новой сборки
echo ${VERSION} > version.txt
sudo mv ./version.txt /var/www-data/dist/frontend/
sudo chown front-user:front-user /var/www-data/dist/frontend/version.txt
# Обновляем конфиг systemd
sudo systemctl daemon-reload
# Перезапускаем сервис сосисочной
sudo systemctl restart sausage-store-frontend
