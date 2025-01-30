#!/usr/bin/env python3

"""
Prints the Nth line of a file or of each of a list of files.
Default input stream is sys.stdin.

Usage:
   mid [-v] LINENO FILE1 [FILE2 FILE3 ...]
   cat FILE | mid LINENO

where LINENO is the 1-indexed line number to display (or a range: M-N).
If `-v` is present, it will print a UNIX `head`-style header above each
file, identifying its provenance.

Author: Matt Post <post@cs.jhu.edu>
Modifier: Hiroyuki Deguchi <deguchi.hiroyuki.db0@is.naist.jp>
"""

import argparse
import gzip
import sys
from io import TextIOWrapper
from itertools import zip_longest
from typing import TextIO, Union


def smart_read(filename: str) -> Union[TextIO, TextIOWrapper]:
    try:
        if filename == "-":
            return sys.stdin
        elif filename.endswith(".gz"):
            return gzip.open(filename, mode="rt", encoding="utf-8")
        else:
            return open(filename, mode="rt", encoding="utf-8")
    except FileNotFoundError:
        print("Can't find file: {}".format(filename))
        sys.exit(1)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser("Grabs a line from one or more files")
    parser.add_argument(
        "--verbose",
        "-v",
        default=False,
        action="store_true",
        help="Display head-style file headers if there is more than one file",
    )
    parser.add_argument(
        "--zero-indexed",
        "-0",
        default=False,
        action="store_true",
        help="The line number is treated as zero-indexed",
    )
    parser.add_argument(
        "lines", help="The line number (N) or range (M-N or M:N) to display"
    )
    parser.add_argument(
        "files",
        nargs="*",
        type=smart_read,
        default=[sys.stdin],
        help="The files to work with",
    )
    return parser.parse_args()


def main(args: argparse.Namespace) -> None:
    if "-" in args.lines:
        start, stop = map(lambda x: int(x), args.lines.split("-"))
    elif "+" in args.lines:
        start, stop = map(lambda x: int(x), args.lines.split("+"))
        stop = start + stop
    else:
        start = int(args.lines)
        stop = int(args.lines)

    for i, lines in enumerate(zip_longest(*args.files), 0 if args.zero_indexed else 1):
        if i < start:
            continue
        if i > stop:
            break

        for j, line in enumerate(lines):
            if line is not None:
                if args.verbose:
                    print(
                        "=== {}".format(args.files[j].name), line.rstrip(), "", sep="\n"
                    )
                else:
                    print(line.rstrip())


def cli_main() -> None:
    args = parse_args()
    main(args)


if __name__ == "__main__":
    cli_main()
