FROM node:20-slim AS deps
WORKDIR /usr/src/app
COPY ./package.json ./package-lock.json ./
RUN npm ci 
FROM gcr.io/distroless/nodejs20-debian12 AS production
WORKDIR /usr/src/app
COPY --from=deps /usr/src/app/node_modules ./node_modules
COPY ./src/ ./src/
COPY ./package.json .
COPY ./package-lock.json .
EXPOSE 3000
CMD ["src/app.js"]