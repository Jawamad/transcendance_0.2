# Étape unique : build du frontend
FROM node:20-alpine AS builder

WORKDIR /app/frontend

# Copier les fichiers de dépendances
COPY content/package*.json ./
RUN npm install

# Copier le code source
COPY content/ ./

# Builder le projet (génère /app/frontend/dist)
RUN npm run build
