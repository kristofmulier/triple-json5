@echo off
echo Building Triple-JSON5 Python package for Windows

:: Check if Python is available
where python >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo Python not found. Please ensure Python is installed and in your PATH.
    exit /b 1
)

:: Install required build dependencies
echo Installing build dependencies...
python -m pip install --upgrade pip
python -m pip install cython wheel setuptools

:: Clean previous build artifacts
echo Cleaning previous build files...
if exist build rmdir /s /q build
if exist dist rmdir /s /q dist
if exist tjson5.egg-info rmdir /s /q tjson5.egg-info
if exist tjson5parser.cpython*.pyd del /f tjson5parser.cpython*.pyd

:: Generate C code from Cython
echo Generating C code from Cython...
python setup.py build_ext --inplace --use-cython
if %ERRORLEVEL% neq 0 (
    echo Failed to compile Cython code.
    exit /b 1
)

:: Build wheel package
echo Building wheel package...
python setup.py bdist_wheel
if %ERRORLEVEL% neq 0 (
    echo Failed to build wheel package.
    exit /b 1
)

:: Show the built wheel file
echo.
echo Build completed successfully!
echo.
echo Wheel file created:
dir /b dist\*.whl

echo.
echo To install the package, run:
echo pip install dist\[wheel-file-name].whl
echo.
echo To publish to PyPI, run:
echo python -m twine upload dist\*.whl

exit /b 0

:: After running this script, you'll find the wheel file in the dist directory,
:: which you can install with pip.
:: Then you can import the tjson5parser in Python like this:
:: 
::     import tjson5parser
::     sample = ''' ... '''
::     data = tjson5parser.parse(sample)
::     print(data)