use std::error::Error;
use std::path::Path;
use std::fs::File;
use std::io::Read;

pub fn rle_compress(data: &[u8]) -> Vec<u8> {
    let mut compressed = Vec::new();
    let mut i = 0;
    
    while i < data.len() {
        let current = data[i];
        let mut count = 1;
        
        while i + count < data.len() && data[i + count] == current && count < 255 {
            count += 1;
        }
        
        compressed.push(count as u8);
        compressed.push(current);
        i += count;
    }
    
    compressed
}

pub fn rle_decompress(data: &[u8]) -> Vec<u8> {
    let mut decompressed = Vec::new();
    let mut i = 0;
    
    while i < data.len() {
        if i + 1 >= data.len() {
            break;
        }
        
        let count = data[i] as usize;
        let value = data[i + 1];
        
        for _ in 0..count {
            decompressed.push(value);
        }
        
        i += 2;
    }
    
    decompressed
}

pub fn lz77_compress(data: &[u8]) -> Vec<u8> {
    let window_size = 4096;
    let lookahead_buffer = 15;
    let mut compressed = Vec::new();
    let mut pos = 0;

    while pos < data.len() {
        let mut best_match = (0, 0);
        let start = if pos > window_size { pos - window_size } else { 0 };
        
        for i in start..pos {
            let mut match_len = 0;
            while match_len < lookahead_buffer 
                && pos + match_len < data.len() 
                && i + match_len < pos 
                && data[i + match_len] == data[pos + match_len] {
                match_len += 1;
            }
            
            if match_len > best_match.1 {
                best_match = (pos - i, match_len);
            }
        }

        if best_match.1 > 2 {
            compressed.push((best_match.0 >> 8) as u8);
            compressed.push(best_match.0 as u8);
            compressed.push(best_match.1 as u8);
            pos += best_match.1;
        } else {
            compressed.push(0);
            compressed.push(0);
            compressed.push(0);
            compressed.push(data[pos]);
            pos += 1;
        }
    }

    compressed
}

pub fn lz77_decompress(data: &[u8]) -> Vec<u8> {
    let mut decompressed = Vec::new();
    let mut i = 0;

    while i < data.len() {
        if i + 3 >= data.len() {
            break;
        }

        let offset = ((data[i] as usize) << 8) | (data[i + 1] as usize);
        let length = data[i + 2] as usize;

        if offset == 0 && length == 0 {
            if i + 4 <= data.len() {
                decompressed.push(data[i + 3]);
            }
            i += 4;
        } else {
            let start = decompressed.len() - offset;
            for j in 0..length {
                if start + j < decompressed.len() {
                    decompressed.push(decompressed[start + j]);
                }
            }
            i += 3;
        }
    }

    decompressed
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, ValueEnum)]
pub enum Algorithm {
    /// Run-length encoding
    Rle,
    /// Lempel-Ziv compression
    Lz,
}

#[cfg(feature = "file-type-detection")]
mod file_type {
    use super::*;

    #[derive(Debug, PartialEq)]
    pub enum FileType {
        Text,
        Binary,
        Mixed,
    }

    pub fn detect_file_type<P: AsRef<Path>>(path: P) -> std::io::Result<FileType> {
        let mut file = File::open(path)?;
        let mut buffer = [0; 1024];
        let bytes_read = file.read(&mut buffer)?;
        
        let mut text_chars = 0;
        let mut total_chars = 0;
        
        for &byte in &buffer[..bytes_read] {
            total_chars += 1;
            if byte.is_ascii_graphic() || byte.is_ascii_whitespace() {
                text_chars += 1;
            }
        }
        
        let text_ratio = text_chars as f32 / total_chars as f32;
        
        Ok(if text_ratio > 0.95 {
            FileType::Text
        } else if text_ratio < 0.05 {
            FileType::Binary
        } else {
            FileType::Mixed
        })
    }

    pub fn suggest_algorithm(file_type: FileType) -> Algorithm {
        match file_type {
            FileType::Text => Algorithm::Rle,    // RLE works well for text with repeated patterns
            FileType::Binary => Algorithm::Lz,   // LZ works better for binary data
            FileType::Mixed => Algorithm::Lz,    // LZ is more versatile for mixed content
        }
    }
}

#[cfg(feature = "file-type-detection")]
pub use file_type::{detect_file_type, suggest_algorithm, FileType};

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_rle_compression() {
        let data = vec![1, 1, 1, 2, 2, 3, 3, 3, 3];
        let compressed = rle_compress(&data);
        let decompressed = rle_decompress(&compressed);
        assert_eq!(decompressed, data);
    }

    #[test]
    fn test_rle_single_bytes() {
        let data = vec![1, 2, 3, 4, 5];
        let compressed = rle_compress(&data);
        let decompressed = rle_decompress(&compressed);
        assert_eq!(decompressed, data);
    }

    #[test]
    fn test_rle_max_run_length() {
        let data = vec![1; 300];
        let compressed = rle_compress(&data);
        let decompressed = rle_decompress(&compressed);
        assert_eq!(decompressed, data);
    }

    #[test]
    fn test_lz77_compression() {
        let data = b"abracadabra";
        let compressed = lz77_compress(data);
        let decompressed = lz77_decompress(&compressed);
        assert_eq!(decompressed, data);
    }

    #[test]
    fn test_lz77_repeated_patterns() {
        let data = b"abcabcabcabc";
        let compressed = lz77_compress(data);
        let decompressed = lz77_decompress(&compressed);
        assert_eq!(decompressed, data);
    }

    #[test]
    fn test_lz77_non_repeating() {
        let data = b"abcdefghijklmnopqrstuvwxyz";
        let compressed = lz77_compress(data);
        let decompressed = lz77_decompress(&compressed);
        assert_eq!(decompressed, data);
    }

    #[test]
    fn test_lz77_empty_input() {
        let data = b"";
        let compressed = lz77_compress(data);
        let decompressed = lz77_decompress(&compressed);
        assert_eq!(decompressed, data);
    }
} 