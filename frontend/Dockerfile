# build
FROM node:16 as builder
WORKDIR /app
COPY . .
RUN npm install \
    && npm run build

# release
FROM nginxproxy/nginx-proxy:alpine
WORKDIR /app
COPY --from=builder /app/dist/frontend/*.* /usr/share/nginx/html/
COPY ./nginx.tmpl /app/nginx.tmpl
