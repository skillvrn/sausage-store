# build
FROM maven:3.8.2-openjdk-16-slim as builder
ARG VERSION=${VERSION}
WORKDIR /app
COPY ./src ./src
COPY *.xml ./
RUN curl https://storage.yandexcloud.net/cloud-certs/CA.pem -o YandexInternalRootCA.crt \
    && mvn package -Dversion.application=${VERSION}

# release
FROM openjdk:16-jdk-alpine
ARG VERSION=${VERSION}
WORKDIR /app
COPY --from=builder /app/YandexInternalRootCA.crt .
RUN keytool -importcert -file YandexInternalRootCA.crt \
    -alias yandex -cacerts -storepass changeit -noprompt \
    && rm -rf YandexInternalRootCA.crt \
    && addgroup --system jaruser \
    && adduser -S -s /bin/false -G jaruser jaruser -D -H \
    && apk add --no-cache curl dumb-init==1.2.5-r0 \
    && mkdir -m 777 ./logs
COPY --chown=jaruser:jaruser \
     --from=builder /app/target/sausage-store-${VERSION}.jar ./sausage-store.jar
EXPOSE 8080
USER jaruser
ENTRYPOINT ["dumb-init", "java", "-jar", "-Dmyserver.bindPort=8080", "./sausage-store.jar"]
