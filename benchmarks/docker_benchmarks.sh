#!/bin/bash

# Create test files
echo "Creating test files..."
mkdir -p test_files

# Create different types of test files
echo "1. Creating text file with repeated patterns..."
for i in {1..100}; do
    echo "This is a repeated pattern $i" >> test_files/repeated.txt
done

echo "2. Creating binary file..."
head -c 1M /dev/urandom > test_files/random.bin

echo "3. Creating mixed content file..."
cat /etc/passwd /etc/hosts > test_files/mixed.txt
for i in {1..10}; do
    cat test_files/mixed.txt test_files/mixed.txt > test_files/mixed.txt.tmp
    mv test_files/mixed.txt.tmp test_files/mixed.txt
done

# Function to run Docker benchmark
run_docker_benchmark() {
    local image=$1
    local input=$2
    local output=$3
    local algorithm=$4
    
    echo -e "\nBenchmarking $image with $algorithm on $(basename $input)"
    echo "----------------------------------------"
    
    # Get original file size
    original_size=$(stat -c %s "$input")
    echo "Original file size: $original_size bytes"
    
    # Run compression and measure time
    echo "Running compression..."
    start_time=$(date +%s.%N)
    sudo docker run --rm -v "$(pwd)/test_files:/data" $image compress "/data/$(basename $input)" "/data/$(basename $output)" --algorithm $algorithm
    compress_time=$(echo "$(date +%s.%N) - $start_time" | bc)
    echo "Compression completed in $compress_time seconds"
    
    # Get compressed file size
    compressed_size=$(stat -c %s "$output")
    compression_ratio=$(echo "scale=2; $compressed_size / $original_size" | bc)
    echo "Compression ratio: $compression_ratio"
    
    # Run decompression and measure time
    echo "Running decompression..."
    start_time=$(date +%s.%N)
    sudo docker run --rm -v "$(pwd)/test_files:/data" $image decompress "/data/$(basename $output)" "/data/$(basename $output).decompressed" --algorithm $algorithm
    decompress_time=$(echo "$(date +%s.%N) - $start_time" | bc)
    echo "Decompression completed in $decompress_time seconds"
    
    # Verify decompression
    if cmp -s "$input" "$output.decompressed"; then
        verification="✅ Success"
    else
        verification="❌ Failed"
    fi
    echo "Verification: $verification"
    
    # Print results
    echo "| Metric | Value |"
    echo "|--------|-------|"
    echo "| Original Size | $original_size bytes |"
    echo "| Compressed Size | $compressed_size bytes |"
    echo "| Compression Ratio | $compression_ratio |"
    echo "| Compression Time | $compress_time seconds |"
    echo "| Decompression Time | $decompress_time seconds |"
    echo "| Verification | $verification |"
    echo ""
}

# Main benchmark execution
echo "Starting Docker benchmarks..."
echo "============================"

# Test files to benchmark
test_files=(
    "test_files/repeated.txt"
    "test_files/random.bin"
    "test_files/mixed.txt"
)

# Run benchmarks for each test file
for file in "${test_files[@]}"; do
    echo -e "\n### Testing $(basename $file)"
    echo "------------------------"
    
    # Test Rust compressor
    echo "#### Rust Compressor"
    run_docker_benchmark "rust-compressor" "$file" "${file}.rust.rle" "rle"
    run_docker_benchmark "rust-compressor" "$file" "${file}.rust.lz77" "lz77"
    
    # Test JavaScript compressor
    echo "#### JavaScript Compressor"
    run_docker_benchmark "js-compressor" "$file" "${file}.js.rle" "rle"
    run_docker_benchmark "js-compressor" "$file" "${file}.js.lz77" "lz77"
done

# Cleanup
echo "Cleaning up..."
rm -rf test_files
echo "Benchmarks completed!" 