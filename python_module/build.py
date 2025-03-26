#!/usr/bin/env python3
"""
Triple-JSON5 Python Package Builder

This script automates the process of building, testing, and publishing the
tjson5 package to PyPI. It handles all steps of the build process including:
- Installing build dependencies
- Running tests
- Building distributions
- Local installation
- Publishing to PyPI

To run:
    python build.py
"""

import os
import sys
import shutil
import subprocess
import platform
import tempfile
import argparse
from pathlib import Path

# Check if we're running in Windows
IS_WINDOWS = platform.system() == 'Windows'
NO_COLOR = IS_WINDOWS and not os.environ.get('TERM')

# Color output for terminal
class Colors:
    HEADER = '\033[95m'
    BLUE = '\033[94m'
    GREEN = '\033[92m'
    YELLOW = '\033[93m'
    RED = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'

# Symbols for success/error/warning
class Symbols:
    CHECK = '✓'
    CROSS = '✗'
    WARNING = '!'

# Detect if running in Windows command prompt (not supporting ANSI colors/unicode)
if NO_COLOR:
    # Disable colors if in Windows CMD
    for attr in dir(Colors):
        if not attr.startswith('__'):
            setattr(Colors, attr, '')
    
    # Use ASCII symbols for Windows
    Symbols.CHECK = 'PASS'
    Symbols.CROSS = 'FAIL'
    Symbols.WARNING = '!'

def print_header(text):
    """Print a formatted header."""
    print(f"\n{Colors.HEADER}{Colors.BOLD}== {text} =={Colors.ENDC}")

def print_success(text):
    """Print a success message."""
    print(f"{Colors.GREEN}{Symbols.CHECK} {text}{Colors.ENDC}")

def print_error(text):
    """Print an error message."""
    print(f"{Colors.RED}{Symbols.CROSS} {text}{Colors.ENDC}")

def print_warning(text):
    """Print a warning message."""
    print(f"{Colors.YELLOW}{Symbols.WARNING} {text}{Colors.ENDC}")

def print_info(text):
    """Print an informational message."""
    print(f"{Colors.BLUE}> {text}{Colors.ENDC}")

def run_command(cmd, check=True, shell=False):
    """Run a command and return the result."""
    print_info(f"Running: {' '.join(cmd) if isinstance(cmd, list) else cmd}")
    
    try:
        if shell:
            result = subprocess.run(cmd, check=check, shell=True, text=True, capture_output=True)
        else:
            result = subprocess.run(cmd, check=check, text=True, capture_output=True)
        
        if result.stdout:
            # Print condensed output for successful commands
            lines = result.stdout.splitlines()
            if len(lines) > 20:
                for line in lines[:10]:
                    print(line)
                print("...")
                for line in lines[-5:]:
                    print(line)
            else:
                print(result.stdout)
                
        if result.stderr and not result.returncode == 0:
            print_error("Command produced errors:")
            print(result.stderr)
            
        return result
    except subprocess.CalledProcessError as e:
        print_error(f"Command failed with exit code {e.returncode}")
        if e.stdout:
            print(e.stdout)
        if e.stderr:
            print(e.stderr)
        if check:
            raise
        return e

def confirm(prompt, default=True, auto_yes=False):
    """
    Ask for user confirmation.
    
    Args:
        prompt: The prompt to display
        default: Default value (True=yes, False=no) if running non-interactively
        auto_yes: Whether to automatically return True without prompting
        
    Returns:
        bool: True if user confirms, False otherwise
    """
    if auto_yes:
        print(f"{prompt} (y/n): y (auto)")
        return True
        
    try:
        while True:
            response = input(f"{prompt} (y/n): ").lower().strip()
            if response in ('y', 'yes'):
                return True
            elif response in ('n', 'no'):
                return False
            elif not response:  # Empty response
                print(f"Using default: {'yes' if default else 'no'}")
                return default
            else:
                print("Please enter 'y' or 'n'")
    except (EOFError, KeyboardInterrupt):
        # Handle non-interactive environments or interrupts
        print(f"\nNo input provided, using default: {'yes' if default else 'no'}")
        return default

def check_python():
    """Check if Python is available and get version."""
    print_header("Checking Python")
    try:
        result = run_command(['python', '--version'])
        print_success(f"Python is available: {result.stdout.strip()}")
        return True
    except Exception as e:
        print_error(f"Python check failed: {e}")
        return False

def install_dependencies():
    """Install required build dependencies."""
    print_header("Installing Build Dependencies")
    
    # Upgrade pip first
    run_command(['python', '-m', 'pip', 'install', '--upgrade', 'pip'])
    
    # Install build dependencies
    dependencies = ['cython', 'wheel', 'setuptools', 'twine', 'build']
    run_command(['python', '-m', 'pip', 'install'] + dependencies)
    print_success("Dependencies installed successfully")

