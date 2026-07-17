# Multi-stage build: compile the SPA, then serve it with nginx.
# Build context is expected to be the filenet-web project root (see compose.yaml).

FROM node:22-slim AS build
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci
COPY . .
# VITE_* values are baked into the static build at build time.
ARG VITE_SUPABASE_URL
ARG VITE_SUPABASE_PUBLISHABLE_KEY
ARG VITE_POWERSYNC_URL
ENV VITE_SUPABASE_URL=$VITE_SUPABASE_URL
ENV VITE_SUPABASE_PUBLISHABLE_KEY=$VITE_SUPABASE_PUBLISHABLE_KEY
ENV VITE_POWERSYNC_URL=$VITE_POWERSYNC_URL
RUN npm run build

FROM nginx:1.27-alpine
COPY docker/self-hosted/nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /app/dist /usr/share/nginx/html
EXPOSE 80
