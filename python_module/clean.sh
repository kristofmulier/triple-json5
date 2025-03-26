#!/bin/bash

echo "Cleaning Triple-JSON5 Python package build artifacts"
echo "--------------------------------------------------"

echo "Removing build directory..."
rm -rf build

echo "Removing dist directory..."
rm -rf dist

echo "Removing egg-info directory..."
rm -rf tjson5.egg-info

echo "Removing compiled Python files..."
find . -type d -name "__pycache__" -exec rm -rf {} +
find . -type f -name "*.pyc" -delete
find . -type f -name "*.pyo" -delete

echo "Removing generated C extensions..."
rm -f tjson5parser.cpython*.so
rm -f tjson5parser.cpython*.pyd
rm -f tjson5parser.cp*-win*.pyd
rm -f tjson5parser.cp*-*-linux-gnu.so

echo "Removing Cython-generated C file..."
rm -f tjson5parser.c

echo ""
echo "Build artifacts successfully cleaned."
echo ""

exit 0