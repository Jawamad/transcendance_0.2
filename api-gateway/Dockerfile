# Étape 1 : Build stage (compilation TypeScript)
FROM node:20-alpine AS builder

# Installer outils nécessaires pour compiler les dépendances natives
RUN apk add --no-cache python3 make g++

WORKDIR /app

# Copier fichiers de dépendances
COPY package*.json ./
COPY tsconfig.json ./

# Installer toutes les dépendances (y compris dev)
RUN npm ci

# Copier le code source
COPY src ./src

# Compiler TypeScript → JavaScript (dist/)
RUN npx tsc

# Étape 2 : Runtime (production)
FROM node:20-alpine AS runner

WORKDIR /app

# Copier uniquement les fichiers nécessaires
COPY package*.json ./

# Installer uniquement les dépendances runtime
RUN npm ci --omit=dev

# Copier le code compilé depuis le builder
COPY --from=builder /app/dist ./dist

ENV PORT=8080

# Expose le port de l'API Gateway
EXPOSE 8080

# Variables d’environnement
ENV NODE_ENV=production

# Lancer l’application
CMD ["node", "dist/main.js"]
