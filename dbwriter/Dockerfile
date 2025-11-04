# Étape 1 : Build stage (TypeScript + build native deps)
FROM node:20-alpine AS builder

# Installer outils nécessaires pour compiler sqlite3 (node-gyp)
RUN apk add --no-cache python3 make g++

WORKDIR /app

# Copier les fichiers de dépendances
COPY package*.json ./
COPY tsconfig.json ./

# Installer toutes les dépendances (y compris dev)
RUN npm ci

# Copier le code source
COPY src ./src

# Compiler TypeScript -> JavaScript (dist/)
RUN npm run build

# Étape 2 : Runtime (production)
FROM node:20-alpine AS runner
WORKDIR /app

# Copier uniquement les dépendances nécessaires pour le runtime
COPY package*.json ./
RUN npm ci --omit=dev

# Copier le code compilé depuis le builder
COPY --from=builder /app/dist ./dist

# Créer le dossier de la base SQLite (monté en volume)
RUN mkdir -p /app/data

# Variables d’environnement par défaut
ENV NODE_ENV=production
ENV PORT=4000
ENV DATABASE_URL=file:/app/data/database.sqlite

EXPOSE 4000

CMD ["node", "dist/index.js"]
