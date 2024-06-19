FROM node:20.12.2

WORKDIR /view
COPY ./ /view

RUN yarn set version stable
RUN yarn install