FROM node:18-alpine AS builder

WORKDIR /build

COPY package*.json ./

RUN npm ci --legacy-peer-deps --ignore-scripts

COPY . .

RUN npm run build --prod


FROM nginx:alpine

COPY --from=builder /build/dist/angular-conduit/ /usr/share/nginx/html/

COPY nginx-frontend.conf /etc/nginx/conf.d/default.conf

ENV NGINX_PORT=4200

EXPOSE ${NGINX_PORT}

CMD ["nginx", "-g", "daemon off;"]
