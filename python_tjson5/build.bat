@echo off
echo Triple-JSON5 Python Package Builder
echo =================================

rem Check for arguments
if "%1"=="--help" goto :show_help
if "%1"=="-h" goto :show_help
if "%1"=="--version" goto :show_version

rem Run the Python build script, passing along any arguments
python build.py %*
goto :eof

:show_help
echo Build script for the tjson5 Python package
echo.
echo Usage:
echo   build.bat [options]
echo.
echo Options:
echo   --yes, -y       Automatically answer yes to all prompts
echo   --no-test       Skip running the tests
echo   --install       Install the package locally after building
echo   --publish       Publish the package to PyPI after building
echo   --version       Show version information and exit
echo   --help, -h      Show this help message and exit
echo.
echo Examples:
echo   build.bat                  Interactive build process
echo   build.bat --yes --install  Build and install with no prompts
echo   build.bat --publish        Build and publish to PyPI
echo.
goto :eof

:show_version
python build.py --version
goto :eof