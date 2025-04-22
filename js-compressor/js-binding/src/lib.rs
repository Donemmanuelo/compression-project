use wasm_bindgen::prelude::*;
use compressor::{compress, decompress, Algorithm, detect_file_type, suggest_algorithm};

#[wasm_bindgen]
pub enum JsAlgorithm {
    Rle,
    Lz,
    Auto,
}

impl From<JsAlgorithm> for Algorithm {
    fn from(algo: JsAlgorithm) -> Self {
        match algo {
            JsAlgorithm::Rle => Algorithm::Rle,
            JsAlgorithm::Lz => Algorithm::Lz,
            JsAlgorithm::Auto => Algorithm::Auto,
        }
    }
}

#[wasm_bindgen]
pub fn compress_data(data: &[u8], algorithm: JsAlgorithm) -> Vec<u8> {
    compress(data, algorithm.into())
}

#[wasm_bindgen]
pub fn decompress_data(data: &[u8], algorithm: JsAlgorithm) -> Vec<u8> {
    decompress(data, algorithm.into())
}

#[wasm_bindgen]
pub fn detect_file_type_js(data: &[u8]) -> String {
    let mut text_chars = 0;
    let mut total_chars = 0;
    
    for &byte in data {
        total_chars += 1;
        if byte.is_ascii_graphic() || byte.is_ascii_whitespace() {
            text_chars += 1;
        }
    }
    
    let text_ratio = text_chars as f32 / total_chars as f32;
    
    if text_ratio > 0.95 {
        "text".to_string()
    } else if text_ratio < 0.05 {
        "binary".to_string()
    } else {
        "mixed".to_string()
    }
}

#[wasm_bindgen]
pub fn suggest_algorithm_js(file_type: &str) -> JsAlgorithm {
    match file_type {
        "text" => JsAlgorithm::Rle,
        "binary" => JsAlgorithm::Lz,
        "mixed" => JsAlgorithm::Lz,
        _ => JsAlgorithm::Auto,
    }
} 