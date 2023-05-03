#!/bin/bash
set +e
cat > backend.env <<EOF
BACKEND_REGISTRY_IMAGE=${BACKEND_REGISTRY_IMAGE}
VAULT_ADDR=${VAULT_ADDR}
SPRING_DATASOURCE_URL=${SPRING_DATASOURCE_URL}
SPRING_DATASOURCE_USERNAME=${SPRING_DATASOURCE_USERNAME}
SPRING_DATASOURCE_PASSWORD=${SPRING_DATASOURCE_PASSWORD}
SPRING_FLYWAY_ENABLED=false
REPORT_PATH=./logs
EOF
docker login -u ${BACKEND_REGISTRY_USER} -p ${BACKEND_REGISTRY_PASSWORD} ${BACKEND_REGISTRY}
docker-compose --env-file backend.env pull backend
set -e
docker-compose --env-file backend.env up --force-recreate --remove-orphans --scale backend=2 -d backend
