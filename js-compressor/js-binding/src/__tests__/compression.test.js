const { rleCompress, rleDecompress, lz77Compress, lz77Decompress } = require('../binding');

describe('RLE Compression', () => {
    test('should compress and decompress repeated data', () => {
        const input = Buffer.from('AAABBBCCCCCDDDDE');
        const compressed = rleCompress(input);
        const decompressed = rleDecompress(compressed);
        expect(decompressed).toEqual(input);
    });

    test('should handle single bytes', () => {
        const input = Buffer.from('ABCDE');
        const compressed = rleCompress(input);
        const decompressed = rleDecompress(compressed);
        expect(decompressed).toEqual(input);
    });

    test('should handle maximum run length', () => {
        const input = Buffer.from('A'.repeat(300));
        const compressed = rleCompress(input);
        const decompressed = rleDecompress(compressed);
        expect(decompressed).toEqual(input);
    });
});

describe('LZ77 Compression', () => {
    test('should compress and decompress with patterns', () => {
        const input = Buffer.from('ABABABABABAB');
        const compressed = lz77Compress(input);
        const decompressed = lz77Decompress(compressed);
        expect(decompressed).toEqual(input);
    });

    test('should handle non-repeating data', () => {
        const input = Buffer.from('ABCDEFGHIJKLMNOPQRSTUVWXYZ');
        const compressed = lz77Compress(input);
        const decompressed = lz77Decompress(compressed);
        expect(decompressed).toEqual(input);
    });

    test('should handle empty input', () => {
        const input = Buffer.from('');
        const compressed = lz77Compress(input);
        const decompressed = lz77Decompress(compressed);
        expect(decompressed).toEqual(input);
    });
}); 