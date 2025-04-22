FROM node:20-slim as builder

WORKDIR /usr/src/app
COPY package*.json ./
RUN npm ci --only=production

# Copy source files
COPY . .

# Create a minimal runtime image
FROM node:20-slim

WORKDIR /usr/src/app

# Copy only necessary files from builder
COPY --from=builder /usr/src/app/node_modules ./node_modules
COPY --from=builder /usr/src/app/index.js ./

# Run as non-root user
RUN useradd -m -u 1000 app && \
    chown -R app:app /usr/src/app
USER app

ENTRYPOINT ["node", "index.js"] 