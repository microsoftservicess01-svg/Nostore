### Dockerfile (Render-safe) - ensures client/dist/index.html always exists
FROM node:18 AS builder
WORKDIR /repo

# copy all files
COPY . .

# Ensure dist exists
RUN mkdir -p /repo/client/dist

# If client exists and has package.json, build it; otherwise create a simple index.html fallback
RUN if [ -d "client" ] && [ -f "client/package.json" ]; then \
      echo "Building frontend..."; \
      cd client && npm install --silent && npm run build; \
    else \
      echo "No client build found — creating fallback index.html"; \
      cat > /repo/client/dist/index.html <<'HTML'\n<!doctype html>\n<html><head><meta charset=\"utf-8\"><meta name=\"viewport\" content=\"width=device-width,initial-scale=1\"><title>BraFit</title></head>\n<body style=\"font-family:Arial,Helvetica,sans-serif;display:flex;align-items:center;justify-content:center;height:100vh;margin:0;background:#f7f7f7;\">\n  <div style=\"text-align:center;max-width:680px;padding:24px;background:#fff;border-radius:10px;box-shadow:0 8px 24px rgba(0,0,0,0.08);\">\n    <h1 style=\"margin:0 0 8px;color:#111\">BraFit</h1>\n    <p style=\"color:#444\">No frontend build found. To enable the UI, add a <code>client/</code> folder with a Vite React app, or run the frontend build.</p>\n    <p style=\"color:#666;font-size:14px;margin-top:12px\">You can still use the server-only features. Re-deploy after adding a client.</p>\n  </div>\n</body></html>\nHTML\n; \
    fi

### runtime stage
FROM node:18-alpine AS runtime
WORKDIR /app

# copy server packages (if present)
COPY package.json package-lock.json* ./

# install server deps if package.json exists
RUN if [ -f package.json ]; then npm install --production --silent || npm i --production --silent; fi

# copy server code (if exists)
COPY server.js ./ || true

# copy built or fallback frontend (will always exist because of builder step)
COPY --from=builder /repo/client/dist ./client/dist

EXPOSE 3000
ENV NODE_ENV=production
CMD ["node", "server.js"]

