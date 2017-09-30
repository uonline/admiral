FROM node:4-alpine

WORKDIR /app

ADD . /app

RUN rm -v node_modules/hubot-telegram/src/telegram.coffee
RUN cp -v telegram.coffee node_modules/hubot-telegram/src/telegram.coffee

EXPOSE 3222
CMD ["script/run"]
