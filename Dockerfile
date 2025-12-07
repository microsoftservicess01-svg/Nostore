### ---- Stage 1: Build frontend if it exists ----
FROM node:18 AS builder
WORKDIR /repo

# Copy entire repo so Docker never fails on missing paths
COPY . .

# Build client only if it exists
RUN if [ -d "client" ] && [ -f "client/package.json" ]; then \
      cd client && npm install && npm run build; \
    else \
      echo "No client folder found — skipping frontend build"; \
    fi

### ---- Stage 2: Runtime server ----
FROM node:18-alpine AS runtime
WORKDIR /app

# Copy server files if they exist
COPY package.json package-lock.json* ./

RUN if [ -f package.json ]; then npm install --production; fi

# Copy server script if it exists
COPY server.js server.js

# Copy built frontend only if it was produced
COPY --from=builder /repo/client/dist ./client/dist

EXPOSE 3000
CMD ["node", "server.js"]


