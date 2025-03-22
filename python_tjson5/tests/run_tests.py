#!/usr/bin/env python3
"""
Test runner for tjson5 package
Runs all tests to verify the package functionality
"""
import sys
import os
import subprocess
import unittest
import time

def run_test(test_script, description):
    """Run a test script and return True if it passes"""
    print(f"\n{description}")
    print("=" * len(description))
    
    start_time = time.time()
    try:
        result = subprocess.run([sys.executable, test_script], capture_output=True, text=True)
        end_time = time.time()
        
        if result.returncode == 0:
            print(f"{description} PASSED in {end_time - start_time:.2f}s")
            return True
        else:
            print(f"{description} FAILED in {end_time - start_time:.2f}s")
            print("\nOutput:")
            print(result.stdout)
            print("\nErrors:")
            print(result.stderr)
            return False
    except Exception as e:
        print(f"Error running {test_script}: {e}")
        return False

def main():
    """Run all tests"""
    print("TJSON5 Package Test Runner")
    print("=========================")
    print(f"Running tests from: {os.path.abspath('.')}")
    
    # Get current directory (should be tests/)
    current_dir = os.path.dirname(os.path.abspath(__file__))
    
    # List of tests to run
    tests = [
        (os.path.join(current_dir, "test_01.py"), "Unit Tests"),
        (os.path.join(current_dir, "test_02.py"), "Simple Usage Example"),
        (os.path.join(current_dir, "test_parse_large_file.py"), "Large File Parser Test"),
        (os.path.join(current_dir, "verify_package.py"), "Package Verification")
    ]
    
    # Track results
    results = []
    
    # Run each test
    for test_script, description in tests:
        results.append(run_test(test_script, description))
    
    # Print summary
    print("\nTest Summary")
    print("===========")
    for i, (test_script, description) in enumerate(tests):
        status = "PASS" if results[i] else "FAIL"
        print(f"{status} - {description} ({test_script})")
    
    # Overall result
    if all(results):
        print("\nAll tests PASSED!")
        return 0
    else:
        print(f"\n{results.count(False)} test(s) FAILED!")
        return 1

if __name__ == "__main__":
    sys.exit(main())