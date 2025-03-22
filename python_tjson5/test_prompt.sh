#!/bin/bash

echo "Testing Y/N prompt handling"

# Simulate successful test run
echo "All tests PASSED!"
echo "Continue build [Y/N]? "
read -p "> " continue_build

if [ "$continue_build" != "y" ] && [ "$continue_build" != "Y" ]; then
    echo "Build cancelled by user."
    exit 0
fi

echo "Continuing with build process..."
echo "Build completed successfully."