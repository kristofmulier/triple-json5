/*---------------------------------------------------------------------------------------------
 *  Custom scanner for JSON5 with support for hex/binary numbers
 *--------------------------------------------------------------------------------------------*/

import * as Json from 'jsonc-parser';

export { SyntaxKind, ScanError } from 'jsonc-parser';

/**
 * A wrapper around the JSONC scanner that supports JSON5 features like hex and binary numbers.
 */
export function createJson5Scanner(text: string, ignoreTrivia = false) {
    // Create the original scanner
    const jsonScanner = Json.createScanner(text, ignoreTrivia);
    
    // Wrap with custom scan function
    const originalScan = jsonScanner.scan;
    const originalGetTokenValue = jsonScanner.getTokenValue;
    const originalGetTokenError = jsonScanner.getTokenError;
    
    // Keep track of modified tokens
    let currentToken: Json.SyntaxKind | null = null;
    let currentTokenIsCustom = false;
    let lastTokenValue = '';
    
    jsonScanner.scan = function() {
        currentTokenIsCustom = false;
        currentToken = originalScan.call(this);
        
        // If we got an Unknown token, check if it's a hex or binary number
        if (currentToken === Json.SyntaxKind.Unknown) {
            lastTokenValue = originalGetTokenValue.call(this);
            const hexRegex = /^0x[0-9A-Fa-f]+$/;
            const binaryRegex = /^0b[01]+$/;
            
            if (hexRegex.test(lastTokenValue) || binaryRegex.test(lastTokenValue)) {
                // Return NumericLiteral for hex/binary formats
                currentTokenIsCustom = true;
                return Json.SyntaxKind.NumericLiteral;
            }
        }
        
        return currentToken;
    };
    
    // Override getTokenValue to return the proper value for custom tokens
    jsonScanner.getTokenValue = function() {
        if (currentTokenIsCustom && currentToken === Json.SyntaxKind.NumericLiteral) {
            return lastTokenValue;
        }
        return originalGetTokenValue.call(this);
    };
    
    // Override getTokenError to return ScanError.None for our custom tokens
    jsonScanner.getTokenError = function() {
        if (currentTokenIsCustom) {
            return Json.ScanError.None;
        }
        return originalGetTokenError.call(this);
    };
    
    return jsonScanner;
}