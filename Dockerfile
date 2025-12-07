
FROM node:18 AS builder
WORKDIR /app
COPY client/package.json client/package-lock.json ./client/
WORKDIR /app/client
RUN npm ci --silent
COPY client ./client
RUN npm run build

FROM node:18-alpine AS runtime
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci --production --silent
COPY server.js ./
COPY --from=builder /app/client/dist ./client/dist
EXPOSE 3000
CMD ["node", "server.js"]
