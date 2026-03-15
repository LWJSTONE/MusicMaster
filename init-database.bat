@echo off
REM =====================================================
REM MusicMaster Database Initialization Tool
REM ANSI/GBK Encoding Compatible
REM =====================================================

echo.
echo ==================================================================
echo       MusicMaster Database Initialization Tool
echo ==================================================================
echo.
echo This tool will help you initialize the MySQL database.
echo.

:: Get project root directory
set "PROJECT_ROOT=%~dp0"
set "MYSQL_DIR=%PROJECT_ROOT%runtime\mysql"

:: Set MySQL connection info
set MYSQL_HOST=localhost
set MYSQL_PORT=3306
set MYSQL_USER=root
set MYSQL_PASSWORD=root
set DB_NAME=musicmaster

echo Current database configuration:
echo   Host: %MYSQL_HOST%:%MYSQL_PORT%
echo   User: %MYSQL_USER%
echo   Password: %MYSQL_PASSWORD%
echo   Database: %DB_NAME%
echo.

set /p CONFIRM="Confirm configuration is correct? (Y/N): "
if /i not "%CONFIRM%"=="Y" (
    echo.
    echo Please edit this script to modify database configuration.
    pause
    exit /b 1
)

echo.
echo [Step 1/2] Testing MySQL connection...
echo.

:: Check for portable MySQL
if exist "%MYSQL_DIR%\bin\mysql.exe" (
    set "MYSQL_CMD=%MYSQL_DIR%\bin\mysql.exe"
    echo Using built-in MySQL command line tool
) else (
    set "MYSQL_CMD=mysql"
    echo Using system MySQL command line tool
)

:: Test MySQL connection
"%MYSQL_CMD%" -h%MYSQL_HOST% -P%MYSQL_PORT% -u%MYSQL_USER% -p%MYSQL_PASSWORD% -e "SELECT 1;" >nul 2>&1
if errorlevel 1 (
    echo [X] MySQL connection failed!
    echo.
    echo Please check:
    echo 1. Is MySQL service running?
    echo 2. Are username and password correct?
    echo 3. Does MySQL allow local connections?
    echo.
    pause
    exit /b 1
)

echo [OK] MySQL connection successful

echo.
echo [Step 2/2] Importing database structure...
echo.

:: Execute SQL file
set "SQL_FILE=%PROJECT_ROOT%backend\src\main\resources\sql\init.sql"

if not exist "%SQL_FILE%" (
    echo [X] SQL file not found: %SQL_FILE%
    pause
    exit /b 1
)

echo Importing: %SQL_FILE%
echo.

"%MYSQL_CMD%" -h%MYSQL_HOST% -P%MYSQL_PORT% -u%MYSQL_USER% -p%MYSQL_PASSWORD% < "%SQL_FILE%"

if errorlevel 1 (
    echo [X] Database import failed!
    pause
    exit /b 1
)

echo.
echo +================================================================+
echo :             Database initialization complete!                   :
echo +================================================================+
echo.
echo   Database: musicmaster
echo   Admin account: admin
echo   Admin password: admin123 (encrypted in database)
echo.
pause
