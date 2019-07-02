FROM node:10 as node-build

WORKDIR /app/clientsrc

COPY ./findy/clientsrc/package.json ./findy/clientsrc/package-lock.json /app/clientsrc/

RUN npm ci

COPY ./findy/clientsrc /app/clientsrc

RUN npm run build

FROM golang:alpine as go-build

RUN apk add --no-cache git

WORKDIR /go/src/app
COPY ./findy/ /go/src/app

ENV CGO_ENABLED=0
ENV GO111MODULE=on

RUN rm -r /go/src/app/clientsrc \
	&& go get -d -v \
	&& go install -v \
	&& go build

FROM scratch as scratch

ENV CLIENT_PATH=/go/src/app/client

EXPOSE 9292

COPY --from=node-build /app/client /go/src/app/client
COPY --from=go-build /go/bin/findy /

CMD ["/findy"]

FROM gcr.io/distroless/base as distroless

ENV CLIENT_PATH=/go/src/app/client

EXPOSE 9292

COPY --from=node-build /app/client /go/src/app/
COPY --from=go-build /go/bin/findy /

CMD ["/findy"]
