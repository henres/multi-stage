FROM node:10 as node-build

WORKDIR /app/clientsrc

COPY ./findy/clientsrc/package.json ./findy/clientsrc/package-lock.json /app/clientsrc/

RUN npm ci

COPY ./findy/clientsrc /app/clientsrc

RUN npm run build

FROM golang as go-build

WORKDIR /go/src/app

COPY ./findy/. /go/src/app
COPY --from=node-build /app/client /go/src/app/client

RUN rm -r /go/src/app/clientsrc \
    && go get -d -v \
    && go install -v \
    && go build

ENV CLIENT_PATH=/go/src/app/client

CMD ["/go/bin/app"]
