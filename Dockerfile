FROM node:22-alpine

WORKDIR /app

COPY package.json ./
RUN npm install

COPY src/ ./src/
COPY tsconfig.json ./

EXPOSE 3100

CMD ["npx", "tsx", "src/hosted.ts"]
