# Triple-JSON5 Extension Reference

## Project Overview

Triple-JSON5 (tjson5) is a VSCode extension that provides syntax highlighting and LSP (Language Server Protocol) processing for `.tjson5` files. It extends JSON5 with the addition of Python-style triple-quoted strings, allowing users to easily create multiline strings without escape characters.

Key features:
- Triple-quoted strings (""") for convenient multiline string support
- All JSON5 features including comments and trailing commas
- Support for binary (0b) and hexadecimal (0x) number formats

## Build Commands

```bash
# Compile the extension
npm run compile

# Watch for changes and recompile
npm run watch

# Package the extension for distribution
npm run package
```

## Code Style Guidelines

- Use TypeScript for all new files
- Follow existing code style with 4-space indentation
- Add appropriate comments for complex logic
- Make sure to update all relevant files when adding new features

## Features Implemented

- Triple-quoted strings (""") - Support for multi-line strings without escaping
  - Implemented in `tripleStringProcessor.ts` by preprocessing text before parsing
  - Allows for multi-line strings without escape characters

- Trailing commas in objects and arrays
  - Modified parser to accept trailing commas in objects and arrays
  - Compatible with the JSON5 spec

- Special number formats: hexadecimal (0x) and binary (0b)
  - Implemented in `json5Scanner.ts` by preprocessing text
  - Converts hex and binary literals to decimal before parsing
  - Examples: `0xFF` (hex) → `255`, `0b1010` (binary) → `10`

## Extension Structure

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

## Implementation Notes

The extension uses a two-stage preprocessing approach:
1. First, triple-quoted strings are processed by `preprocessTripleQuotedStrings`
2. Then, hex/binary numbers are converted to decimal by `preprocessNumbers`

This approach allows for proper syntax highlighting and parsing while maintaining accurate diagnostic messages at the correct source positions.