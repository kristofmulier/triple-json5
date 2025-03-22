# cython: language_level=3
"""
Triple-JSON5 parser implemented in Cython - Fixed version.
This parser supports JSON5 with the addition of triple-quoted strings
and special number formats (hex: 0x, binary: 0b).
"""
import re
import json
import os
from cpython.ref cimport PyObject
from libc.stdlib cimport malloc, free

# Define exception class for parse errors
class TJSON5ParseError(Exception):
    """Exception raised for Triple-JSON5 parsing errors."""
    pass

# Regular expressions for number preprocessing
cdef object HEX_REGEX = re.compile(r'\b0x([0-9A-Fa-f]+)\b')
cdef object BINARY_REGEX = re.compile(r'\b0b([01]+)\b')
cdef object COMMENT_LINE_REGEX = re.compile(r'^\s*//.*$', re.MULTILINE)
cdef object FIRST_JSON_CHAR_REGEX = re.compile(r'[\[\{]')

# Import json5 package if available
try:
    import json5
    HAS_JSON5 = True
except ImportError:
    HAS_JSON5 = False

# Convert triple-quoted strings to regular quoted strings
cdef str process_triple_quotes(str text):
    """
    Process triple-quoted strings by converting them to regular quoted strings.
    This is a simpler implementation focusing on correctness first.
    """
    cdef list result_parts = []
    cdef int pos = 0
    cdef int length = len(text)
    cdef bint in_string = False
    cdef bint in_triple_string = False
    cdef str current_part = ""
    
    while pos < length:
        # Check for triple quotes
        if pos + 2 < length and text[pos:pos+3] == '"""':
            if in_triple_string:  # Closing triple quote
                result_parts.append(current_part.replace('"', '\\"').replace('\n', '\\n'))
                current_part = ""
                result_parts.append('"')  # Close with single quote
                in_triple_string = False
                pos += 3
            elif not in_string:  # Opening triple quote
                result_parts.append('"')  # Open with single quote
                in_triple_string = True
                pos += 3
            else:  # Triple quote inside a regular string (unlikely)
                current_part += text[pos]
                pos += 1
        elif in_triple_string:  # Inside triple string, collect content
            current_part += text[pos]
            pos += 1
        elif pos < length and text[pos] == '"' and not in_triple_string:
            # Toggle regular string state if not in triple string
            in_string = not in_string
            result_parts.append('"')
            pos += 1
        else:  # Regular character
            result_parts.append(text[pos])
            pos += 1
    
    return "".join(result_parts)

# Convert hex and binary literals to decimal
cdef str process_number_formats(str text):
    """Convert hex and binary literals to decimal."""
    # Replace hex numbers
    text = HEX_REGEX.sub(lambda m: str(int(m.group(1), 16)), text)
    # Replace binary numbers
    text = BINARY_REGEX.sub(lambda m: str(int(m.group(1), 2)), text)
    return text

cdef str strip_leading_comments(str text):
    """
    Strip comments at the beginning of the file before the first { or [
    """
    # Find the first opening brace or bracket
    match = FIRST_JSON_CHAR_REGEX.search(text)
    if match:
        start_pos = match.start()
        if start_pos > 0:
            # Get the part of the text before the first JSON character
            prefix = text[:start_pos]
            # If it's only comments and whitespace, remove it
            if re.match(r'^(\s*((//[^\n]*\n)|(\/\*[\s\S]*?\*\/)))*\s*$', prefix):
                return text[start_pos:]
    return text

# Process JSON5 unquoted keys and other features
cdef str process_json5_features(str text):
    """
    Process JSON5 features like unquoted keys, comments, and trailing commas.
    """
    # Handle unquoted keys - convert objects like {key: value} to {"key": value}
    processed = re.sub(r'(?<!["\'])\b([a-zA-Z_][a-zA-Z0-9_]*)\s*:', r'"\1":', text)
    
    # Remove comments (both // and /* */)
    processed = re.sub(r'//.*$', '', processed, flags=re.MULTILINE)
    processed = re.sub(r'/\*[\s\S]*?\*/', '', processed)
    
    # Handle trailing commas in objects and arrays
    processed = re.sub(r',\s*\}', '}', processed)
    processed = re.sub(r',\s*\]', ']', processed)
    
    return processed

