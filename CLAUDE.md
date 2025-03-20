# Triple-JSON5 Extension Reference

## Build Commands

```bash
# Compile the extension
npm run compile

# Package the extension for distribution
npm run package

# Run the extension in development mode
npm run dev
```

## Code Style Guidelines

- Use TypeScript for all new files
- Follow existing code style with 4-space indentation
- Add appropriate comments for complex logic
- Make sure to update all relevant files when adding new features

## Features Implemented

- Triple-quoted strings (""") - Support for multi-line strings without escaping
- Trailing commas in objects and arrays
- Special number formats: hexadecimal (0x) and binary (0b)

## Extension Structure

- `lsp-server/` - Contains the language server implementation
  - `server.ts` - Main server entry point
  - `custom-languageservice/` - Custom language service implementation
    - `parser/` - JSON parser customization
    - `utils/` - Utility functions
      - `tripleStringProcessor.ts` - Handles triple-quoted strings
      - `json5Scanner.ts` - Custom scanner for JSON5 features

- `lsp-client/` - Contains the language client implementation
  - `client.ts` - Main client entry point

- `syntaxes/` - TextMate grammar for syntax highlighting
  - `tjson5.json` - Grammar rules for Triple-JSON5