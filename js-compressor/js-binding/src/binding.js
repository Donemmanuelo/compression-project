import { compress_data, decompress_data, detect_file_type_js, suggest_algorithm_js, JsAlgorithm } from './compressor_wasm.js';

export class Compressor {
    static Algorithm = {
        RLE: JsAlgorithm.Rle,
        LZ: JsAlgorithm.Lz,
        AUTO: JsAlgorithm.Auto
    };

    static compress(data, algorithm = JsAlgorithm.Auto) {
        return compress_data(data, algorithm);
    }

    static decompress(data, algorithm = JsAlgorithm.Auto) {
        return decompress_data(data, algorithm);
    }

    static detectFileType(data) {
        return detect_file_type_js(data);
    }

    static suggestAlgorithm(fileType) {
        return suggest_algorithm_js(fileType);
    }
} 