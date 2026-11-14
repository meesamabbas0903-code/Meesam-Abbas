FROM node:20-alpine
WORKDIR /app
# Baileys needs these for native crypto fallbacks
RUN apk add --no-cache python3 make g++ cairo-dev jpeg-dev pango-dev giflib-dev
COPY package*.json ./
RUN npm install --omit=dev
COPY . .
ENV NODE_ENV=production
EXPOSE 3000
CMD ["node", "src/server.js"]
