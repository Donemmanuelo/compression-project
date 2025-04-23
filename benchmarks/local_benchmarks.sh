#!/bin/bash

# Check for required tools
if ! command -v node &> /dev/null; then
    echo "Node.js is not installed. JavaScript benchmarks will be skipped."
    SKIP_JS=true
fi

# Create test files
echo "Creating test files..."
mkdir -p test_files

# Create different types of test files
echo "1. Creating text file with repeated patterns..."
for i in {1..10}; do
    echo "This is a repeated pattern $i" >> test_files/repeated.txt
done

echo "2. Creating binary file..."
head -c 10K /dev/urandom > test_files/random.bin

echo "3. Creating mixed content file..."
echo "This is a mixed content file with some repeated patterns. AAAAABBBBB and some random text. The quick brown fox jumps over the lazy dog. CCCCCDDDDD" > test_files/mixed.txt
for i in {1..3}; do
    cat test_files/mixed.txt test_files/mixed.txt > test_files/mixed.txt.tmp
    mv test_files/mixed.txt.tmp test_files/mixed.txt
done

# Function to run local benchmark
run_local_benchmark() {
    local implementation=$1
    local input=$2
    local output=$3
    local algorithm=$4
    
    echo -e "\nBenchmarking $implementation with $algorithm on $(basename $input)"
    echo "----------------------------------------"
    
    # Get original file size
    original_size=$(stat -c %s "$input")
    echo "Original file size: $original_size bytes"
    
    # Run compression and measure time
    echo "Running compression..."
    start_time=$(date +%s.%N)
    if [ "$implementation" == "rust" ]; then
        ./core/target/release/compression-cli compress --input "$input" --output "$output" --algorithm "$algorithm"
    else
        if [ "$SKIP_JS" = true ]; then
            echo "Skipping JavaScript benchmark (Node.js not installed)"
            return
        fi
        node ./js-compressor/index.js compress "$input" "$output" --algorithm $algorithm
    fi
    compress_time=$(echo "$(date +%s.%N) - $start_time" | bc)
    echo "Compression completed in $compress_time seconds"
    
    # Get compressed file size
    compressed_size=$(stat -c %s "$output")
    compression_ratio=$(echo "scale=2; $compressed_size / $original_size" | bc)
    echo "Compression ratio: $compression_ratio"
    
    # Run decompression and measure time
    echo "Running decompression..."
    start_time=$(date +%s.%N)
    if [ "$implementation" == "rust" ]; then
        ./core/target/release/compression-cli decompress --input "$output" --output "$output.decompressed" --algorithm "$algorithm"
    else
        if [ "$SKIP_JS" = true ]; then
            echo "Skipping JavaScript benchmark (Node.js not installed)"
            return
        fi
        node ./js-compressor/index.js decompress "$output" "$output.decompressed" --algorithm $algorithm
    fi
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
echo "Starting local benchmarks..."
echo "==========================="

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
    run_local_benchmark "rust" "$file" "${file}.rust.rle" "rle"
    run_local_benchmark "rust" "$file" "${file}.rust.lz" "lz"
    
    # Test JavaScript compressor if Node.js is available
    if [ "$SKIP_JS" != true ]; then
        echo "#### JavaScript Compressor"
        run_local_benchmark "js" "$file" "${file}.js.rle" "rle"
        run_local_benchmark "js" "$file" "${file}.js.lz77" "lz77"
    fi
done

# Cleanup
echo "Cleaning up..."
rm -rf test_files
echo "Benchmarks completed!" 