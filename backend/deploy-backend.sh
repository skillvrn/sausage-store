#!/bin/bash
set +e
echo "Creating env file..."
cat > backend.env <<EOF
BACKEND_REGISTRY_IMAGE=${BACKEND_REGISTRY_IMAGE}
VAULT_ADDR=${VAULT_ADDR}
SPRING_DATASOURCE_URL=${SPRING_DATASOURCE_URL}
SPRING_DATASOURCE_USERNAME=${SPRING_DATASOURCE_USERNAME}
SPRING_DATASOURCE_PASSWORD=${SPRING_DATASOURCE_PASSWORD}
SPRING_FLYWAY_ENABLED=false
REPORT_PATH=./logs
EOF
echo "Env file created!"
docker login -u ${BACKEND_REGISTRY_USER} -p ${BACKEND_REGISTRY_PASSWORD} ${BACKEND_REGISTRY}
set -e
echo "Checking if Blue container is healthy..."
if [ "$(docker inspect --format "{{.State.Health.Status}}" $(docker-compose ps -q backend_blue))" == "healthy" ]; then
  echo "Blue container is healthy!"
  docker-compose stop backend_green || true
  docker-compose rm -f backend_green || true
  docker-compose pull backend_green
  docker-compose --env-file=backend.env up -d backend_green
  for i in {1..20}
  do
    echo "Checking health of new Green container..."
    sleep 1
    if [ "$(docker inspect --format "{{.State.Health.Status}}" $(docker-compose ps -q backend_green))" == "healthy" ]; then
      echo "New Green container in healthy state!"
      sleep 2  # Ensure all requests were processed
      docker-compose stop backend_blue
      docker image prune -f
      echo "Deployment successful!"
      break
    else
      echo "New Green service is not ready yet. Waiting ($i)..."
    fi
  done
else
  echo "Blue container is not healthy, checking if Green container is healthy..."
  if [ "$(docker inspect --format "{{.State.Health.Status}}" $(docker-compose ps -q backend_green))" == "healthy" ]; then
    echo "Green container is healthy!"
    docker-compose rm -f backend_blue || true
    docker-compose pull backend_blue
    docker-compose --env-file=backend.env up -d backend_blue
    for i in {1..20}
    do
      echo "Checking health of new Blue container..."
      sleep 1
      if [ "$(docker inspect --format "{{.State.Health.Status}}" $(docker-compose ps -q backend_blue))" == "healthy" ]; then
        echo "New Blue container in healthy state!"
        sleep 2  # Ensure all requests were processed
        docker-compose stop backend_green
        docker image prune -f
        echo "Deployment successful!"
        break
      else
        echo "New Blue service is not ready yet. Waiting ($i)..."
      fi
    done
  else
    echo "Warning! No one backend is healthy!"
    echo "New service did not raise. Failed to deploy T_T"
  fi
fi
