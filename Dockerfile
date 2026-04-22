# ── Stage 1: Builder ──────────────────────────────────────────
# TODO(step-4a): ตั้งชื่อ stage แรกว่า "builder" บน node:20.11-slim
FROM node:20.11-slim AS builder

# TODO(step-4b): กำหนด working directory
WORKDIR /app

# TODO(step-4c): Copy เฉพาะ package files ก่อน (เพื่อ cache layer)
COPY app/package*.json ./

# TODO(step-4d): ติดตั้ง dependencies แบบ production only
RUN npm ci --omit=dev

# ── Stage 2: Runtime ──────────────────────────────────────────
# TODO(step-4e): stage สองใช้ base image เดิม แต่ไม่มีชื่อ stage
FROM node:20.11-slim

WORKDIR /app

# Copy node_modules จาก builder stage
COPY --from=builder /app/node_modules ./node_modules

# TODO(step-4f): Copy โค้ด app
COPY app/ .

# Expose port
EXPOSE 3000

# TODO(step-4g): HEALTHCHECK ด้วย Node.js one-liner
# (ใช้ Node เพราะ slim image ไม่มี curl/wget)
HEALTHCHECK --interval=30s --timeout=5s --start-period=15s --retries=3 \
  CMD node -e "require('http').get('http://localhost:3000/health', r => { process.exit(r.statusCode === 200 ? 0 : 1) }).on('error', () => process.exit(1))"

# Start app
CMD ["node", "src/index.js"]