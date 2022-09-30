FROM alpine

# install golang
RUN apk add --no-cache python3 go git make bash npm yarn gcc

# get chainlink repo
RUN git clone https://github.com/smartcontractkit/chainlink

WORKDIR /chainlink
RUN git checkout v1.8.0
RUN make install
RUN chainlink help
