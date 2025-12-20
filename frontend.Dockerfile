# ============================================================================
# Frontend Dockerfile - Angular + Nginx
# ============================================================================
# Multi-Stage Build für optimale Image-Größe
# ============================================================================

# ----------------------------------------------------------------------------
# Stage 1: Builder - Angular App kompilieren
# ----------------------------------------------------------------------------
FROM node:18-alpine AS builder

WORKDIR /build

# Package Files
COPY package*.json ./
# COPY conduit-frontend/package*.json ./

# Dependencies installieren (ohne Git/Husky hooks)
RUN npm ci --legacy-peer-deps --ignore-scripts

# Source Code
COPY . .
# COPY conduit-frontend/ .

# Production Build
RUN npm run build --prod

# ----------------------------------------------------------------------------
# Stage 2: Runtime - Nginx Server
# ----------------------------------------------------------------------------
FROM nginx:alpine

# Angular Build Output kopieren
COPY --from=builder /build/dist/angular-conduit/ /usr/share/nginx/html/

# Nginx Config
COPY nginx-frontend.conf /etc/nginx/conf.d/default.conf

# Nginx Port
ENV NGINX_PORT=4200

EXPOSE ${NGINX_PORT}

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]
