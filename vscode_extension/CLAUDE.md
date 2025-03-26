# Triple-JSON5 Extension Reference

## Project Overview

Triple-JSON5 (`.tjson5` files) is a data format extending JSON5 with Python-style triple-quoted strings and additional number formats. The project consists of two primary components:

1. **VSCode Extension**: Provides syntax highlighting and LSP (Language Server Protocol) processing for `.tjson5` files in VSCode
2. **Python Module**: A high-performance Cython-based parser that converts `.tjson5` files into Python dictionaries

Key features:
- Triple-quoted strings (""") for convenient multiline string support
- All JSON5 features including comments and trailing commas
- Support for binary (0b) and hexadecimal (0x) number formats
- Integration in VSCode and a Python Module to converts `.tjson5` files into Python dictionaries

## Build Commands

### VSCode Extension

```sh
# Compile the extension
npm run compile

# Watch for changes and recompile
npm run watch

# Package the extension for distribution
npm run package
```

These build commands create a `triple-json5-x.x.x.vsix` file in the toplevel `triple-json5/` folder which you can install as a VSCode extension.

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

## Code Style Guidelines

- Use TypeScript for all VSCode extension files
- Use Python/Cython for the Python module implementation
- Follow existing code style with 4-space indentation
- Add appropriate comments for complex logic
- Make sure to update all relevant files when adding new features

## Features Implemented

- Triple-quoted strings (""") - Support for multi-line strings without escaping
  - Implemented in `tripleStringProcessor.ts` for VSCode extension
  - Implemented in `tjson5parser.pyx` for Python module
  - Allows for multi-line strings without escape characters

- Trailing commas in objects and arrays
  - Modified parser to accept trailing commas in objects and arrays
  - Compatible with the JSON5 spec

- Special number formats: hexadecimal (0x) and binary (0b)
  - Implemented in `json5Scanner.ts` and `tjson5parser.pyx`
  - Converts hex and binary literals to decimal before parsing
  - Examples: `0xFF` (hex) → `255`, `0b1010` (binary) → `10`

## Project Structure

### VSCode Extension

- `lsp-server/` - Contains the language server implementation
  - `server.ts` - Main server entry point
  - `custom-languageservice/` - Custom language service implementation
    - `parser/` - JSON parser customization
      - `jsonParser.ts` - Modified parser with Triple-JSON5 features
    - `utils/` - Utility functions
      - `tripleStringProcessor.ts` - Handles triple-quoted strings
      - `json5Scanner.ts` - Preprocesses hex/binary numbers

- `lsp-client/` - Contains the language client implementation
  - `client.ts` - Main client entry point

- `syntaxes/` - TextMate grammar for syntax highlighting
  - `tjson5.json` - Grammar rules for Triple-JSON5

### Python Module

- `python_tjson5/` - Contains the Python module implementation
  - `tjson5parser.pyx` - Cython implementation of the TJSON5 parser
  - `tjson5parser.c` - Generated C code from the Cython file
  - `setup.py` - Build script for the Python module
  - `example.py` - Example usage of the Python module
  - `test_01.py`, `test_02.py` - Test files for the Python module

## Implementation Notes

### VSCode Extension

The extension uses a two-stage preprocessing approach:
1. First, triple-quoted strings are processed by `preprocessTripleQuotedStrings`
2. Then, hex/binary numbers are converted to decimal by `preprocessNumbers`

This approach allows for proper syntax highlighting and parsing while maintaining accurate diagnostic messages at the correct source positions.

### Python Module

The Python module uses Cython for high-performance parsing:
1. The `tjson5parser.pyx` file defines the core parsing functionality
2. It exposes a standard Python API similar to the built-in `json` module
3. The implementation preprocesses triple-quoted strings and special number formats
4. It maintains position mapping for accurate error reporting
5. The parser handles JSON5 features like comments and trailing commas