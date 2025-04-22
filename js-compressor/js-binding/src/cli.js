#!/usr/bin/env node

const { program } = require('commander');
const fs = require('fs/promises');
const ProgressBar = require('progress');
const { rleCompress, rleDecompress, lz77Compress, lz77Decompress } = require('./binding');

program
    .name('compression-cli')
    .description('CLI for file compression using RLE and LZ77 algorithms')
    .version('1.0.0');

program
    .command('compress')
    .description('Compress a file')
    .requiredOption('-i, --input <file>', 'input file path')
    .requiredOption('-o, --output <file>', 'output file path')
    .requiredOption('-a, --algorithm <type>', 'compression algorithm (rle or lz)')
    .action(async (options) => {
        try {
            const data = await fs.readFile(options.input);
            
            const bar = new ProgressBar('Compressing [:bar] :percent :etas', {
                total: data.length,
                width: 40,
            });

            const compressed = options.algorithm === 'rle' 
                ? rleCompress(data)
                : lz77Compress(data);

            bar.tick(data.length);
            await fs.writeFile(options.output, compressed);
            console.log('Compression completed successfully!');
        } catch (error) {
            console.error('Error during compression:', error);
            process.exit(1);
        }
    });

program
    .command('decompress')
    .description('Decompress a file')
    .requiredOption('-i, --input <file>', 'input file path')
    .requiredOption('-o, --output <file>', 'output file path')
    .requiredOption('-a, --algorithm <type>', 'compression algorithm (rle or lz)')
    .action(async (options) => {
        try {
            const data = await fs.readFile(options.input);
            
            const bar = new ProgressBar('Decompressing [:bar] :percent :etas', {
                total: data.length,
                width: 40,
            });

            const decompressed = options.algorithm === 'rle'
                ? rleDecompress(data)
                : lz77Decompress(data);

            bar.tick(data.length);
            await fs.writeFile(options.output, decompressed);
            console.log('Decompression completed successfully!');
        } catch (error) {
            console.error('Error during decompression:', error);
            process.exit(1);
        }
    });

program.parse(); 