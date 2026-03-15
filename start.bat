@echo off
REM =====================================================
REM MusicMaster - One-Click Startup Script
REM ANSI/GBK Encoding Compatible
REM Portable Environment - No System Impact
REM =====================================================

setlocal enabledelayedexpansion

title MusicMaster Launcher

color 0A

echo.
echo +================================================================+
echo :                                                                :
echo :    M U S I C M A S T E R                                       :
echo :                                                                :
echo :    Music Management System v1.0.0                              :
echo :                                                                :
echo +================================================================+
echo.

:: Get project root directory
set "PROJECT_ROOT=%~dp0"
set "RUNTIME_DIR=%PROJECT_ROOT%runtime"
set "JDK_DIR=%RUNTIME_DIR%\jdk"
set "NODE_DIR=%RUNTIME_DIR%\nodejs"
set "MAVEN_DIR=%RUNTIME_DIR%\maven"
set "MYSQL_DIR=%RUNTIME_DIR%\mysql"
set "BACKEND_DIR=%PROJECT_ROOT%backend"
set "FRONTEND_DIR=%PROJECT_ROOT%frontend"

:: ============ Display Menu ============
:MENU
echo.
echo ==================================================================
echo   Please select an option:
echo ==================================================================
echo.
echo   [1] Start System (Recommended)
echo   [2] Initialize Database
echo   [3] Stop All Services
echo   [4] View Help
echo   [0] Exit
echo.
set /p CHOICE="Enter option (0-4): "

if "%CHOICE%"=="1" goto START_ALL
if "%CHOICE%"=="2" goto INIT_DB
if "%CHOICE%"=="3" goto STOP_ALL
if "%CHOICE%"=="4" goto HELP
if "%CHOICE%"=="0" goto END
echo.
echo Invalid option, please try again!
goto MENU

:: ============ Start All ============
:START_ALL
cls
echo.
echo ==================================================================
echo   Starting MusicMaster System
echo ==================================================================

:: Step 1: Check environment
echo.
echo [Step 1/6] Checking runtime environment...
echo ------------------------------------------------------------------

:: Check JDK (use local environment variables, no system impact)
if exist "%JDK_DIR%\bin\java.exe" (
    set "JAVA_HOME=%JDK_DIR%"
    set "LOCAL_PATH=%JDK_DIR%\bin"
    echo [OK] JDK is ready
) else (
    echo [X] JDK not found!
    echo     Please extract JDK 8 to: %JDK_DIR%
    echo     Download: https://adoptium.net/temurin/releases/?version=8
    pause
    goto MENU
)

:: Check Node.js
if exist "%NODE_DIR%\node.exe" (
    set "LOCAL_PATH=%LOCAL_PATH%;%NODE_DIR%"
    echo [OK] Node.js is ready
) else (
    echo [X] Node.js not found!
    echo     Please extract Node.js 18 to: %NODE_DIR%
    echo     Download: https://nodejs.org/
    pause
    goto MENU
)

:: Check Maven
if exist "%MAVEN_DIR%\bin\mvn.cmd" (
    set "MAVEN_HOME=%MAVEN_DIR%"
    set "LOCAL_PATH=%LOCAL_PATH%;%MAVEN_DIR%\bin"
    echo [OK] Maven is ready
) else (
    echo [X] Maven not found!
    echo     Please extract Maven to: %MAVEN_DIR%
    echo     Download: https://maven.apache.org/download.cgi
    pause
    goto MENU
)

:: Step 2: Check MySQL
echo.
echo [Step 2/6] Checking database connection...
echo ------------------------------------------------------------------

:: Check if MySQL is running
tasklist /fi "imagename eq mysqld.exe" 2>nul | find /i "mysqld.exe" >nul
if errorlevel 1 (
    echo [!] MySQL is not running

    :: Check for portable MySQL
    if exist "%MYSQL_DIR%\bin\mysqld.exe" (
        echo [i] Portable MySQL detected, starting...
        start "MySQL Server" "%MYSQL_DIR%\bin\mysqld.exe" --console
        echo Waiting for MySQL to start...
        timeout /t 8 /nobreak >nul
    ) else (
        echo [!] Please ensure MySQL service is running
        echo     Or extract MySQL to: %MYSQL_DIR%
        echo.
        set /p MYSQL_CONFIRM="Is MySQL running at another location? (Y/N): "
        if /i not "!MYSQL_CONFIRM!"=="Y" (
            pause
            goto MENU
        )
    )
) else (
    echo [OK] MySQL is running
)

:: Step 3: Install frontend dependencies
echo.
echo [Step 3/6] Checking frontend dependencies...
echo ------------------------------------------------------------------
cd /d "%FRONTEND_DIR%"

if exist "node_modules" (
    echo [OK] Frontend dependencies installed
) else (
    echo Installing frontend dependencies...
    echo Using Taobao mirror for faster download...
    set "PATH=%LOCAL_PATH%;%PATH%"
    call npm config set registry https://registry.npmmirror.com
    call npm install
    if errorlevel 1 (
        echo [X] Frontend dependency installation failed!
        pause
        goto MENU
    )
    echo [OK] Frontend dependencies installed
)

:: Step 4: Build backend
echo.
echo [Step 4/6] Building backend project...
echo ------------------------------------------------------------------
cd /d "%BACKEND_DIR%"

