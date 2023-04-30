#!/bin/bash
set +e
cat > reports.env <<EOF
BACKEND_REPORT_REGISTRY_IMAGE=${BACKEND_REPORT_REGISTRY_IMAGE}
DB=${MONGODB_URI}&tlsCaFile=YandexInternalRootCA.crt
EOF
docker login -u ${BACKEND_REPORT_REGISTRY_USER} -p ${BACKEND_REPORT_REGISTRY_PASSWORD} ${BACKEND_REPORT_REGISTRY}
docker-compose --env-file reports.env pull reports
set -e
docker-compose --env-file reports.env up --force-recreate --remove-orphans -d reports
