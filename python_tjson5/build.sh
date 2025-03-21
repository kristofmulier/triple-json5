#!/bin/bash
set -e  # Exit on error

echo "Building Triple-JSON5 Python package for Linux"

# Check if Python is available
if ! command -v python3 &> /dev/null; then
    echo "Python3 not found. Please ensure Python 3 is installed."
    exit 1
fi

# Install required build dependencies
echo "Installing build dependencies..."
python3 -m pip install --upgrade pip
python3 -m pip install cython wheel setuptools

# Clean previous build artifacts
echo "Cleaning previous build files..."
rm -rf build dist tjson5.egg-info
rm -f tjson5parser.cpython*.so

# Generate C code from Cython
echo "Generating C code from Cython..."
python3 setup.py build_ext --inplace --use-cython

# Build wheel package
echo "Building wheel package..."
python3 setup.py bdist_wheel

# Show the built wheel file
echo ""
echo "Build completed successfully!"
echo ""
echo "Wheel file created:"
ls -la dist/*.whl

echo ""
echo "To install the package, run:"
echo "pip install dist/[wheel-file-name].whl"
echo ""
echo "To publish to PyPI, run:"
echo "python -m twine upload dist/*.whl"
echo ""
echo "To use in a Python project:"
echo "1. Install the wheel file: pip install dist/[wheel-file-name].whl"
echo "2. Import in your Python code: import tjson5parser"
echo "3. Parse TJSON5 strings: data = tjson5parser.parse(tjson5_string)"
echo "4. Load TJSON5 files: data = tjson5parser.load(open('file.tjson5'))"

exit 0