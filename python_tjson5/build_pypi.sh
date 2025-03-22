#!/bin/bash

echo "Publishing Triple-JSON5 Python package to PyPI"
echo "---------------------------------------------"

# Set to 1 to run tests before building
RUN_TESTS=1

# Check if Python is available
if ! command -v python &> /dev/null; then
    echo "Python not found. Please ensure Python is installed and in your PATH."
    exit 1
fi

# Install required build dependencies
echo "Installing build dependencies..."
python -m pip install --upgrade pip
python -m pip install cython wheel setuptools twine build
if [ $? -ne 0 ]; then
    echo "Failed to install build dependencies."
    exit 1
fi

# Clean previous build artifacts
echo "Cleaning previous build files..."
if [ -d "build" ]; then rm -rf build; fi
if [ -d "dist" ]; then rm -rf dist; fi
if [ -d "tjson5.egg-info" ]; then rm -rf tjson5.egg-info; fi
rm -f tjson5parser.cpython*.so

# Generate C code from Cython
echo "Generating C code from Cython..."
python setup.py build_ext --inplace --use-cython
if [ $? -ne 0 ]; then
    echo "Failed to compile Cython code."
    exit 1
fi

# Run tests if enabled
if [ $RUN_TESTS -eq 1 ]; then
    echo
    echo "Running package tests..."
    python tests/run_tests.py
    if [ $? -ne 0 ]; then
        echo
        echo "WARNING: Tests failed. Do you want to continue anyway? (y/n)"
        read -p "> " continue_build
        if [ "$continue_build" != "y" ] && [ "$continue_build" != "Y" ]; then
            echo "Build cancelled due to test failures."
            exit 1
        fi
        echo "Continuing build despite test failures..."
    else
        echo "All tests passed!"
    fi
fi

# Build both wheel and source distribution
echo "Building distributions..."
echo
echo "1. Building wheel package..."
python -m build --wheel
if [ $? -ne 0 ]; then
    echo "Failed to build wheel package."
    exit 1
fi

echo "2. Building source distribution..."
python -m build --sdist
if [ $? -ne 0 ]; then
    echo "Failed to build source distribution."
    exit 1
fi

# Show the built distribution files
echo
echo "Build completed successfully!"
echo
echo "Distribution files created:"
ls -la dist/

# Check the distributions with twine
echo
echo "Checking distributions with twine..."
python -m twine check dist/*

# Confirmation before uploading to PyPI
echo
echo "Ready to upload to PyPI"
echo "----------------------"
echo "This will publish the package to PyPI, making it available for anyone to install."
echo
echo "Before continuing, ensure you have:"
echo "1. Updated the version number in setup.py if needed (current: 0.1.7)"
echo "2. Set up your PyPI API token in your .pypirc file or as environment variables"
echo
echo "To set up your PyPI API token:"
echo "  Create a ~/.pypirc file with:"
echo "      [pypi]"
echo "      username = __token__"
echo "      password = pypi-xxxx...  (your full API token)"
echo
echo "  Or use environment variables:"
echo "      export TWINE_USERNAME=__token__"
echo "      export TWINE_PASSWORD=pypi-xxxx..."
echo

# Main menu
echo "Choose an option:"
echo "1. Upload to PyPI"
echo "2. Cancel and exit"
echo

read -p "Enter option (1-2): " CHOICE

if [ "$CHOICE" = "1" ]; then
    echo
    echo "Uploading to PyPI..."
    python -m twine upload dist/* --verbose
    if [ $? -ne 0 ]; then
        echo
        echo "ERROR: Failed to upload to PyPI."
        echo
        echo "This may be caused by:"
        echo "1. Authentication failure - Check your .pypirc file or environment variables"
        echo "2. Package name 'tjson5' may already be taken on PyPI"
        echo "3. Version number may already exist - try incrementing the version in setup.py"
        echo
        exit 1
    fi

    echo
    echo "================================================"
    echo "Successfully published tjson5 to PyPI!"
    echo
    echo "Users can now install your package with:"
    echo "pip install tjson5"
    echo "================================================"
elif [ "$CHOICE" = "2" ]; then
    echo "Publication process cancelled."
else
    echo "Invalid selection. Please select 1 or 2."
    exit 1
fi