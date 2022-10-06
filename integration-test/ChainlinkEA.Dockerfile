FROM rust

WORKDIR /app

# copy in the contracts
COPY . .

RUN cargo build --release
CMD cargo run --release
