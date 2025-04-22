# Benchmarking Documentation

This document describes the benchmarking process and tools available in this project.

## Benchmark Suite

The project includes a comprehensive benchmark suite that tests:

1. Different file types:
   - Text files with repeated patterns
   - Random binary data
   - Mixed content files

2. Different algorithms:
   - Run-Length Encoding (RLE)
   - Lempel-Ziv (LZ77)

3. Both implementations:
   - Rust
   - JavaScript (WASM)

## Running Benchmarks

### Using the Benchmark Script

```bash
cd benchmarks
./benchmark.sh
```

This will:
1. Create test files
2. Run compression/decompression tests
3. Measure performance metrics
4. Generate a markdown report
5. Clean up test files

### Test Files

The benchmark creates three types of test files:

1. **repeated.txt**:
   - Contains repeated text patterns
   - Good for testing RLE performance
   - Size: ~1MB

2. **random.bin**:
   - Contains random binary data
   - Good for testing LZ77 performance
   - Size: ~10MB

3. **mixed.txt**:
   - Combination of binary and text data
   - Tests algorithm selection
   - Size: ~11MB

## Performance Metrics

The benchmark measures:

1. **Compression Time**:
   - Time taken to compress the input
   - Measured in seconds
   - Includes file I/O

2. **Decompression Time**:
   - Time taken to decompress the output
   - Measured in seconds
   - Includes file I/O

3. **Compression Ratio**:
   - Ratio of compressed size to original size
   - Lower is better
   - Formula: compressed_size / original_size

4. **Memory Usage**:
   - Peak memory usage during operations
   - Measured in megabytes
   - Includes both implementations

## Benchmark Results Format

Results are presented in markdown tables:

```markdown
| Metric | Value |
|--------|-------|
| Original Size | X bytes |
| Compressed Size | Y bytes |
| Compression Ratio | Z |
| Compression Time | T seconds |
| Decompression Time | U seconds |
```

## Custom Benchmarks

You can create custom benchmarks by modifying the `benchmark.sh` script:

1. **Adding Test Files**:
   ```bash
   # Add to the test file creation section
   dd if=/dev/urandom of=custom.bin bs=1M count=5
   ```

2. **Adding Test Cases**:
   ```bash
   # Add to the benchmark section
   run_benchmark "rust-compressor" "custom.bin" "lz" "compress"
   run_benchmark "rust-compressor" "custom.bin" "lz" "decompress"
   ```

## Interpreting Results

1. **Compression Ratio**:
   - RLE: Best for repeated patterns (ratio < 1)
   - LZ77: Best for general data (ratio ~ 2-4)

2. **Performance**:
   - Rust: Generally faster
   - JavaScript: Slower but more portable

3. **Memory Usage**:
   - Both implementations should use constant memory
   - Watch for spikes in memory usage

## Best Practices

1. **Environment**:
   - Run benchmarks on a dedicated machine
   - Close other applications
   - Use consistent hardware

2. **Reproducibility**:
   - Document hardware specifications
   - Note software versions
   - Run multiple times

3. **Analysis**:
   - Compare against baseline
   - Look for trends
   - Consider use cases

## Example Results

### Text File (repeated.txt)

| Implementation | Algorithm | Compression Ratio | Compression Time | Decompression Time |
|----------------|-----------|-------------------|------------------|-------------------|
| Rust           | RLE       | 0.5              | 0.1s             | 0.05s             |
| JavaScript     | RLE       | 0.5              | 0.5s             | 0.3s              |

### Binary File (random.bin)

| Implementation | Algorithm | Compression Ratio | Compression Time | Decompression Time |
|----------------|-----------|-------------------|------------------|-------------------|
| Rust           | LZ77      | 2.1              | 0.3s             | 0.2s              |
| JavaScript     | LZ77      | 2.1              | 1.2s             | 0.8s              | 