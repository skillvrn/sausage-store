#!/bin/bash

#Если свалится одна из команд, рухнет и весь скрипт
set -xe
# Перезаливаем дескриптор сервиса на ВМ для деплоя
sudo cp -rf sausage-store-backend.service /etc/systemd/system/sausage-store-backend.service
# Создаем environment для unit'а и наполняем его переменными
echo "PGSQL_URL=${PGSQL_URL}" | sudo tee /etc/systemd/system/sausage-store-backend.env > /dev/null
echo "PGSQL_DB=${PGSQL_DB}" | sudo tee -a /etc/systemd/system/sausage-store-backend.env > /dev/null
echo "PGSQL_USER=${PGSQL_USER}" | sudo tee -a /etc/systemd/system/sausage-store-backend.env > /dev/null
echo "PGSQL_PASS=${PGSQL_PASS}" | sudo tee -a /etc/systemd/system/sausage-store-backend.env > /dev/null
echo "MONGO_USER=${MONGO_USER}" | sudo tee -a /etc/systemd/system/sausage-store-backend.env > /dev/null
echo "MONGO_PASSWORD=${MONGO_PASSWORD}" | sudo tee -a /etc/systemd/system/sausage-store-backend.env > /dev/null
echo "MONGO_HOST=${MONGO_HOST}" | sudo tee -a /etc/systemd/system/sausage-store-backend.env > /dev/null
echo "MONGO_DATABASE=${MONGO_DATABASE}" | sudo tee -a /etc/systemd/system/sausage-store-backend.env > /dev/null
# Скачиваем сертификат для подключения к внешнему сервису
wget "https://storage.yandexcloud.net/cloud-certs/CA.pem" -O YandexInternalRootCA.crt
sudo keytool -importcert \
    -file YandexInternalRootCA.crt \
    -alias yandex \
    -cacerts \
    -storepass changeit \
    -noprompt || true  # если сертификат уже имеется, то пропускаем ошибку наличия алиаса <yandex>
# Делаем бэкап старой версии jar-ника
sudo mv /var/jarservice/sausage-store.jar /var/jarservice/sausage-store-old.jar||true # true" - если команда обвалится - продолжай
# Скачиваем артефакт новой версии
curl -u ${NEXUS_REPO_USER}:${NEXUS_REPO_PASS} -o sausage-store.jar ${NEXUS_REPO_URL}/sausage-store-kuznetsov-danil-backend/com/yandex/practicum/devops/sausage-store/${VERSION}/sausage-store-${VERSION}.jar
# Переносим файл в рабочую директорию
sudo mv ./sausage-store.jar /var/jarservice/sausage-store.jar||true
# Устанавливаем права на jar для пользователя jarservice и группы jarusers
sudo chown jarservice:jarusers /var/jarservice/sausage-store.jar
# Записываем версию нового jar'ника
echo ${VERSION} > jar-version.txt
sudo mv jar-version.txt /var/jarservice/
sudo chown jarservice:jarusers /var/jarservice/jar-version.txt
# Обновляем конфиг systemd
sudo systemctl daemon-reload
# Перезапускаем сервис сосисочной
sudo systemctl restart sausage-store-backend
