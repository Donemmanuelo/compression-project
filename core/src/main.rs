use std::io::{self, Read, Write};
use std::path::Path;
use std::fs::File;
use clap::{Parser, ValueEnum};
use compressor::{compress, decompress, Algorithm, detect_file_type, suggest_algorithm};

#[derive(Parser)]
#[command(author, version, about, long_about = None)]
struct Cli {
    /// The algorithm to use
    #[arg(short, long, value_enum, default_value_t = Algorithm::Rle)]
    algorithm: Algorithm,

    /// Input file path
    #[arg(short, long)]
    input: String,

    /// Output file path
    #[arg(short, long)]
    output: String,

    /// Operation to perform
    #[arg(value_enum)]
    operation: Operation,

    /// Enable stdin/stdout support (use - for stdin/stdout)
    #[arg(long)]
    use_streams: bool,

    /// Enable automatic algorithm selection
    #[arg(long)]
    auto_algorithm: bool,

    /// Enable multiple file processing
    #[arg(long)]
    multiple_files: bool,

    /// Output directory for multiple files (required if multiple_files is true)
    #[arg(long)]
    output_dir: Option<String>,
}

#[derive(Copy, Clone, PartialEq, Eq, PartialOrd, Ord, ValueEnum)]
enum Operation {
    /// Compress the input
    Compress,
    /// Decompress the input
    Decompress,
}

fn process_single_file(input: &str, output: &str, operation: Operation, algorithm: Algorithm) -> io::Result<()> {
    // Read input
    let mut input_data = Vec::new();
    if input == "-" {
        io::stdin().read_to_end(&mut input_data)?;
    } else {
        let mut file = File::open(input)?;
        file.read_to_end(&mut input_data)?;
    }

    // Determine algorithm
    let algorithm = match algorithm {
        Algorithm::Auto => {
            if input != "-" {
                let file_type = detect_file_type(input)?;
                suggest_algorithm(file_type)
            } else {
                Algorithm::Lz // Default to LZ for stdin
            }
        }
        algo => algo,
    };

    // Process data
    let result = match operation {
        Operation::Compress => compress(&input_data, algorithm),
        Operation::Decompress => decompress(&input_data, algorithm),
    };

    // Write output
    if output == "-" {
        io::stdout().write_all(&result)?;
    } else {
        let mut file = File::create(output)?;
        file.write_all(&result)?;
    }

    Ok(())
}

fn main() -> io::Result<()> {
    let cli = Cli::parse();

    if cli.multiple_files {
        // Multiple file processing
        let output_dir = cli.output_dir.ok_or_else(|| {
            io::Error::new(io::ErrorKind::InvalidInput, "Output directory required for multiple files")
        })?;

        let inputs: Vec<&str> = cli.input.split(',').collect();
        for input in inputs {
            let output_name = if input == "-" {
                "stdin".to_string()
            } else {
                Path::new(input)
                    .file_name()
                    .and_then(|n| n.to_str())
                    .map(|s| s.to_string())
                    .unwrap_or_else(|| "output".to_string())
            };

            let output_path = Path::new(&output_dir).join(output_name);
            process_single_file(input, output_path.to_str().unwrap(), cli.operation, cli.algorithm)?;
        }
    } else {
        // Single file processing
        process_single_file(&cli.input, &cli.output, cli.operation, cli.algorithm)?;
    }

    Ok(())
} 