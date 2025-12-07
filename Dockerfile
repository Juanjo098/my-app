# -------------------------
# 1. BUILD STAGE
# -------------------------
FROM node:20-alpine AS builder

# Set working directory
WORKDIR /app

# Enable corepack (for pnpm)
RUN corepack enable

# Copy lock file and package.json first (for caching)
COPY package.json pnpm-lock.yaml ./

# Install dependencies
RUN pnpm install --frozen-lockfile

# Copy all project files
COPY . .

# Build Next.js project
RUN pnpm build


# -------------------------
# 2. PRODUCTION STAGE
# -------------------------
FROM node:20-alpine AS runner

WORKDIR /app

ENV NODE_ENV=production

# Enable corepack again
RUN corepack enable

# Install only production dependencies
COPY package.json pnpm-lock.yaml ./
RUN pnpm install --prod --frozen-lockfile

# Copy build output from builder
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/public ./public
COPY --from=builder /app/package.json ./package.json

EXPOSE 4321

CMD ["pnpm", "start"]
