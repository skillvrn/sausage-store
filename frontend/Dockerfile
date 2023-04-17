# build
FROM node:16 as builder
WORKDIR /app
COPY . .
RUN npm install \
    && npm run build

# release
FROM node:16-alpine
WORKDIR /app
COPY --from=builder /app/dist/frontend/ /app/frontend/
RUN addgroup --system front-user \
    && adduser -S -s /bin/false -G front-user front-user -D -H \
    && chown -R front-user:front-user /app/frontend \
    && npm install -g http-server 
EXPOSE 80
USER front-user
ENTRYPOINT ["http-server", "/app/frontend/", "-p", "80", "--proxy", "http://backend:8080"]
