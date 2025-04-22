#!/bin/bash

# Remove duplicate directories
rm -rf rust/ js/ tests/ compression-project/

# Remove duplicate files in compress-decompress
rm -f compress-decompress/benchmark.sh

# Remove old implementations
rm -rf compress-decompress/js-compressor/
rm -rf compress-decompress/rust-compressor/

# Make sure all files have content
find . -type f -empty -delete

# Make sure all directories have content
find . -type d -empty -delete

echo "Cleanup complete!" 