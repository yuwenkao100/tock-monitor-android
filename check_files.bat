@echo off
echo ========================================
echo     GitHub Upload File Checker
echo ========================================
echo.

echo Checking required files for upload...
echo.

set missing=0

echo [Core Files]
if exist "pubspec.yaml" (
    echo [OK] pubspec.yaml
) else (
    echo [MISSING] pubspec.yaml
    set /a missing+=1
)

if exist "lib\main.dart" (
    echo [OK] lib\main.dart
) else (
    echo [MISSING] lib\main.dart
    set /a missing+=1
)

if exist "android\app\build.gradle" (
    echo [OK] android\app\build.gradle
) else (
    echo [MISSING] android\app\build.gradle
    set /a missing+=1
)

echo.
echo [Source Directories]
if exist "lib\models" (
    echo [OK] lib\models\
) else (
    echo [MISSING] lib\models\
    set /a missing+=1
)

if exist "lib\services" (
    echo [OK] lib\services\
) else (
    echo [MISSING] lib\services\
    set /a missing+=1
)

if exist "lib\screens" (
    echo [OK] lib\screens\
) else (
    echo [MISSING] lib\screens\
    set /a missing+=1
)

if exist "lib\widgets" (
    echo [OK] lib\widgets\
) else (
    echo [MISSING] lib\widgets\
    set /a missing+=1
)

echo.
echo [Optional Files]
if exist "README.md" (
    echo [OK] README.md
) else (
    echo [OPTIONAL] README.md
)

if exist "test" (
    echo [OK] test\
) else (
    echo [OPTIONAL] test\
)

echo.
echo ========================================
echo           Results
echo ========================================

if %missing% equ 0 (
    echo [SUCCESS] All required files found!
    echo [READY] You can upload to GitHub
    echo.
    echo Upload these files/folders:
    echo   - lib/
    echo   - android/
    echo   - pubspec.yaml
    echo   - README.md ^(if exists^)
    echo   - test/ ^(if exists^)
    echo.
    echo Do NOT upload:
    echo   - build/
    echo   - .dart_tool/
    echo   - *.bat files
    echo   - *.sh files
) else (
    echo [ERROR] Missing %missing% required files!
    echo Please check the [MISSING] items above
)

echo.
echo Next steps:
echo 1. Go to https://github.com
echo 2. Create new repository ^(Public^)
echo 3. Upload the files listed above
echo.
pause
