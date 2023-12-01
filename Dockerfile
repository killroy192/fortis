FROM ghcr.io/foundry-rs/foundry:latest
WORKDIR /usr/src/app
COPY . .
RUN apk update
RUN apk add --no-cache make
RUN apk add --no-cache nodejs npm
RUN make
ENTRYPOINT ["/bin/sh","-c","sleep infinity"]