def clean_artifacts():
    """Clean previous build artifacts."""
    print_header("Cleaning Build Artifacts")
    
    # Directories to clean
    dirs_to_clean = ['build', 'dist', 'tjson5.egg-info']
    
    for dir_name in dirs_to_clean:
        if os.path.exists(dir_name):
            print_info(f"Removing directory: {dir_name}")
            shutil.rmtree(dir_name)
    
    # Remove compiled extension files
    if IS_WINDOWS:
        # Windows extension files have .pyd suffix
        for ext_file in Path('.').glob('tjson5parser.cp*.pyd'):
            print_info(f"Removing file: {ext_file}")
            if os.path.exists(ext_file):
                os.unlink(ext_file)
    else:
        # Linux extension files have .so suffix
        for ext_file in Path('.').glob('tjson5parser.cpython*.so'):
            print_info(f"Removing file: {ext_file}")
            if os.path.exists(ext_file):
                os.unlink(ext_file)
        
    print_success("Build artifacts cleaned")

def build_extension():
    """Build the Cython extension."""
    print_header("Building Cython Extension")
    
    try:
        # Generate C code from Cython
        run_command(['python', 'setup.py', 'build_ext', '--inplace', '--use-cython'])
        print_success("Cython extension built successfully")
        return True
    except Exception as e:
        print_error(f"Failed to build Cython extension: {e}")
        return False

def run_tests(auto_yes=False):
    """Run the package tests."""
    print_header("Running Tests")
    
    try:
        # Run tests
        result = run_command(['python', 'tests/run_tests.py'], check=False)
        
        if result.returncode == 0:
            print_success("All tests PASSED!")
            
            if not confirm("Continue with build process", default=True, auto_yes=auto_yes):
                print_info("Build process cancelled by user")
                return False
                
            return True
        else:
            print_error("Tests FAILED!")
            
            if not confirm("Tests failed. Do you want to continue anyway", default=False, auto_yes=auto_yes):
                print_info("Build process cancelled due to test failures")
                return False
                
            print_warning("Continuing build process despite test failures")
            return True
            
    except Exception as e:
        print_error(f"Error running tests: {e}")
        
        if not confirm("Error running tests. Do you want to continue anyway", default=False, auto_yes=auto_yes):
            print_info("Build process cancelled due to test errors")
            return False
            
        print_warning("Continuing build process despite test errors")
        return True

def build_distributions():
    """Build both wheel and source distributions."""
    print_header("Building Distributions")
    
    try:
        # Build wheel
        print_info("Building wheel package...")
        run_command(['python', 'setup.py', 'bdist_wheel'])
        
        # Build source distribution
        print_info("Building source distribution...")
        run_command(['python', 'setup.py', 'sdist'])
        
        # List distributions
        dist_files = list(Path('dist').glob('*'))
        if dist_files:
            print_success("Distribution files created:")
            for file in dist_files:
                print(f"  - {file}")
                
            # Check distributions with twine
            print_info("Checking distributions with twine...")
            if IS_WINDOWS:
                # On Windows, use glob to expand the wildcards
                dist_files = [str(f) for f in Path('dist').glob('*')]
                run_command(['python', '-m', 'twine', 'check'] + dist_files)
            else:
                # On Unix-like systems, shell expansion works
                run_command(['python', '-m', 'twine', 'check', 'dist/*'])
            
            return True
        else:
            print_error("No distribution files were created")
            return False
            
    except Exception as e:
        print_error(f"Failed to build distributions: {e}")
        return False

def install_locally():
    """Install the package locally."""
    print_header("Installing Package Locally")
    
    try:
        # Find the wheel file
        wheel_files = list(Path('dist').glob('*.whl'))
        if not wheel_files:
            print_error("No wheel files found in dist directory")
            return False
            
        # Install wheel (use the first wheel file found)
        wheel_path = str(wheel_files[0])
        print_info(f"Installing wheel: {wheel_path}")
        run_command(['python', '-m', 'pip', 'install', wheel_path, '--force-reinstall'])
        
        # Test import
        test_script = """
import tjson5
print(f"tjson5 version: {tjson5.__version__}")
data = tjson5.parse('{"test": "success"}')
print(f"Parsed data: {data}")
"""
        # Create temporary file
        with tempfile.NamedTemporaryFile('w', suffix='.py', delete=False) as f:
            f.write(test_script)
            temp_script = f.name
            
        try:
            # Run test script
            result = run_command(['python', temp_script])
            if result.returncode == 0:
                print_success("Package installed and working correctly!")
                return True
            else:
                print_error("Package installed but import test failed")
                return False
        finally:
            # Clean up temporary file
            os.unlink(temp_script)
            
    except Exception as e:
        print_error(f"Failed to install package locally: {e}")
        return False

