@echo off
setlocal enabledelayedexpansion

echo Publishing Triple-JSON5 Python package to PyPI
echo ---------------------------------------------

:: Check if Python is available
where python >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo Python not found. Please ensure Python is installed and in your PATH.
    exit /b 1
)

:: Install required build dependencies
echo Installing build dependencies...
python -m pip install --upgrade pip
python -m pip install cython wheel setuptools twine build
if %ERRORLEVEL% neq 0 (
    echo Failed to install build dependencies.
    exit /b 1
)

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

:: Build both wheel (for Windows) and source distribution (for Linux/other platforms)
echo Building distributions...
echo.
echo 1. Building wheel package (for Windows)...
python setup.py bdist_wheel
if %ERRORLEVEL% neq 0 (
    echo Failed to build wheel package.
    exit /b 1
)

echo 2. Building source distribution (for Linux and other platforms)...
python setup.py sdist
if %ERRORLEVEL% neq 0 (
    echo Failed to build source distribution.
    exit /b 1
)

:: Show the built distribution files
echo.
echo Build completed successfully!
echo.
echo Distribution files created:
dir /b dist\*

:: Check the distributions with twine
echo.
echo Checking distributions with twine...
python -m twine check dist/*

:: Confirmation before uploading to PyPI
echo.
echo Ready to upload to PyPI
echo ----------------------
echo This will publish the package to PyPI, making it available for anyone to install.
echo.
echo Before continuing, ensure you have:
echo 1. Updated the version number in setup.py if needed (current: 0.1.0)
echo 2. Set up your PyPI credentials in one of these ways:
echo.
echo    Option 1: Create a .pypirc file at C:\Users\krist\.pypirc with:
echo        [pypi]
echo        username = kmulier
echo        password = your_password
echo.
echo        [testpypi]
echo        username = kmulier
echo        password = your_password
echo.
echo    Option 2: Use environment variables:
echo        set TWINE_USERNAME=kmulier
echo        set TWINE_PASSWORD=your_password
echo.
echo    For better security, you can use API tokens from:
echo    https://pypi.org/manage/account/token/
echo.

:: Main menu
echo Choose an option:
echo 1. Upload to Test PyPI only
echo 2. Upload to main PyPI only
echo 3. Upload to Test PyPI, then main PyPI
echo 4. Cancel and exit
echo.

set /p CHOICE="Enter option (1-4): "

if "%CHOICE%"=="1" goto TESTPYPI_ONLY
if "%CHOICE%"=="2" goto PYPI_ONLY
if "%CHOICE%"=="3" goto TESTPYPI_THEN_PYPI
if "%CHOICE%"=="4" goto EXIT_SCRIPT

echo Invalid selection. Please select 1-4.
exit /b 1

:TESTPYPI_ONLY
echo.
echo Uploading to Test PyPI...
python -m twine upload --repository testpypi dist/* --verbose
if %ERRORLEVEL% neq 0 (
    echo.
    echo ERROR: Failed to upload to Test PyPI.
    echo.
    echo This may be caused by:
    echo 1. Authentication failure - Check your .pypirc file or environment variables
    echo 2. Package name 'tjson5' may already be taken on TestPyPI
    echo 3. Version 0.1.0 may already exist - try incrementing the version in setup.py
    echo.
    exit /b 1
)
echo.
echo Successfully uploaded to Test PyPI!
echo To test installation from Test PyPI:
echo pip install --index-url https://test.pypi.org/simple/ tjson5
goto EXIT_SUCCESS

:PYPI_ONLY
echo.
echo Uploading to PyPI...
python -m twine upload dist/* --verbose
if %ERRORLEVEL% neq 0 (
    echo.
    echo ERROR: Failed to upload to PyPI.
    echo.
    echo This may be caused by:
    echo 1. Authentication failure - Check your .pypirc file or environment variables
    echo 2. Package name 'tjson5' may already be taken on PyPI
    echo 3. Version 0.1.0 may already exist - try incrementing the version in setup.py
    echo.
    exit /b 1
)
goto EXIT_SUCCESS

:TESTPYPI_THEN_PYPI
echo.
echo Uploading to Test PyPI first...
python -m twine upload --repository testpypi dist/* --verbose
if %ERRORLEVEL% neq 0 (
    echo.
    echo ERROR: Failed to upload to Test PyPI.
    echo.
    echo This may be caused by:
    echo 1. Authentication failure - Check your .pypirc file or environment variables
    echo 2. Package name 'tjson5' may already be taken on TestPyPI
    echo 3. Version 0.1.0 may already exist - try incrementing the version in setup.py
    echo.
    echo Skipping upload to main PyPI due to Test PyPI failure.
    exit /b 1
)
echo.
echo Successfully uploaded to Test PyPI!
echo.
echo Now uploading to main PyPI...
python -m twine upload dist/* --verbose
if %ERRORLEVEL% neq 0 (
    echo.
    echo ERROR: Failed to upload to main PyPI.
    echo.
    echo This may be caused by:
    echo 1. Authentication failure - Check your .pypirc file or environment variables
    echo 2. Package name 'tjson5' may already be taken on PyPI
    echo 3. Version 0.1.0 may already exist - try incrementing the version in setup.py
    exit /b 1
)
goto EXIT_SUCCESS

:EXIT_SUCCESS
echo.
echo ================================================
echo Successfully published tjson5 to PyPI!
echo.
echo Users can now install your package with:
echo pip install tjson5
echo ================================================
exit /b 0

:EXIT_SCRIPT
echo Publication process cancelled.
exit /b 0