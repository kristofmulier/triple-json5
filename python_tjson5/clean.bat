@echo off
echo Cleaning Triple-JSON5 Python package build artifacts
echo --------------------------------------------------

echo Removing build directory...
if exist build rmdir /s /q build

echo Removing dist directory...
if exist dist rmdir /s /q dist

echo Removing egg-info directory...
if exist tjson5.egg-info rmdir /s /q tjson5.egg-info

echo Removing compiled Python files...
for /r %%i in (*.pyc *.pyo __pycache__) do (
    if exist "%%i" (
        echo Removing: %%i
        del /q "%%i" 2>nul
        if exist "%%i" rmdir /s /q "%%i" 2>nul
    )
)

echo Removing generated C extensions...
if exist tjson5parser.cpython*.pyd del /f tjson5parser.cpython*.pyd
if exist tjson5parser.cp*-win*.pyd del /f tjson5parser.cp*-win*.pyd
if exist tjson5parser.cpython*.so del /f tjson5parser.cpython*.so

echo.
echo Build artifacts successfully cleaned.
echo.

exit /b 0