#!/bin/bash

echo "Triple-JSON5 Python Package Builder"
echo "================================="

# Process arguments
if [ "$1" == "--help" ] || [ "$1" == "-h" ]; then
    echo "Build script for the tjson5 Python package"
    echo
    echo "Usage:"
    echo "  ./build.sh [options]"
    echo
    echo "Options:"
    echo "  --yes, -y       Automatically answer yes to all prompts"
    echo "  --no-test       Skip running the tests"
    echo "  --install       Install the package locally after building"
    echo "  --publish       Publish the package to PyPI after building"
    echo "  --version       Show version information and exit"
    echo "  --help, -h      Show this help message and exit"
    echo
    echo "Examples:"
    echo "  ./build.sh                  Interactive build process"
    echo "  ./build.sh --yes --install  Build and install with no prompts"
    echo "  ./build.sh --publish        Build and publish to PyPI"
    echo
    exit 0
fi

if [ "$1" == "--version" ]; then
    python3 build.py --version
    exit 0
fi

# Make sure script has executable permissions
chmod +x build.py

# Run the Python build script with all arguments passed through
python3 build.py "$@"