# build
FROM golang:latest as builder
ARG VERSION=${VERSION}
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o main .
RUN curl https://storage.yandexcloud.net/cloud-certs/CA.pem -o YandexInternalRootCA.crt

# release
FROM alpine:latest
ARG VERSION=${VERSION}
RUN apk --no-cache add ca-certificates
WORKDIR /root/
COPY --from=builder /app/YandexInternalRootCA.crt .
COPY --from=builder /app/main .
EXPOSE 8080
CMD ["./main"]
