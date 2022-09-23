FROM rust:latest
WORKDIR /usr/src/myapp
COPY . .

RUN cargo install --path .
# start the ethereum node
CMD ["myapp"]

