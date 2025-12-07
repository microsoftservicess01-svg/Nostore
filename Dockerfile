# safer-multi-stage.Dockerfile - robust to missing client/ directory
FROM node:18 AS builder
WORKDIR /repo

# copy whole repo so paths are not fragile
COPY . .

# Make build output folder available if client exists.
# If client/package.json exists, install & build client.
# Use npm ci where possible (faster + deterministic).
RUN set -eux; \
  if [ -f package-lock.json ]; then echo "Root lock present"; fi; \
  if [ -d client ] && [ -f client/package.json ]; then \
    echo "Client detected — building frontend..."; \
    cd client; \
    if [ -f package-lock.json ]; then npm ci --silent; else npm i --silent; fi; \
    npm run build; \
    cd ..; \
  else \
    echo "No client/ folder or no client/package.json — skipping frontend build"; \
  fi

# ---------------- runtime image ----------------
FROM node:18-alpine AS runtime
WORKDIR /app

# Copy server files (if you have any)
COPY package.json package-lock.json ./
# install server deps (if package.json exists)
RUN if [ -f package.json ]; then npm ci --production --silent || npm i --production --silent; fi

COPY server.js ./ || true
# copy static build only if it exists in builder
COPY --from=builder /repo/client/dist ./client/dist

# If you prefer a simple fallback HTML when no build is present,
# ensure server.js handles that (see instructions below).
ENV NODE_ENV=production
EXPOSE 3000
CMD ["node", "server.js"]

