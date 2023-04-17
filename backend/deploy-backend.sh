#!/bin/bash
set +e
cat > .env <<EOF
SPRING_DATASOURCE_URL=${SPRING_DATASOURCE_URL}
SPRING_DATASOURCE_USERNAME=${SPRING_DATASOURCE_USERNAME}
SPRING_DATASOURCE_PASSWORD=${SPRING_DATASOURCE_PASSWORD}
SPRING_DATA_MONGODB_URI=${SPRING_DATA_MONGODB_URI}
SPRING_FLYWAY_ENABLED=false
EOF
docker network create -d bridge sausage_network || true
docker login -u ${BACKEND_REGISTRY_USER} -p ${BACKEND_REGISTRY_PASSWORD} ${BACKEND_REGISTRY}
docker pull ${BACKEND_REGISTRY_IMAGE}/sausage-backend:latest
docker rm -f backend || true
set -e
docker run -d \
    --env-file .env \
    --name backend \
    --network=sausage_network \
    --restart always \
    ${BACKEND_REGISTRY_IMAGE}/sausage-backend:latest
