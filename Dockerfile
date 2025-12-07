### ---- Stage 1: Builder ----
FROM node:18 AS builder
WORKDIR /repo

# Copy everything from repository
COPY . .

# Always create dist folder so Render won’t error
RUN mkdir -p /repo/client/dist

# If client exists, build it
RUN if [ -d "client" ] && [ -f "client/package.json" ]; then \
      echo "Building client..."; \
      cd client && npm install && npm run build; \
    else \
      echo "No client folder found — using empty dist"; \
    fi


### ---- Stage 2: Runtime ----
FROM node:18-alpine AS runtime
WORKDIR /app

# Copy server package files
COPY package.json package-lock.json* ./
RUN npm install --production || npm install --production

# Copy server
COPY server.js .

# Copy frontend (folder always exists now)
COPY --from=builder /repo/client/dist ./client/dist

EXPOSE 3000
CMD ["node", "server.js"]
