/*---------------------------------------------------------------------------------------------
 *  Triple quoted string processor for Triple JSON5
 *--------------------------------------------------------------------------------------------*/

/**
 * Result of preprocessing triple-quoted strings
 */
export interface PreprocessResult {
    /**
     * The processed text with triple quotes converted to regular quotes
     */
    text: string;
    
    /**
     * Maps positions in the processed text to positions in the original text
     */
    positionMap: Map<number, number>;
}

/**
 * Processes a text to handle triple-quoted strings ("""...""").
 * Converts them to regular double-quoted strings in a way that maintains
 * position information for diagnostics.
 * 
 * @param text The original text to process
 * @returns An object containing the processed text and a position mapping
 */
export function preprocessTripleQuotedStrings(text: string): PreprocessResult {
    let result = '';
    let pos = 0;
    let inString = false;
    let inTripleString = false;
    
    // Map positions in the processed text to positions in the original text
    const positionMap = new Map<number, number>();
    
    while (pos < text.length) {
        // Store the mapping between current positions
        positionMap.set(result.length, pos);
        
        // Look for triple quotes (""")
        if (pos + 2 < text.length && text.substr(pos, 3) === '"""' && (!inString || inTripleString)) {
            // Toggle triple string state
            inTripleString = !inTripleString;
            
            // If entering a triple string, add open quote
            if (inTripleString) {
                result += '"';
                inString = true;
                pos += 3; // Skip the triple quotes
            } else {
                // If exiting a triple string, add close quote
                result += '"';
                inString = false;
                pos += 3; // Skip the triple quotes
            }
            continue;
        }

        // Handle regular string quotes if not in a triple string
        if (!inTripleString && text[pos] === '"') {
            inString = !inString;
            result += '"';
            pos++;
            continue;
        }

        // Handle escape sequences in regular strings
        if (inString && !inTripleString && text[pos] === '\\') {
            result += '\\';
            pos++;
            if (pos < text.length) {
                result += text[pos];
                pos++;
            }
            continue;
        }

        // Handle newlines in triple strings - convert to escaped newlines for JSON
        if (inTripleString && (text[pos] === '\n' || text[pos] === '\r')) {
            // For \r\n, skip both characters but only add one escaped newline
            if (text[pos] === '\r' && pos + 1 < text.length && text[pos + 1] === '\n') {
                pos += 2;
                result += '\\n';
            } else {
                // For \r or \n individually
                pos++;
                result += '\\n';
            }
            continue;
        }

        // Add the current character to the result
        result += text[pos];
        pos++;
    }
    
    // Add the final position mapping
    positionMap.set(result.length, pos);
    
    return { text: result, positionMap };
}

/**
 * Maps a position in the processed text back to a position in the original text
 * 
 * @param processedPosition Position in the processed text
 * @param positionMap Mapping from processed positions to original positions
 * @returns The corresponding position in the original text
 */
export function mapPositionToOriginal(processedPosition: number, positionMap: Map<number, number>): number {
    // Find the closest position in the map that doesn't exceed our target
    let lastMapping = 0;
    let lastOriginal = 0;
    
    for (const [processed, original] of positionMap.entries()) {
        if (processed > processedPosition) {
            break;
        }
        lastMapping = processed;
        lastOriginal = original;
    }
    
    // Calculate the offset from the last known mapping
    const offset = processedPosition - lastMapping;
    
    // Apply the same offset to the original position
    return lastOriginal + offset;
}