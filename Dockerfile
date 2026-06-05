# --- ETAPA 1: Construcción (Build) ---
FROM node:22-slim AS builder

# Instalamos dependencias de compilación necesarias para módulos nativos
RUN apt-get update && apt-get install -y --no-install-recommends python3 make g++ && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copiamos primero solo los archivos de dependencias para aprovechar el caché
COPY package.json pnpm-lock.yaml ./

# Instalamos todo (incluyendo devDependencies para poder compilar)
RUN npm install -g pnpm && \
    CI=true pnpm install --frozen-lockfile --ignore-scripts

# Copiamos el resto del código
COPY . .

# Compilamos la aplicación
RUN CI=true pnpm build

# --- ETAPA 2: Ejecución (Production) ---
FROM node:22-slim

WORKDIR /app

# Copiamos solo lo indispensable de la etapa de construcción
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package.json ./package.json

# Limpiamos las devDependencies para dejar la imagen ligera y segura
RUN npm install -g pnpm && pnpm prune --prod

ENV NODE_ENV=production

# Exponemos el puerto si tu aplicación lo requiere (3000)
EXPOSE 3000

CMD ["node", "dist/main.js"]
