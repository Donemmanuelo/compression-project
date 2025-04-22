#!/bin/bash

set -e

# Create test files
echo "Creating test files..."
dd if=/dev/urandom of=random.bin bs=1M count=10
echo "Hello World! ".repeat(1000) > repeated.txt
cat random.bin repeated.txt > mixed.txt

# Function to run benchmark
run_benchmark() {
    local image=$1
    local input=$2
    local algorithm=$3
    local operation=$4
    
    echo "Benchmarking $image with $algorithm on $input"
    echo "----------------------------------------"
    
    # Get original file size
    original_size=$(stat -f %z "$input")
    echo "Original file size: $original_size bytes"
    
    # Run compression/decompression
    start_time=$(date +%s.%N)
    if [ "$operation" = "compress" ]; then
        docker run --rm -v "$(pwd):/data" "$image" "$operation" "/data/$input" "/data/${input}.cmp" "--$algorithm"
    else
        docker run --rm -v "$(pwd):/data" "$image" "$operation" "/data/${input}.cmp" "/data/${input}.dec" "--$algorithm"
    fi
    end_time=$(date +%s.%N)
    
    # Calculate time and size
    elapsed_time=$(echo "$end_time - $start_time" | bc)
    if [ "$operation" = "compress" ]; then
        compressed_size=$(stat -f %z "${input}.cmp")
        ratio=$(echo "scale=2; $compressed_size / $original_size" | bc)
        echo "Compression completed in $elapsed_time seconds"
        echo "Compression ratio: $ratio"
        echo "| Metric | Value |"
        echo "|--------|-------|"
        echo "| Original Size | $original_size bytes |"
        echo "| Compressed Size | $compressed_size bytes |"
        echo "| Compression Ratio | $ratio |"
        echo "| Compression Time | $elapsed_time seconds |"
    else
        decompressed_size=$(stat -f %z "${input}.dec")
        echo "Decompression completed in $elapsed_time seconds"
        echo "| Metric | Value |"
        echo "|--------|-------|"
        echo "| Decompression Time | $elapsed_time seconds |"
    fi
    
    echo ""
}

# Run benchmarks
echo "Starting benchmarks..."
echo "==========================="

# Test repeated.txt
echo "### Testing repeated.txt"
echo "------------------------"
run_benchmark "rust-compressor" "repeated.txt" "rle" "compress"
run_benchmark "rust-compressor" "repeated.txt" "rle" "decompress"
run_benchmark "js-compressor" "repeated.txt" "rle" "compress"
run_benchmark "js-compressor" "repeated.txt" "rle" "decompress"

# Test random.bin
echo "### Testing random.bin"
echo "------------------------"
run_benchmark "rust-compressor" "random.bin" "lz" "compress"
run_benchmark "rust-compressor" "random.bin" "lz" "decompress"
run_benchmark "js-compressor" "random.bin" "lz" "compress"
run_benchmark "js-compressor" "random.bin" "lz" "decompress"

# Test mixed.txt
echo "### Testing mixed.txt"
echo "------------------------"
run_benchmark "rust-compressor" "mixed.txt" "lz" "compress"
run_benchmark "rust-compressor" "mixed.txt" "lz" "decompress"
run_benchmark "js-compressor" "mixed.txt" "lz" "compress"
run_benchmark "js-compressor" "mixed.txt" "lz" "decompress"

# Cleanup
echo "Cleaning up..."
rm -f random.bin repeated.txt mixed.txt *.cmp *.dec
echo "Benchmarks completed!" 