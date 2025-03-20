# Triple JSON5 - Development Guide

## Build Commands
- Compile: `npm run compile` - Compiles TypeScript files for both client and server
- Watch: `npm run watch` - Watches TypeScript files for changes
- Package: `npm run package` or `./build.sh` - Creates VSCode extension package

## Testing
- Run all tests: `npx mocha lsp-server/custom-languageservice/test/**/*.test.ts`
- Run single test: `npx mocha lsp-server/custom-languageservice/test/specific-file.test.ts`

## Code Style
- TypeScript configuration: ES2020, CommonJS modules, strict type checking
- Use 2-space indentation
- Use single quotes for strings
- Use explicit typing
- Include JSDoc comments in test files
- Use descriptive camelCase function/variable names
- Proper error handling with try/catch blocks
- Group and organize imports
- Use explicit imports rather than wildcard imports
- Use semicolons consistently