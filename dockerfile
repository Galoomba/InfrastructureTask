FROM node:12.2.0 AS builder
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN yarn build
FROM nginx:alpine
COPY --from=builder /app/dist/ /usr/share/nginx/html/
