FROM alpine:edge

WORKDIR /go/src/app

RUN apk update \
	&& apk add --no-cache \
		go \
		curl \
		git \
		npm \
		nodejs \
		gcc \
		musl-dev

COPY ./findy .

ENV GOPATH=/go
ENV CLIENT_PATH=/go/src/app/client

RUN cd clientsrc \
	&& npm ci \
	&& npm run build \
	&& cd ../ \
	&& rm -r /go/src/app/clientsrc \
	&& go get -d -v \
	&& go install -v \
	&& go build

CMD ["/go/bin/app"]
