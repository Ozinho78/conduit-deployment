FROM node:18-alpine AS builder

WORKDIR /app

COPY package*.json ./

RUN npm ci --legacy-peer-deps --ignore-scripts

COPY . .

RUN npm run build --prod

FROM node:14-alpine

WORKDIR /app

RUN npm install -g serve

COPY --from=builder /app/dist/angular-conduit ./dist

EXPOSE 80

CMD ["serve", "-s", "dist", "-l", "80"]