def publish_to_pypi(auto_yes=False):
    """Publish the package to PyPI."""
    print_header("Publishing to PyPI")
    
    # Check version
    with open('setup.py', 'r') as f:
        setup_content = f.read()
        import re
        version_match = re.search(r'version=[\'"](.*?)[\'"]', setup_content)
        version = version_match.group(1) if version_match else "unknown"
    
    print_info(f"Current package version: {version}")
    print_warning("Before publishing, ensure you have:")
    print("1. Updated the version number in setup.py if needed")
    print("2. Set up your PyPI API token in .pypirc or as environment variables:")
    print("   - For .pypirc: username = __token__, password = your-token")
    print("   - For env vars: TWINE_USERNAME=__token__ TWINE_PASSWORD=your-token")
    
    if not confirm("Ready to publish to PyPI", default=False, auto_yes=auto_yes):
        print_info("Publication cancelled")
        return False
    
    try:
        # Upload to PyPI
        if IS_WINDOWS:
            # On Windows, use glob to expand the wildcards
            dist_files = [str(f) for f in Path('dist').glob('*')]
            run_command(['python', '-m', 'twine', 'upload'] + dist_files + ['--verbose'])
        else:
            # On Unix-like systems, shell expansion works
            run_command(['python', '-m', 'twine', 'upload', 'dist/*', '--verbose'])
        
        print_success(f"""
============================================================
Successfully published tjson5 {version} to PyPI!

Users can now install your package with:
    pip install tjson5
============================================================
""")
        return True
        
    except Exception as e:
        print_error(f"Failed to publish to PyPI: {e}")
        print_warning("This might be caused by:")
        print("1. Authentication failure - Check your PyPI credentials")
        print("2. Package name 'tjson5' might already be taken")
        print("3. Version number might already exist - try incrementing version")
        return False

def parse_args():
    """Parse command-line arguments."""
    parser = argparse.ArgumentParser(description="Triple-JSON5 Python Package Builder")
    parser.add_argument('--yes', '-y', action='store_true', 
                      help='Automatically answer yes to all prompts')
    parser.add_argument('--no-test', action='store_true', 
                      help='Skip running the tests')
    parser.add_argument('--install', action='store_true',
                      help='Install the package locally after building')
    parser.add_argument('--publish', action='store_true',
                      help='Publish the package to PyPI after building')
    parser.add_argument('--version', action='store_true',
                      help='Show version information and exit')
    
    return parser.parse_args()

def main():
    """Main build process."""
    # Parse command-line arguments
    args = parse_args()
    
    # Show version information if requested
    if args.version:
        # Get version from setup.py
        with open('setup.py', 'r') as f:
            setup_content = f.read()
            import re
            version_match = re.search(r'version=[\'"](.*?)[\'"]', setup_content)
            version = version_match.group(1) if version_match else "unknown"
        print(f"Triple-JSON5 Python Package Builder (version {version})")
        sys.exit(0)
        
    print_header("Triple-JSON5 Python Package Builder")
    print("This script will build, test, and optionally publish the tjson5 package")
    
    # Check Python
    if not check_python():
        sys.exit(1)
    
    # Install dependencies
    install_dependencies()
    
    # Clean artifacts
    clean_artifacts()
    
    # Build extension
    if not build_extension():
        if not confirm("Failed to build extension. Continue anyway", default=False, auto_yes=args.yes):
            sys.exit(1)
    
    # Run tests (unless skipped)
    if not args.no_test:
        if not run_tests(auto_yes=args.yes):
            sys.exit(0)  # User cancelled
    else:
        print_warning("Skipping tests as requested")
    
    # Build distributions
    if not build_distributions():
        if not confirm("Failed to build distributions. Continue anyway", default=False, auto_yes=args.yes):
            sys.exit(1)
    
    # Handle automatic actions based on arguments
    if args.install:
        install_locally()
        if args.publish:
            publish_to_pypi(auto_yes=args.yes)
    elif args.publish:
        publish_to_pypi(auto_yes=args.yes)
    elif not (args.yes or args.no_test): # Only prompt if not in automated mode
        # Ask what to do next
        print_header("Build Completed")
        print("What would you like to do next?")
        print("1. Install locally")
        print("2. Publish to PyPI")
        print("3. Exit")
        
        try:
            while True:
                try:
                    choice = int(input("Enter option (1-3): ").strip())
                    if choice in [1, 2, 3]:
                        break
                    else:
                        print("Please enter a number between 1 and 3")
                except ValueError:
                    print("Please enter a number")
            
            if choice == 1:
                install_locally()
            elif choice == 2:
                publish_to_pypi(auto_yes=args.yes)
            else:
                print_info("Exiting build script")
        except (EOFError, KeyboardInterrupt):
            print("\nNo input provided, exiting")
    
    print_success("Build script completed successfully")

if __name__ == "__main__":
    main()