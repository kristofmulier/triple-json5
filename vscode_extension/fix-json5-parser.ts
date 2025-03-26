import * as fs from 'fs';
import * as path from 'path';

const filePath = path.join(__dirname, 'lsp-server/custom-languageservice/parser/jsonParser.ts');
const fileContent = fs.readFileSync(filePath, 'utf8');

let modifiedContent = fileContent;

// Fix the array trailing comma validation (around line 1232-1234)
modifiedContent = modifiedContent.replace(
  /_errorAtRange\(l10n\.t\('Trailing comma'\), ErrorCode\.TrailingComma, commaOffset, commaOffset \+ 1\);/g,
  '// JSON5 allows trailing commas'
);

fs.writeFileSync(filePath, modifiedContent, 'utf8');
console.log('Successfully modified parser to allow trailing commas.');
