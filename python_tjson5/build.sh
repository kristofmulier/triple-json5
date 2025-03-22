#!/bin/bash

echo "Triple-JSON5 Python Package Builder for Linux"
echo "============================================="

# Set to 1 to run tests before building
RUN_TESTS=1

# Check if Python is available
if ! command -v python3 &> /dev/null; then
    echo "Python3 not found. Please ensure Python 3 is installed."
    exit 1
fi

# Install required build dependencies
echo "Installing build dependencies..."
python3 -m pip install --upgrade pip
python3 -m pip install cython wheel setuptools twine build
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
python3 setup.py build_ext --inplace --use-cython
if [ $? -ne 0 ]; then
    echo "Failed to compile Cython code."
    exit 1
fi

# Run tests if enabled
if [ $RUN_TESTS -eq 1 ]; then
    echo
    echo "Running package tests..."
    python3 tests/run_tests.py
    TEST_RESULT=$?
    
    if [ $TEST_RESULT -ne 0 ]; then
        echo
        echo "WARNING: Tests failed. Do you want to continue anyway? (y/n)"
        read -p "> " continue_build
        if [ "$continue_build" != "y" ] && [ "$continue_build" != "Y" ]; then
            echo "Build cancelled due to test failures."
            exit 1
        fi
        echo "Continuing build despite test failures..."
    else
        echo
        echo "All tests PASSED!"
        echo "Continue build [Y/N]? "
        read -p "> " continue_build
        if [ "$continue_build" != "y" ] && [ "$continue_build" != "Y" ]; then
            echo "Build cancelled by user."
            exit 0
        fi
        echo "Continuing with build process..."
    fi
fi

# Build distributions
echo "Building distributions..."
echo
echo "1. Building wheel package..."
python3 -m build --wheel
if [ $? -ne 0 ]; then
    echo "Failed to build wheel package."
    exit 1
fi

echo "2. Building source distribution..."
python3 -m build --sdist
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
python3 -m twine check dist/*

# Ask user what to do next
echo
echo "What would you like to do next?"
echo "1. Install locally"
echo "2. Publish to PyPI"
echo "3. Exit"
echo

read -p "Enter option (1-3): " NEXT_STEP

case $NEXT_STEP in
    1)
        echo
        echo "Installing package locally..."
        python3 -m pip install dist/*.whl --force-reinstall
        if [ $? -eq 0 ]; then
            echo "Package installed successfully!"
            echo
            echo "You can now import the package in Python:"
            echo ">>> import tjson5"
            echo ">>> data = tjson5.parse('{\"key\": \"value\"}')"
        else
            echo "Failed to install package."
            exit 1
        fi
        ;;
    
    2)
        echo
        echo "Ready to publish to PyPI"
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
        
        echo "Proceed with PyPI upload? (y/n)"
        read -p "> " PUBLISH_CHOICE
        
        if [ "$PUBLISH_CHOICE" = "y" ] || [ "$PUBLISH_CHOICE" = "Y" ]; then
            echo
            echo "Uploading to PyPI..."
            python3 -m twine upload dist/* --verbose
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
        else
            echo "PyPI upload cancelled."
        fi
        ;;
        
    3)
        echo "Exiting build script."
        ;;
        
    *)
        echo "Invalid option. Exiting."
        exit 1
        ;;
esac

echo
echo "Build script completed."