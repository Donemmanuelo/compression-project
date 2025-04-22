# Compression Algorithms

This document describes the compression algorithms implemented in this project.

## Run-Length Encoding (RLE)

Run-Length Encoding is a simple compression algorithm that works by replacing consecutive repeated data with a count and a single instance of the data.

### Algorithm Details

1. **Compression**:
   - Scan the input data sequentially
   - Count consecutive identical bytes
   - When a different byte is encountered or the maximum count (255) is reached:
     - Output the count as a single byte
     - Output the repeated byte
   - Continue until the entire input is processed

2. **Decompression**:
   - Read the input data in pairs (count, byte)
   - For each pair, output the byte 'count' times
   - Continue until the entire input is processed

### Use Cases

- Best for data with long runs of identical bytes
- Particularly effective for:
  - Simple graphics (e.g., black and white images)
  - Text files with repeated patterns
  - Sparse data with many zeros

### Performance Characteristics

- Compression ratio: 1:1 to 1:255 (best case)
- Time complexity: O(n)
- Space complexity: O(n)

## Lempel-Ziv (LZ77)

LZ77 is a dictionary-based compression algorithm that works by replacing repeated sequences with references to previous occurrences.

### Algorithm Details

1. **Compression**:
   - Maintain a sliding window of previously seen data
   - For each position in the input:
     - Find the longest match in the window
     - If a match is found:
       - Output a triple (offset, length, next_char)
     - If no match is found:
       - Output a literal byte
   - Slide the window forward

2. **Decompression**:
   - Maintain a sliding window of decompressed data
   - For each triple in the input:
     - Copy 'length' bytes from 'offset' positions back
     - Append the next character
   - For literal bytes, simply output them

### Use Cases

- Best for data with repeated patterns
- Particularly effective for:
  - Text files
  - Binary files with repeated structures
  - Mixed content files

### Performance Characteristics

- Compression ratio: Variable, typically 2:1 to 4:1
- Time complexity: O(n²) for compression, O(n) for decompression
- Space complexity: O(window_size)

## Automatic Algorithm Selection

The tool can automatically select the best algorithm based on file type analysis.

### File Type Detection

1. **Analysis**:
   - Sample the first 1024 bytes of the file
   - Count ASCII graphic and whitespace characters
   - Calculate text ratio (text_chars / total_chars)

2. **Classification**:
   - Text: text_ratio > 0.95
   - Binary: text_ratio < 0.05
   - Mixed: 0.05 ≤ text_ratio ≤ 0.95

### Algorithm Selection

- Text files: RLE (good for repeated patterns)
- Binary files: LZ77 (better for structured data)
- Mixed files: LZ77 (more versatile)

## Performance Comparison

| Algorithm | Best For | Compression Ratio | Speed | Memory Usage |
|-----------|----------|-------------------|-------|--------------|
| RLE       | Repeated patterns | 1:1 to 1:255 | Fast | Low |
| LZ77      | General purpose | 2:1 to 4:1 | Medium | Medium |

## Implementation Notes

### Rust Implementation

- Uses zero-copy operations where possible
- Implements streaming for large files
- Thread-safe and memory-efficient

### JavaScript Implementation

- Uses WASM for performance-critical operations
- Implements streaming for browser compatibility
- Memory-efficient with chunked processing 