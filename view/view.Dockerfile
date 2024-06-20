FROM node:20.12.2

WORKDIR /view
COPY ./ /view
COPY ./script/dev_up.sh /view/script/dev_up.sh

RUN yarn set version stable
RUN yarn install
RUN chmod +x /view/script/dev_up.sh