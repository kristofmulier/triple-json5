import * as path from 'path';
import * as vscode from 'vscode';
import {
  LanguageClient,
  LanguageClientOptions,
  ServerOptions,
  TransportKind
} from 'vscode-languageclient/node';

let client: LanguageClient;

export function activate(context: vscode.ExtensionContext) {
  // The server is implemented in Node (server.ts -> server.js).
  // We'll assume you'll compile it to lsp-server/out/server.js
  const serverModule = context.asAbsolutePath(path.join('lsp-server', 'out', 'server.js'));

  const debugOptions = { execArgv: ['--nolazy', '--inspect=6009'] };

  // If you need to debug the server, you can run it in debug mode
  // Otherwise the 'run' config starts it in normal mode
  const serverOptions: ServerOptions = {
    run: { module: serverModule, transport: TransportKind.ipc },
    debug: { module: serverModule, transport: TransportKind.ipc, options: debugOptions }
  };

  // Options to control the client
  const clientOptions: LanguageClientOptions = {
    // Files with language "triple-json5" trigger this language client
    documentSelector: [{ scheme: 'file', language: 'triple-json5' }],
    synchronize: {
      // Optionally, watch configuration changes in [settings].  
      // or watch certain files if you want
    }
  };

  // Create the language client
  client = new LanguageClient(
    'tripleJson5LanguageServer',
    'Triple JSON5 Language Server',
    serverOptions,
    clientOptions
  );

  // Start the client. This also launches the server
  client.start();
}

export function deactivate(): Thenable<void> | undefined {
  if (!client) {
    return undefined;
  }
  return client.stop();
}
