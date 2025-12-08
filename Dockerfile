# -------------------------
# 1. BUILD STAGE
# -------------------------
FROM node:20-alpine AS builder

WORKDIR /app
RUN corepack enable

# Install dependencies
COPY package.json pnpm-lock.yaml ./
RUN pnpm install --frozen-lockfile

# Copy project files
COPY . .

# Build Next.js project
RUN pnpm build


# -------------------------
# 2. PRODUCTION STAGE
# -------------------------
FROM node:20-alpine AS runner

WORKDIR /app
ENV NODE_ENV=production

RUN corepack enable

# --- Crear usuario no root ---
# UID 1001 para evitar conflictos
RUN addgroup -S appgroup && adduser -S appuser -G appgroup -u 1001

# Instalar solo dependencias de producción
COPY package.json pnpm-lock.yaml ./
RUN pnpm install --prod --frozen-lockfile

# Copiar el build
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/public ./public
COPY --from=builder /app/package.json ./package.json

# --- Cambiar propiedad de la carpeta ---
RUN chown -R appuser:appgroup /app

USER appuser

EXPOSE 4321
CMD ["pnpm", "start"]
