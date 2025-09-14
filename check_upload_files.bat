@echo off
chcp 65001 >nul
echo ========================================
echo     GitHub Upload File Checker
echo ========================================
echo.

echo Checking required files for upload...
echo.

set missing_files=0

REM Check core files
echo [Core Files Check]
if exist "pubspec.yaml" (
    echo [OK] pubspec.yaml - Project config file
) else (
    echo [MISSING] pubspec.yaml - Required!
    set /a missing_files+=1
)

if exist "lib\main.dart" (
    echo [OK] lib\main.dart - App entry point
) else (
    echo [MISSING] lib\main.dart - Required!
    set /a missing_files+=1
)

if exist "android\app\build.gradle" (
    echo [OK] android\app\build.gradle - Android build config
) else (
    echo [MISSING] android\app\build.gradle - Required!
    set /a missing_files+=1
)

echo.
echo [Source Code Directories Check]
if exist "lib\models" (
    echo [OK] lib\models\ - Data models
) else (
    echo [MISSING] lib\models\ - Required!
    set /a missing_files+=1
)

if exist "lib\services" (
    echo [OK] lib\services\ - Business services
) else (
    echo [MISSING] lib\services\ - Required!
    set /a missing_files+=1
)

if exist "lib\screens" (
    echo [OK] lib\screens\ - UI screens
) else (
    echo [MISSING] lib\screens\ - Required!
    set /a missing_files+=1
)

if exist "lib\widgets" (
    echo [OK] lib\widgets\ - UI widgets
) else (
    echo [MISSING] lib\widgets\ - Required!
    set /a missing_files+=1
)

echo.
echo [Optional Files Check]
if exist "README.md" (
    echo [OK] README.md - Project documentation
) else (
    echo [OPTIONAL] README.md - Recommended to add
)

if exist "test" (
    echo [OK] test\ - Test files
) else (
    echo [OPTIONAL] test\ - Recommended to add
)

echo.
echo ========================================
echo           Check Results
echo ========================================

if %missing_files% equ 0 (
    echo [SUCCESS] All required files exist!
    echo [READY] Safe to upload to GitHub
    echo.
    echo Files to upload:
    echo    - lib/           ^(entire folder^)
    echo    - android/       ^(entire folder^)
    echo    - test/          ^(if exists^)
    echo    - pubspec.yaml
    echo    - README.md      ^(if exists^)
    echo.
    echo Do NOT upload:
    echo    - build/         ^(build output^)
    echo    - .dart_tool/    ^(cache files^)
    echo    - *.bat          ^(batch files^)
    echo    - *.sh           ^(shell scripts^)
) else (
    echo [ERROR] Found %missing_files% missing files!
    echo Please check the [MISSING] files above
    echo.
    echo Possible solutions:
    echo 1. Make sure you are in the correct project directory
    echo 2. Regenerate missing files
    echo 3. Check file paths are correct
)

echo.
echo Upload Guide:
echo 1. Visit https://github.com
echo 2. Create new repository ^(set as Public^)
echo 3. Upload the [OK] marked files and folders
echo 4. Do not upload files marked as "Do NOT upload"
echo.

pause
