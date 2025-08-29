FROM node:20-alpine AS build

WORKDIR /app

ARG PNPM_VERSION=10.15.0
RUN corepack enable && corepack prepare pnpm@${PNPM_VERSION} --activate

COPY package.json pnpm-lock.yaml ./

RUN pnpm install --frozen-lockfile

COPY . .
RUN pnpm run docs:build

FROM nginx:1.27-alpine AS deploy
ENV NGINX_ENTRYPOINT_QUIET_LOGS=1

COPY .nginx/nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /app/docs/.vuepress/dist /usr/share/nginx/html

EXPOSE 80
