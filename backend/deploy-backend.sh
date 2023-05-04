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
if [ "$(docker inspect --format "{{.State.Health.Status}}" $(docker-compose ps -q backend_blue))" == "healthy" ]; then
  docker-compose stop backend_green || true
  docker-compose rm -f backend_green || true
  docker-compose pull backend_green
  docker-compose --env-file=backend.env up -d backend_green
  until [ "$(docker inspect --format "{{.State.Health.Status}}" $(docker-compose ps -q backend_green))" != "healthy" ]; do 
    sleep 1;
  done
  docker-compose stop backend_blue
elif [ "$(docker inspect --format "{{.State.Health.Status}}" $(docker-compose ps -q backend_green))" == "healthy" ]; then
  docker-compose rm -f backend_blue || true
  docker-compose pull backend_blue
  docker-compose --env-file=backend.env up -d backend_blue
  until [ "$(docker inspect --format "{{.State.Health.Status}}" $(docker-compose ps -q backend_blue))" != "healthy" ]; do
    sleep 1;
  done
  docker-compose stop backend_green
else
  echo "Warning! No one backend is healthy!"
fi
docker image prune -f
