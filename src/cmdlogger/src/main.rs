use chrono::{DateTime, Local};
use clap::Parser;
use serde::{Deserialize, Serialize};
use std::{
    collections::HashSet,
    env::{self},
    fs::{File, OpenOptions},
    io::{BufRead, BufReader, BufWriter, Write},
    path::{Path, PathBuf},
    str::FromStr,
};

#[derive(Serialize, Deserialize)]
struct Record {
    date: String,
    host: String,
    user: String,
    dir: String,
    cmd: String,
}

fn log_cmdline(history_file: &Path, cmdline: &str) {
    let cmdline = cmdline.trim();

    let curdir = env::current_dir().expect("Cannot get the current directory.");
    let username = whoami::username();
    let host = whoami::fallible::hostname().expect("Cannot get the hostname.");

    let datetime: DateTime<Local> = Local::now();
    let datetime_fmt = datetime.format("%Y-%m-%d %H:%M:%S");

    let record = Record {
        date: datetime_fmt.to_string(),
        host: host,
        user: username,
        dir: curdir.to_str().unwrap().to_string(),
        cmd: cmdline.to_string(),
    };

    let f = OpenOptions::new()
        .create(true)
        .append(true)
        .open(history_file)
        .expect("Cannot open the file.");
    let mut writer = BufWriter::new(f);

    let jsonl = serde_json::to_string(&record).unwrap();

    writeln!(&mut writer, "{}", jsonl).unwrap();
}

fn parse_records(path: &Path) -> impl Iterator<Item = Result<Record, serde_json::Error>> {
    let f = match File::open(path) {
        Ok(f) => f,
        Err(_) => {
            File::create(path).expect("Cannot create a history file.");
            File::open(path).expect("Cannot create a history file.")
        }
    };
    let reader = BufReader::new(f);

    reader
        .lines()
        .map(|line| serde_json::from_str::<Record>(&line.unwrap()))
}

fn lookup_records(records: impl Iterator<Item = Result<Record, serde_json::Error>>) {
    let mut seen: HashSet<String> = HashSet::new();
    let curdir = env::current_dir().expect("Cannot get the current directory.");
    let records = records
        .filter_map(|record| match record {
            Ok(record) if PathBuf::from_str(&record.dir).unwrap() == curdir => Some(Ok(record)),
            Ok(_) => None,
            Err(e) => Some(Err(e)),
        })
        .collect::<Result<Vec<Record>, serde_json::Error>>()
        .expect("Cannot parse the JSON object.");

    for record in records.iter().rev() {
        let cmd = record.cmd.replace("\n", "\\n");
        if seen.insert(cmd.clone()) {
            print!("{}{}", cmd, '\0');
        }
    }
}

fn lookup_unique_history(history_file: &Path) {
    lookup_records(parse_records(history_file));
}

fn print_records(records: impl Iterator<Item = Result<Record, serde_json::Error>>, unique: bool) {
    let mut seen: HashSet<String> = HashSet::new();
    for (i, record) in records.enumerate() {
        let mut record = record.expect("Cannot parse the JSON object.");
        record.cmd = record.cmd.replace("\n", "\\n");
        if !unique || seen.insert(record.cmd.clone()) {
            println!("{:>5} {} {}", i + 1, record.date, record.cmd);
        }
    }
}

fn print_history(history_file: &Path) {
    print_records(parse_records(history_file), false);
}

fn print_unique_history(history_file: &Path) {
    print_records(parse_records(history_file), true);
}

#[derive(Parser)]
#[command(version, about, long_about = None)]
struct Args {
    /// Log the command line.
    #[arg(short, long, default_value = "")]
    appned: String,
    /// Look up history of the current directory.
    #[arg(short, long)]
    lookup: bool,
    /// Print history of the current directory.
    #[arg(short, long)]
    print: bool,
    /// Print unique history of the current directory.
    #[arg(short, long)]
    unique_print: bool,
}

fn main() {
    let args = Args::parse();

    let history_file = match env::var("CMDLOG_HISTORY_FILE") {
        Ok(path) => Path::new(&path).to_path_buf(),
        Err(_) => dirs::home_dir().unwrap().join(Path::new(".cmdlog_history")),
    };
    let history_file = history_file.as_path();

    if args.appned.len() > 0 {
        log_cmdline(history_file, &args.appned);
    } else if args.lookup {
        lookup_unique_history(history_file);
    } else if args.unique_print {
        print_unique_history(history_file);
    } else if args.print {
        print_history(history_file);
    }
}
