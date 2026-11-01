"""Inspection aid only: render legacy tokenised listings, never compiler input.

Uses this repository's BBC keyword table. Unknown tokens and encoded line
references remain visible markers. Does not claim a lossless dialect converter.
Downloaded inputs/listings belong in the ignored task build directory.
"""

import argparse
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[4]


def keywords():
    text = (ROOT / "include/bbc-ez80/MAIN.Z80").read_text()
    text = text.split("KEYWDS:", 1)[1].split("KEYWDL", 1)[0]
    table = {}
    for number, word in re.findall(
        r"DEFB\s+([0-9A-F]+)H\s*\n\s*DEFM\s+'([^']+)'", text
    ):
        table.setdefault(int(number, 16), word.rstrip())
    return table


def render(body, table):
    result = []
    quoted = False
    raw = False
    skip = 0
    for value in body:
        if skip:
            skip -= 1
            continue
        if value == 34:
            quoted = not quoted
        if raw or quoted or value == 34:
            result.append(chr(value) if 32 <= value < 127 else f"<byte:{value:02x}>")
        elif value == 0x8D:
            result.append("<encoded-line-reference>")
            skip = 3
        elif value >= 128 or value < 32:
            result.append(table.get(value, f"<token:{value:02x}>"))
            raw = value == 0xF4
        else:
            result.append(chr(value))
    return "".join(result)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("format", choices=("russell", "acorn"))
    parser.add_argument("path", type=Path)
    args = parser.parse_args()
    data = args.path.read_bytes()
    table = keywords()
    pos = 0
    while pos < len(data):
        if args.format == "russell":
            length = data[pos]
            if length == 0:
                assert data[pos:] == b"\0\xff\xff", "unexpected terminator"
                break
            assert length >= 4 and pos + length <= len(data)
            assert data[pos + length - 1] == 13
            number = int.from_bytes(data[pos + 1:pos + 3], "little")
            body = data[pos + 3:pos + length - 1]
        else:
            assert data[pos] == 13
            if data[pos + 1] == 255:
                assert pos + 2 == len(data), "unexpected terminator"
                break
            number = int.from_bytes(data[pos + 1:pos + 3], "big")
            length = data[pos + 3]
            assert length >= 4 and pos + length <= len(data)
            body = data[pos + 4:pos + length]
        print(number, render(body, table))
        pos += length
    else:
        raise ValueError("missing program terminator")


if __name__ == "__main__":
    main()
