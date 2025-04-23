# Build stage
FROM rust:1.70-slim as builder

WORKDIR /usr/src/compressor
COPY . .

# Build with all features enabled
RUN cargo build --release 

# Runtime stage
FROM debian:bookworm-slim

# Install runtime dependencies
RUN apt-get update && apt-get install -y \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Copy the binary from the builder stage
COPY --from=builder /usr/src/compressor/target/release/compression-cli /usr/local/bin/compressor

# Set the entrypoint
ENTRYPOINT ["compressor"]

# Default command (can be overridden)
CMD ["--help"] 
