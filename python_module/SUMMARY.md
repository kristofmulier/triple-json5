# TJSON5 Cython Implementation Summary

## Overview

This project implements a high-performance Triple-JSON5 parser for Python using Cython. The parser supports all the features of JSON5 plus triple-quoted strings and special number formats (hexadecimal and binary).

## Key Files

- `tjson5parser.pyx` - The core Cython implementation
- `setup.py` - Build script for compiling the Cython extension
- `test_tjson5.py` - Unit tests
- `example.py` - Example usage
- `README.md` - Documentation
- `MANIFEST.in` - Package manifest

## Implementation Details

### Performance Characteristics

The Cython implementation offers significant performance advantages over a pure Python approach:

1. **Preprocessing Speed**: The triple-quoted string and number format conversions are implemented in Cython with static typing, which runs much faster than Python equivalents.

2. **Memory Efficiency**: The implementation minimizes intermediate string copies and uses efficient data structures.

3. **C-level Function Calls**: Critical sections use C-level function calls where possible.

### Parsing Pipeline

The parser uses a multi-stage preprocessing approach:

1. **Triple-quoted String Processing**: Converts `"""..."""` to standard JSON quotes with proper escaping
2. **Number Format Conversion**: Converts hex (`0xFF`) and binary (`0b101`) literals to decimal
3. **Comment Removal**: Strips both single-line (`//`) and multi-line (`/* */`) comments
4. **Trailing Comma Handling**: Removes trailing commas in objects and arrays
5. **JSON Parsing**: Leverages Python's built-in `json` module for the final parsing

### Error Handling

For error reporting, the implementation maintains a position map to accurately translate error positions in the processed text back to positions in the original source. This ensures that error messages point to the correct location in the TJSON5 file.

## Usage

```python
import tjson5parser

# Parse a string
data = tjson5parser.parse('''
{
    // Comments are supported
    name: "Triple-JSON5",
    description: """
        Multi-line strings work great
        with "embedded quotes"
    """,
    values: [0xFF, 0b1010]  // Hex and binary literals
}
''')

# Load from a file
with open('config.tjson5', 'r') as f:
    config = tjson5parser.load(f)

# Write to a file (as standard JSON)
with open('output.json', 'w') as f:
    tjson5parser.dump(data, f, indent=2)
```

## Building and Installation

```bash
# Build the extension in place (for development)
python setup.py build_ext --inplace

# Install the package
pip install .

# Create a distributable package
python setup.py sdist
```