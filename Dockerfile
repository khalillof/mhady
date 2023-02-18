
################################### stage one
FROM node:18.9-alpine3.15 as builder

WORKDIR /app

COPY ./package.json .
COPY ./package-lock.json .
COPY ./build ./build
COPY ./server ./server
RUN npm ci  --only=production --omit=dev

################################### stage two
FROM node:18.9-alpine3.15

EXPOSE 3000
ENV NODE_ENV=production
ARG appDir=/home/node/app

USER node
RUN mkdir -p ${appDir}
WORKDIR ${appDir}

COPY --chown=node:node --from=builder  /app/package.json .
COPY --chown=node:node --from=builder  /app/package-lock.json .
COPY --chown=node:node --from=builder  /app/build ./build
COPY --chown=node:node --from=builder  /app/server ./server
COPY --from=builder   /app/node_modules  ./node_modules

CMD ["node", "./server/app.js"]
#CMD ["node", "start"]
