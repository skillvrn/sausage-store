#!/bin/bash
set +e
cat > frontend.env <<EOF
FRONTEND_REGISTRY_IMAGE=${FRONTEND_REGISTRY_IMAGE}
EOF
docker login -u ${FRONTEND_REGISTRY_USER} -p ${FRONTEND_REGISTRY_PASSWORD} ${FRONTEND_REGISTRY}
docker-compose --env-file frontend.env pull frontend
set -e
docker-compose up --force-recreate --remove-orphans -d frontend
docker image prune -f
