# Compression/Decompression Tool

A high-performance compression and decompression tool implemented in both Rust and JavaScript, with support for multiple algorithms and features.

## Features

- **Multiple Compression Algorithms**:
  - Run-Length Encoding (RLE)
  - Lempel-Ziv (LZ77)
  - Automatic algorithm selection based on file type

- **Cross-Platform Support**:
  - Rust implementation for maximum performance
  - JavaScript implementation with WASM support
  - Docker containers for easy deployment

- **Flexible I/O**:
  - File-based compression/decompression
  - Optional stdin/stdout support
  - Multiple file processing support

## Installation

### Docker (Recommended)

```bash
# Pull the Rust version
docker pull ghcr.io/your-org/rust-compressor:latest

# Pull the JavaScript version
docker pull ghcr.io/your-org/js-compressor:latest
```

### From Source

#### Rust Version

```bash
git clone https://github.com/your-org/compressor.git
cd compressor/core
cargo build --release
```

#### JavaScript Version

```bash
git clone https://github.com/your-org/compressor.git
cd compressor/js-compressor
npm install
npm run build
```

## Usage

### Basic Usage

```bash
# Compress a file
compressor compress input.txt output.txt.cmp --algorithm rle

# Decompress a file
compressor decompress output.txt.cmp output.txt --algorithm rle
```

### Advanced Features

#### Stdin/Stdout Support

```bash
# Compress from stdin to stdout
cat input.txt | compressor compress - - --use-streams --algorithm rle > output.txt.cmp

# Decompress from stdin to stdout
cat output.txt.cmp | compressor decompress - - --use-streams --algorithm rle > output.txt
```

#### Multiple File Processing

```bash
# Compress multiple files
compressor compress file1.txt,file2.txt --multiple-files --output-dir ./compressed --algorithm rle

# Decompress multiple files
compressor decompress file1.txt.cmp,file2.txt.cmp --multiple-files --output-dir ./decompressed --algorithm rle
```

#### Automatic Algorithm Selection

```bash
# Let the tool choose the best algorithm
compressor compress input.txt output.txt.cmp --auto-algorithm
```

### Docker Usage

```bash
# Using the Rust version
docker run --rm -v $(pwd):/data rust-compressor compress /data/input.txt /data/output.txt.cmp --algorithm rle

# Using the JavaScript version
docker run --rm -v $(pwd):/data js-compressor compress /data/input.txt /data/output.txt.cmp --algorithm rle
```

## Performance

The tool includes a benchmarking suite to compare performance between implementations. Run the benchmarks:

```bash
cd benchmarks
./benchmark.sh
```

This will test:
- Different file types (text, binary, mixed)
- Different algorithms (RLE, LZ77)
- Both implementations (Rust and JavaScript)

## Development

### Project Structure

```
.
├── core/                 # Rust implementation
│   ├── src/             # Source code
│   ├── Cargo.toml       # Rust dependencies
│   └── Dockerfile       # Rust Docker configuration
├── js-compressor/       # JavaScript implementation
│   ├── src/             # Source code
│   ├── package.json     # Node.js dependencies
│   └── Dockerfile       # JavaScript Docker configuration
├── benchmarks/          # Benchmarking tools
│   └── benchmark.sh     # Benchmark script
└── .github/             # GitHub Actions workflows
    └── workflows/
        └── docker.yml   # Docker build workflow
```

### Building

#### Rust

```bash
cd core
cargo build
```

#### JavaScript

```bash
cd js-compressor
npm install
npm run build
```

### Testing

```bash
# Rust tests
cd core
cargo test

# JavaScript tests
cd js-compressor
npm test
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Rust community for the excellent ecosystem
- Node.js community for the JavaScript implementation
- WASM for enabling high-performance JavaScript 