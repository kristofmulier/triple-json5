# Triple-JSON5 (tjson5)

Do you love JSON5, but you hate to put all string values on a single line?

While JSON5 lets you spread string values over multiple lines, it's far from elegant (you need to escape each line with a `\`).

**Triple-JSON5** (`.tjson5`) is a data format extending JSON5 with Python-style triple-quoted strings and additional number formats:

```json5
{
  // This is a single line comment
  /*
    This is a multiline comment
  */
  "key1": """this is a single line string""",
  "key2": """
    this is a multiline string
  """,
  "key3": "foo",    // String value
  "key4": 1010,     // Decimal number
  "key5": 0b0101,   // Binary number
  "key6": 0xBEEF,   // Hex number
  "key7": "foobar", // Trailing comma allowed
}
```

The project consists of two primary components:

1. **VSCode Extension**: Provides syntax highlighting and LSP (Language Server Protocol) processing for `.tjson5` files in VSCode
2. **Python Module**: A high-performance Cython-based parser that converts `.tjson5` files into Python dictionaries

## Project Components

This project consists of two main components:

### 1. VSCode Extension

A Visual Studio Code extension that provides:
- Syntax highlighting for `.tjson5` files
- Language Server Protocol (LSP) support with diagnostics and code intelligence
- Automatic validation of `.tjson5` files

### 2. Python Module

A high-performance Python module for parsing `.tjson5` files:
- Fast Cython-based implementation for near-native speed
- Standard interface compatible with Python's built-in JSON module
- Support for all Triple-JSON5 features (triple quotes, hex/binary numbers, JSON5 syntax)

## Installation

### VSCode Extension

* Clone this repo: `git clone https://github.com/kristofmulier/triple-json5`.
* Open VSCode.
* Open the **Extensions** tab on the left.
* Click the three dots `...` in the top-right corner of the **Extensions** tab, then select `"Install from VSIX..."` in the dropdown.
* Select the `triple-json5-x.x.x.vsix` file from this repo.
* Open a `.tjson5` file and check if the language in VSCode switches to `Triple JSON5`.

To recompile the `triple-json5-x.x.x.vsix` file, execute these commands:

```sh
# Compile the extension
npm run compile

# Watch for changes and recompile
npm run watch

# Package the extension for distribution
npm run package
```

### Python Module

```sh
# CD into the python module project
cd python_tjson5

# Generate C code from Cython
python setup.py build_ext --inplace --use-cython

# Build wheel package
python setup.py bdist_wheel

# After running this script, you'll find the wheel file in the dist directory,
# which you can install with pip.
# Then you can import the tjson5parser in Python like this:
# 
#     import tjson5parser
#     sample = ''' <file content here> '''
#     data = tjson5parser.parse(sample)
#     print(data)
```

These build commands can also be found in `python_tjson5/build.bat` and `python_tjson5/build.sh`.

## Python Usage

```python
import tjson5parser

# Parse a TJSON5 string
data = tjson5parser.parse('''
{
    // Comments are supported
    "name": "TJSON5 Example",
    "description": """
        Multi-line strings
        are easy to use!
    """,
    "values": [1, 0xFF, 0b1010,],  // Hex, binary, and trailing commas
}
''')

# Load from a file
with open('config.tjson5', 'r') as f:
    config = tjson5parser.load(f)

# Convert to standard JSON
with open('output.json', 'w') as f:
    tjson5parser.dump(data, f, indent=2)
```

## Credits

This project builds on the following MIT-licensed projects:
- The syntax highlighting is based on https://github.com/mrmlnc/vscode-json5
- The LSP (Language Server Protocol) is based on https://github.com/microsoft/vscode-json-languageservice

## License

This software is released under the terms of the MIT license.