import { Command } from 'commander';
import fs from 'fs/promises';

const program = new Command();

function rleCompress(data) {
    const result = [];
    let i = 0;
    while (i < data.length) {
        let count = 1;
        while (i + count < data.length && data[i] === data[i + count] && count < 255) {
            count++;
        }
        result.push(count);
        result.push(data[i]);
        i += count;
    }
    return Buffer.from(result);
}

function rleDecompress(data) {
    const result = [];
    let i = 0;
    while (i < data.length) {
        const count = data[i];
        const value = data[i + 1];
        for (let j = 0; j < count; j++) {
            result.push(value);
        }
        i += 2;
    }
    return Buffer.from(result);
}

function lz77Compress(data) {
    const result = [];
    let i = 0;
    while (i < data.length) {
        if (i > 0 && data[i] === data[i - 1]) {
            let count = 1;
            while (i + count < data.length && data[i + count] === data[i] && count < 255) {
                count++;
            }
            result.push(1); // offset
            result.push(count);
            i += count;
        } else {
            result.push(0);
            result.push(data[i]);
            i++;
        }
    }
    return Buffer.from(result);
}

function lz77Decompress(data) {
    const result = [];
    let i = 0;
    while (i < data.length) {
        const offset = data[i];
        if (offset === 0) {
            result.push(data[i + 1]);
            i += 2;
        } else {
            const len = data[i + 1];
            const pos = result.length - offset;
            for (let j = 0; j < len; j++) {
                result.push(result[pos]);
            }
            i += 2;
        }
    }
    return Buffer.from(result);
}

program
    .name('js-compressor')
    .description('JavaScript implementation of RLE and LZ77 compression algorithms');

program
    .command('compress')
    .argument('<input>', 'input file path')
    .argument('<output>', 'output file path')
    .option('--algorithm <type>', 'compression algorithm (rle or lz77)')
    .action(async (input, output, options) => {
        try {
            const data = await fs.readFile(input);
            let compressed;
            switch (options.algorithm) {
                case 'rle':
                    compressed = rleCompress(data);
                    break;
                case 'lz77':
                    compressed = lz77Compress(data);
                    break;
                default:
                    throw new Error('Unsupported algorithm');
            }
            await fs.writeFile(output, compressed);
        } catch (error) {
            console.error('Error:', error.message);
            process.exit(1);
        }
    });

program
    .command('decompress')
    .argument('<input>', 'input file path')
    .argument('<output>', 'output file path')
    .option('--algorithm <type>', 'compression algorithm (rle or lz77)')
    .action(async (input, output, options) => {
        try {
            const data = await fs.readFile(input);
            let decompressed;
            switch (options.algorithm) {
                case 'rle':
                    decompressed = rleDecompress(data);
                    break;
                case 'lz77':
                    decompressed = lz77Decompress(data);
                    break;
                default:
                    throw new Error('Unsupported algorithm');
            }
            await fs.writeFile(output, decompressed);
        } catch (error) {
            console.error('Error:', error.message);
            process.exit(1);
        }
    });

program.parse(); 