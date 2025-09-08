use std::fs;
use std::env;
use base64::prelude::*;

fn main() {
    let args: Vec<String> = env::args().collect();
    if args.len() != 3 {
        eprintln!("Usage: {} <input_file> <output_data_file>", args[0]);
        std::process::exit(1);
    }

    let input_file = &args[1];
    let output_file = &args[2];

    let data = fs::read(input_file).expect("Failed to read input file");

    let encoded = BASE64_STANDARD.encode(&data);

    fs::write(output_file, encoded).expect("Failed to write output file");
    
    println!("Encoded {} to {}", input_file, output_file);
}