cpdef parse(str text, bint strip_comments=True):
    """
    Parse a Triple-JSON5 string and return the corresponding Python object.
    
    Parameters:
    - text: The Triple-JSON5 string to parse
    - strip_comments: Whether to strip comments (default True)
    
    Returns:
    - A Python object (dict, list, str, int, float, bool, None)
    
    Raises:
    - TJSON5ParseError if the text is invalid
    """
    # Skip invalid or empty input
    if not text or not text.strip():
        raise TJSON5ParseError("Empty or invalid input")
        
    # First, check if we have the json5 package available - if so, use it
    if HAS_JSON5:
        try:
            # Strip any leading file comments before the JSON structure
            if text.lstrip().startswith('//'):
                # Direct approach with json5
                return json5.loads(text)
            else:
                # Process triple quotes first
                processed_text = process_triple_quotes(text)
                # Process hex and binary literals
                processed_text = process_number_formats(processed_text)
                # Parse with json5
                return json5.loads(processed_text)
        except Exception as e:
            # If json5 fails, continue with our implementation
            pass
            
    # Try our fallback implementation
    try:
        # Check if the file has comments before the actual JSON content
        has_leading_comments = text.lstrip().startswith('//')
        
        if has_leading_comments:
            # Strip leading comments before the first { or [
            text = strip_leading_comments(text)
            
        # Step 1: Process triple-quoted strings
        processed_text = process_triple_quotes(text)
        
        # Step 2: Process hex and binary literals
        processed_text = process_number_formats(processed_text)
        
        # Step 3: Use a fallback approach - let's use our custom JSON5 processor
        try:
            # Process JSON5 features
            final_text = process_json5_features(processed_text)
            
            # Parse with standard JSON
            return json.loads(final_text)
        except json.JSONDecodeError as e:
            # If direct parsing fails, try a more comprehensive approach
            import tempfile
            
            # Write the processed text to a temporary file
            with tempfile.NamedTemporaryFile(mode='w+', suffix='.json5', delete=False) as tf:
                temp_filename = tf.name
                tf.write(processed_text)
            
            try:
                # First, handle unquoted keys with explicit regex
                with open(temp_filename, 'r', encoding='utf-8') as f:
                    content = f.read()
                    
                # Create a manual JSON5 processor
                # Replace unquoted keys with quoted keys
                fixed_content = re.sub(r'([{,]\s*)([a-zA-Z_][a-zA-Z0-9_]*)\s*:', r'\1"\2":', content)
                
                # Remove comments
                fixed_content = re.sub(r'//.*?$', '', fixed_content, flags=re.MULTILINE)
                fixed_content = re.sub(r'/\*.*?\*/', '', fixed_content, flags=re.DOTALL)
                
                # Remove trailing commas in objects and arrays
                fixed_content = re.sub(r',\s*\}', '}', fixed_content)
                fixed_content = re.sub(r',\s*\]', ']', fixed_content)
                
                # Write the fixed content back to the file
                with open(temp_filename, 'w', encoding='utf-8') as f:
                    f.write(fixed_content)
                    
                # Now try to parse with standard JSON
                with open(temp_filename, 'r', encoding='utf-8') as f:
                    try:
                        return json.load(f)
                    except json.JSONDecodeError as je:
                        raise TJSON5ParseError(f"Failed to parse Triple-JSON5: {str(je)}")
            finally:
                # Clean up temporary file
                try:
                    os.unlink(temp_filename)
                except:
                    pass
                    
    except Exception as e:
        if not isinstance(e, TJSON5ParseError):
            raise TJSON5ParseError(f"Parsing error: {str(e)}")
        raise

cpdef loads(str text, bint strip_comments=True):
    """Alias for parse to match Python's json module API."""
    return parse(text, strip_comments)

cpdef load(file_obj, bint strip_comments=True):
    """Parse a file object containing Triple-JSON5."""
    return parse(file_obj.read(), strip_comments)

cpdef dump(obj, file_obj, indent=None):
    """Serialize obj to a file as JSON."""
    json.dump(obj, file_obj, indent=indent)

cpdef dumps(obj, indent=None):
    """Serialize obj to a JSON string."""
    return json.dumps(obj, indent=indent)

# Export preprocessing functions for testing
cpdef preprocessTripleQuotedStrings(str text):
    """Process triple-quoted strings for testing."""
    return process_triple_quotes(text)

cpdef preprocessHexBinary(str text):
    """Process hex and binary literals for testing."""
    return process_number_formats(text)