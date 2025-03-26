import {
  createConnection,
  ProposedFeatures,
  InitializeParams,
  InitializeResult,
  TextDocumentSyncKind,
  TextDocuments,
  CompletionItem,
  TextDocumentPositionParams,
  Hover,
  Diagnostic,
  DiagnosticSeverity
} from 'vscode-languageserver/node';
import { TextDocument } from 'vscode-languageserver-textdocument';
import { getLanguageService, ClientCapabilities } from './custom-languageservice/jsonLanguageService';

// Create a connection for the server
const connection = createConnection(ProposedFeatures.all);
const documents = new TextDocuments(TextDocument);

// Create the JSON language service
const languageService = getLanguageService({
  clientCapabilities: ClientCapabilities.LATEST
});

connection.onInitialize((params: InitializeParams): InitializeResult => {
  return {
    capabilities: {
      textDocumentSync: {
        openClose: true,
        change: TextDocumentSyncKind.Incremental
      },
      // Enable completion support
      completionProvider: {
        resolveProvider: true,
        triggerCharacters: ['"', ':']
      },
      // Enable hover support
      hoverProvider: true,
      // Enable document symbol support
      documentSymbolProvider: true,
      // Enable code folding support
      foldingRangeProvider: true,
      // Enable selection range support
      selectionRangeProvider: true,
      // Enable document link support
      documentLinkProvider: { resolveProvider: false }
    }
  };
});

// Listen for text document changes
documents.onDidChangeContent(change => {
  validateTextDocument(change.document);
});

// Handle completion requests
connection.onCompletion(async (textDocumentPosition: TextDocumentPositionParams): Promise<CompletionItem[]> => {
  const document = documents.get(textDocumentPosition.textDocument.uri);
  if (!document) {
    return [];
  }

  const jsonDocument = languageService.parseJSONDocument(document);
  const completionList = await languageService.doComplete(document, textDocumentPosition.position, jsonDocument);
  return completionList?.items || [];
});

// Handle completion item resolution
connection.onCompletionResolve(async (item: CompletionItem): Promise<CompletionItem> => {
  const resolvedItem = await languageService.doResolve(item);
  return resolvedItem;
});

// Handle hover requests
connection.onHover(async (textDocumentPosition: TextDocumentPositionParams): Promise<Hover | null> => {
  const document = documents.get(textDocumentPosition.textDocument.uri);
  if (!document) {
    return null;
  }

  const jsonDocument = languageService.parseJSONDocument(document);
  const hover = await languageService.doHover(document, textDocumentPosition.position, jsonDocument);
  return hover;
});

// Validate the document
async function validateTextDocument(textDocument: TextDocument) {
  try {
    // Parse the document with our custom JSON parser
    const jsonDocument = languageService.parseJSONDocument(textDocument);
    
    // Get the diagnostics from the parser
    const diagnostics: Diagnostic[] = [];
    
    // Add syntax errors from the document
    if ('syntaxErrors' in jsonDocument) {
      const syntaxErrors = (jsonDocument as any).syntaxErrors;
      if (Array.isArray(syntaxErrors)) {
        diagnostics.push(...syntaxErrors);
      }
    }
    
    // If no syntax errors but also no root, the document is invalid
    if (diagnostics.length === 0 && !jsonDocument.root) {
      diagnostics.push({
        severity: DiagnosticSeverity.Error,
        range: {
          start: textDocument.positionAt(0),
          end: textDocument.positionAt(textDocument.getText().length)
        },
        message: "Invalid triple-json5 document",
        source: 'Triple JSON5'
      });
    }
    
    // Send the computed diagnostics to VS Code
    connection.sendDiagnostics({ uri: textDocument.uri, diagnostics });
  } catch (e: any) {
    // If any unexpected error occurs during validation
    connection.console.error(`Error validating triple-json5 document: ${e.message}`);
  }
}

// Document symbols
connection.onDocumentSymbol((params) => {
  const document = documents.get(params.textDocument.uri);
  if (!document) {
    return [];
  }

  const jsonDocument = languageService.parseJSONDocument(document);
  return languageService.findDocumentSymbols2(document, jsonDocument);
});

// Folding ranges
connection.onFoldingRanges((params) => {
  const document = documents.get(params.textDocument.uri);
  if (!document) {
    return [];
  }

  return languageService.getFoldingRanges(document);
});

// Selection ranges
connection.onSelectionRanges((params) => {
  const document = documents.get(params.textDocument.uri);
  if (!document) {
    return [];
  }

  const jsonDocument = languageService.parseJSONDocument(document);
  return languageService.getSelectionRanges(document, params.positions, jsonDocument);
});

// Document links
connection.onDocumentLinks(async (params) => {
  const document = documents.get(params.textDocument.uri);
  if (!document) {
    return [];
  }

  const jsonDocument = languageService.parseJSONDocument(document);
  const links = await languageService.findLinks(document, jsonDocument);
  return links;
});

documents.listen(connection);
connection.listen();