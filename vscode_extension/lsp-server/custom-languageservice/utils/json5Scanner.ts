/*---------------------------------------------------------------------------------------------
 *  Custom scanner for JSON5 with support for hex/binary numbers
 *--------------------------------------------------------------------------------------------*/

import * as Json from 'jsonc-parser';

export { SyntaxKind, ScanError } from 'jsonc-parser';

/**
 * Preprocesses text to handle hex and binary numbers before scanning.
 * This approach converts 0x and 0b numbers to regular decimal numbers.
 */
export function preprocessNumbers(text: string): string {
    // Regular expressions to find hex and binary numbers
    const hexRegex = /\b0x([0-9A-Fa-f]+)\b/g;
    const binaryRegex = /\b0b([01]+)\b/g;
    
    // Replace hex numbers with their decimal equivalents
    let processedText = text.replace(hexRegex, (match, hexDigits) => {
        const decimalValue = parseInt(hexDigits, 16);
        return decimalValue.toString();
    });
    
    // Replace binary numbers with their decimal equivalents
    processedText = processedText.replace(binaryRegex, (match, binaryDigits) => {
        const decimalValue = parseInt(binaryDigits, 2);
        return decimalValue.toString();
    });
    
    return processedText;
}

/**
 * A wrapper around the JSONC scanner that supports JSON5 features like hex and binary numbers.
 * The text is preprocessed to convert hex/binary numbers to decimal before scanning.
 */
export function createJson5Scanner(text: string, ignoreTrivia = false) {
    // Preprocess the text to handle hex/binary numbers
    const processedText = preprocessNumbers(text);
    
    // Create the original scanner with the processed text
    return Json.createScanner(processedText, ignoreTrivia);
}