if exist "target\musicmaster-backend-1.0.0.jar" (
    echo [OK] Backend already built
) else (
    echo First run, building backend project...
    echo This may take a few minutes, please wait...
    set "PATH=%LOCAL_PATH%;%PATH%"
    call "%MAVEN_DIR%\bin\mvn.cmd" clean package -DskipTests -q
    if errorlevel 1 (
        echo [X] Backend build failed!
        pause
        goto MENU
    )
    echo [OK] Backend build complete
)

:: Step 5: Start backend
echo.
echo [Step 5/6] Starting backend service...
echo ------------------------------------------------------------------
cd /d "%BACKEND_DIR%"
start "MusicMaster Backend" cmd /c ""%JDK_DIR%\bin\java.exe" -jar target\musicmaster-backend-1.0.0.jar"
echo [OK] Backend service starting... (Port: 8080)
echo Waiting for backend service...
timeout /t 12 /nobreak >nul

:: Step 6: Start frontend
echo.
echo [Step 6/6] Starting frontend service...
echo ------------------------------------------------------------------
cd /d "%FRONTEND_DIR%"
start "MusicMaster Frontend" cmd /c ""%NODE_DIR%\node.exe" node_modules\@vue\cli-service\bin\vue-cli-service.js serve --port 8081"
echo [OK] Frontend service starting... (Port: 8081)
echo Waiting for frontend service...
timeout /t 15 /nobreak >nul

echo.
echo +================================================================+
echo :                                                                :
echo :              STARTUP SUCCESSFUL!                               :
echo :                                                                :
echo +================================================================+
echo.
echo   Frontend URL: http://localhost:8081
echo   Backend API:  http://localhost:8080/api
echo.
echo   Default Admin Account: admin
echo   Default Password:      admin123
echo.

:: Open browser
echo Opening browser...
timeout /t 3 /nobreak >nul
start http://localhost:8081

echo.
echo System started successfully!
echo Closing this window will not affect running services.
echo To stop services, select menu option [3] or close backend/frontend windows.
echo.
pause
goto MENU

:: ============ Initialize Database ============
:INIT_DB
cls
echo.
echo ==================================================================
echo   Initialize Database
echo ==================================================================
echo.
echo This tool will help you initialize the MySQL database.
echo.

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
    goto MENU
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
    goto MENU
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
    goto MENU
)

echo Importing: %SQL_FILE%
echo.

"%MYSQL_CMD%" -h%MYSQL_HOST% -P%MYSQL_PORT% -u%MYSQL_USER% -p%MYSQL_PASSWORD% < "%SQL_FILE%"

if errorlevel 1 (
    echo [X] Database import failed!
    pause
    goto MENU
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
goto MENU

:: ============ Stop All Services ============
:STOP_ALL
cls
echo.
echo ==================================================================
echo   Stop All Services
echo ==================================================================
echo.
echo Stopping backend service (Java)...
taskkill /f /im java.exe 2>nul
if errorlevel 1 (
    echo     No running backend service found
) else (
    echo     Backend service stopped
)

echo Stopping frontend service (Node.js)...
taskkill /f /im node.exe 2>nul
if errorlevel 1 (
    echo     No running frontend service found
) else (
    echo     Frontend service stopped
)

echo Stopping MySQL service...
taskkill /f /im mysqld.exe 2>nul
if errorlevel 1 (
    echo     No running MySQL service found
) else (
    echo     MySQL service stopped
)

echo.
echo ==================================================================
echo   All services stopped
echo ==================================================================
echo.
pause
goto MENU

:: ============ Help ============
:HELP
cls
echo.
echo ==================================================================
echo   MusicMaster Help
echo ==================================================================
echo.
echo  [Quick Start]
echo   1. First time setup:
echo      - Extract JDK 8 to: runtime/jdk/
echo      - Extract Node.js 18 to: runtime/nodejs/
echo      - Extract Maven to: runtime/maven/
echo      - Extract MySQL to: runtime/mysql/ (optional)
echo.
echo   2. Download links:
echo      - JDK 8:    https://adoptium.net/temurin/releases/?version=8
echo      - Node.js:  https://nodejs.org/
echo      - Maven:    https://maven.apache.org/download.cgi
echo      - MySQL:    https://dev.mysql.com/downloads/mysql/
echo.
echo   3. Run steps:
echo      - Select [2] Initialize Database
echo      - Select [1] Start System
echo.
echo  [System Requirements]
echo   - Windows 10/11 (64-bit)
echo   - At least 4GB available memory
echo   - At least 2GB available disk space
echo.
echo  [Port Usage]
echo   - Frontend: 8081
echo   - Backend:  8080
echo   - MySQL:    3306
echo   If ports are occupied, close conflicting programs or modify config.
echo.
echo  [Default Account]
echo   - Admin: admin / admin123
echo   - Please change password after login.
echo.
echo  [Environment Isolation]
echo   This script uses portable runtime environment.
echo   It does NOT modify system environment variables.
echo   All environment variables are only valid during script execution.
echo.
echo ==================================================================
echo.
pause
goto MENU

:: ============ Exit ============
:END
echo.
echo Thank you for using MusicMaster!
echo.
timeout /t 2 /nobreak >nul
exit /b 0
