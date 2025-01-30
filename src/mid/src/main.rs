use std::{
    fs::File,
    io::{self, BufRead, BufReader, Read, Write},
    num::ParseIntError,
};

use clap::Parser;

/// Prints the Nth line of a file.
#[derive(Parser, Debug)]
#[command(version, about, long_about = None)]
struct Args {
    /// The line number (N) or range (M-N) to display.
    #[arg(id = "N|M-N|M+N")]
    lines: String,
    /// Files to be displayed. If not specified, read from the standard input.
    #[arg(verbatim_doc_comment)]
    files: Vec<String>,

    /// The line number will be treated as zero-indexed.
    #[arg(short = '0', long, default_value_t = false)]
    zero_indexed: bool,
    /// Display head-style file headers if there is more than one file.
    #[arg(short, long)]
    verbose: bool,
}

fn parse_range(lines: &str) -> Result<(usize, usize), ParseIntError> {
    if lines.contains("-") {
        let (start, end) = lines.split_once("-").expect("Cannot parse the range.");
        Ok((start.parse()?, end.parse::<usize>()? + 1))
    } else if lines.contains("+") {
        let (start, end) = lines.split_once("+").expect("Cannot parse the range.");
        let start_i: usize = start.parse()?;
        Ok((start_i, start_i + end.parse::<usize>()? + 1))
    } else {
        let n: usize = lines.parse()?;
        Ok((n, n + 1))
    }
}

fn print_lines<R: Read>(stream: &mut BufReader<R>, start: usize, end: usize) {
    // Iterator-based naive implementation
    // for line in stream.lines().skip(start).take(end - start) {
    //     println!("{}", line.as_ref().unwrap());
    // }

    // Faster version.
    // This implementation avoids the heap allocations due to reading each line as String.
    let mut buffer: Vec<u8> = Vec::new();
    let mut i: usize = 0;
    while stream.read_until(b'\n', &mut buffer).unwrap() > 0 {
        if i >= start && i < end {
            io::stdout().write_all(&buffer).unwrap();
        }
        buffer.clear();
        i += 1;
        if i >= end {
            break;
        }
    }
}

fn main() {
    let args: Args = Args::parse();

    let (mut start, mut end) = parse_range(&args.lines).expect("Cannot parse line numbers.");
    if !args.zero_indexed {
        start -= 1;
        end -= 1;
    }

    if args.files.len() == 0 {
        let mut buf_reader = io::BufReader::new(io::stdin());
        print_lines(&mut buf_reader, start, end);
    } else {
        for (i, path) in args.files.into_iter().enumerate() {
            let f = File::open(&path).expect("File not found.");
            if args.verbose {
                if i >= 1 {
                    println!()
                }
                println!("==> {} <==", &path)
            }
            let mut buf_reader = io::BufReader::new(f);
            print_lines(&mut buf_reader, start, end);
        }
    }
}
