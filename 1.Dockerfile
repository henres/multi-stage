FROM ubuntu

WORKDIR /go/src/app

RUN apt-get update \
	&& apt-get install -y golang-go curl git \
	&& curl -sL https://deb.nodesource.com/setup_12.x | bash - \
	&& apt-get update \
	&& apt-get install -y nodejs \
	&& rm -rf /var/lib/apt/lists/*

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
