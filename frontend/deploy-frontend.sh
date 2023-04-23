#!/bin/bash
set +e
docker login -u ${FRONTEND_REGISTRY_USER} -p ${FRONTEND_REGISTRY_PASSWORD} ${FRONTEND_REGISTRY}
docker pull ${FRONTEND_REGISTRY_IMAGE}/sausage-frontend:latest
docker rm -f frontend || true
set -e
docker run -d \
    --name frontend \
    --network=sausage_network \
    --restart always \
    -p 80:80 \
    ${FRONTEND_REGISTRY_IMAGE}/sausage-frontend:latest
