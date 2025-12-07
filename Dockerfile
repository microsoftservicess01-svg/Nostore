### Stage 1: builder
FROM node:18 AS builder
WORKDIR /repo

COPY . .

# Always ensure dist folder exists
RUN mkdir -p client/dist

# Build client only if it exists
RUN if [ -f client/package.json ]; then \
      cd client && npm install --silent && npm run build; \
    else \
      echo "Skipping client build"; \
    fi


### Stage 2: runtime
FROM node:18-alpine
WORKDIR /app

COPY package.json package-lock.json* ./
RUN npm install --production --silent || npm install --production --silent

COPY server.js .

# Copy dist safely (because it ALWAYS exists)
COPY --from=builder /repo/client/dist ./client/dist

EXPOSE 3000
CMD ["node", "server.js"]


