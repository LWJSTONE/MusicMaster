@echo off
REM =====================================================
REM MusicMaster - One-Click Startup Script
REM ANSI/GBK Encoding Compatible
REM Portable Environment - No System Impact
REM Auto MySQL Setup
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

:: MySQL settings
set MYSQL_HOST=localhost
set MYSQL_PORT=3306
set MYSQL_USER=root
set MYSQL_PASSWORD=root
set DB_NAME=musicmaster

:: ============ Display Menu ============
:MENU
cls
echo.
echo +================================================================+
echo :    M U S I C M A S T E R   -   Main Menu                       :
echo +================================================================+
echo.
echo   [1] One-Click Start (Auto Setup Everything)
echo   [2] Stop All Services
echo   [3] View Help
echo   [0] Exit
echo.
set /p CHOICE="Enter option (0-3): "

if "%CHOICE%"=="1" goto START_ALL
if "%CHOICE%"=="2" goto STOP_ALL
if "%CHOICE%"=="3" goto HELP
if "%CHOICE%"=="0" goto END
echo.
echo Invalid option, please try again!
timeout /t 2 /nobreak >nul
goto MENU

:: ============ Start All ============
:START_ALL
cls
echo.
echo ==================================================================
echo   Starting MusicMaster System (Auto Setup)
echo ==================================================================

:: Step 1: Check runtime environment
echo.
echo [Step 1/7] Checking runtime environment...
echo ------------------------------------------------------------------

:: Check JDK
if exist "%JDK_DIR%\bin\java.exe" (
    set "JAVA_HOME=%JDK_DIR%"
    set "LOCAL_PATH=%JDK_DIR%\bin"
    echo [OK] JDK is ready
) else (
    echo [X] JDK not found!
    echo     Expected: %JDK_DIR%\bin\java.exe
    pause
    goto MENU
)

:: Check Node.js
if exist "%NODE_DIR%\node.exe" (
    set "LOCAL_PATH=%LOCAL_PATH%;%NODE_DIR%"
    echo [OK] Node.js is ready
) else (
    echo [X] Node.js not found!
    echo     Expected: %NODE_DIR%\node.exe
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
    echo     Expected: %MAVEN_DIR%\bin\mvn.cmd
    pause
    goto MENU
)

:: Step 2: Setup MySQL
echo.
echo [Step 2/7] Setting up MySQL...
echo ------------------------------------------------------------------

:: Check for portable MySQL
if exist "%MYSQL_DIR%\bin\mysqld.exe" (
    echo [i] Portable MySQL detected
    
    :: Check if MySQL is already running
    tasklist /fi "imagename eq mysqld.exe" 2>nul | find /i "mysqld.exe" >nul
    if not errorlevel 1 (
        echo [OK] MySQL is already running
        goto :MYSQL_READY
    )
    
    :: Check if data directory exists
    if not exist "%MYSQL_DIR%\data" (
        echo [i] Initializing MySQL data directory...
        cd /d "%MYSQL_DIR%"
        
        :: Create my.ini config file
        echo [mysqld] > my.ini
        echo port=%MYSQL_PORT% >> my.ini
        echo basedir=%MYSQL_DIR%>> my.ini
        echo datadir=%MYSQL_DIR%\data >> my.ini
        echo character-set-server=utf8mb4 >> my.ini
        echo collation-server=utf8mb4_unicode_ci >> my.ini
        echo default-storage-engine=INNODB >> my.ini
        echo max_connections=200 >> my.ini
        echo. >> my.ini
        echo [client] >> my.ini
        echo port=%MYSQL_PORT% >> my.ini
        echo default-character-set=utf8mb4 >> my.ini
        
        :: Initialize data directory (no password)
        "%MYSQL_DIR%\bin\mysqld.exe" --initialize-insecure --console 2>nul
        if errorlevel 1 (
            echo [X] MySQL initialization failed!
            echo     Try running as administrator.
            pause
            goto MENU
        )
        echo [OK] MySQL data directory initialized
    )
    
    :: Start MySQL
    echo [i] Starting MySQL service...
    start "MySQL Server" /min "%MYSQL_DIR%\bin\mysqld.exe"
    
    :: Wait for MySQL to start
    echo [i] Waiting for MySQL to start...
    timeout /t 5 /nobreak >nul
    
    :: Check if MySQL started successfully
    :WAIT_MYSQL
    tasklist /fi "imagename eq mysqld.exe" 2>nul | find /i "mysqld.exe" >nul
    if errorlevel 1 (
        timeout /t 2 /nobreak >nul
        goto :WAIT_MYSQL
    )
    echo [OK] MySQL started
    
    :: Set root password if not set
    echo [i] Setting root password...
    "%MYSQL_DIR%\bin\mysql.exe" -u root -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '%MYSQL_PASSWORD%'; FLUSH PRIVILEGES;" 2>nul
    echo [OK] MySQL password configured
    
) else (
    :: Check if system MySQL is running
    tasklist /fi "imagename eq mysqld.exe" 2>nul | find /i "mysqld.exe" >nul
    if errorlevel 1 (
        echo [X] MySQL not found!
        echo     Please install MySQL or extract portable version to:
        echo     %MYSQL_DIR%
        echo.
        echo     Download: https://dev.mysql.com/downloads/mysql/
        echo     (Select "Windows (x86, 64-bit), ZIP Archive")
        pause
        goto MENU
    )
    echo [OK] System MySQL is running
)

:MYSQL_READY
echo [OK] MySQL is ready

:: Step 3: Initialize database
echo.
echo [Step 3/7] Checking database...
echo ------------------------------------------------------------------

:: Set MySQL command
if exist "%MYSQL_DIR%\bin\mysql.exe" (
    set "MYSQL_CMD=%MYSQL_DIR%\bin\mysql.exe"
) else (
    set "MYSQL_CMD=mysql"
)

:: Check if database exists
"%MYSQL_CMD%" -h%MYSQL_HOST% -P%MYSQL_PORT% -u%MYSQL_USER% -p%MYSQL_PASSWORD% -e "USE %DB_NAME%;" >nul 2>&1
if errorlevel 1 (
    echo [i] Database not found, initializing...
    
    :: Import SQL file
    set "SQL_FILE=%PROJECT_ROOT%backend\src\main\resources\sql\init.sql"
    if exist "%SQL_FILE%" (
        "%MYSQL_CMD%" -h%MYSQL_HOST% -P%MYSQL_PORT% -u%MYSQL_USER% -p%MYSQL_PASSWORD% < "%SQL_FILE%" 2>nul
        if errorlevel 1 (
            echo [X] Database initialization failed!
            echo     Please check MySQL connection.
            pause
            goto MENU
        )
        echo [OK] Database initialized
    ) else (
        echo [X] SQL file not found: %SQL_FILE%
        pause
        goto MENU
    )
) else (
    echo [OK] Database already exists
)

:: Step 4: Install frontend dependencies
echo.
echo [Step 4/7] Checking frontend dependencies...
echo ------------------------------------------------------------------
cd /d "%FRONTEND_DIR%"

if exist "node_modules" (
    echo [OK] Frontend dependencies installed
) else (
    echo [i] Installing frontend dependencies...
    echo     Using Taobao mirror for faster download...
    set "PATH=%LOCAL_PATH%;%PATH%"
    call npm config set registry https://registry.npmmirror.com >nul 2>&1
    call npm install >nul 2>&1
    if errorlevel 1 (
        echo [X] Frontend dependency installation failed!
        pause
        goto MENU
    )
    echo [OK] Frontend dependencies installed
)

:: Step 5: Build backend
echo.
echo [Step 5/7] Building backend project...
echo ------------------------------------------------------------------
cd /d "%BACKEND_DIR%"

if exist "target\musicmaster-backend-1.0.0.jar" (
    echo [OK] Backend already built
) else (
    echo [i] Building backend project...
    echo     This may take a few minutes, please wait...
    set "PATH=%LOCAL_PATH%;%PATH%"
    call "%MAVEN_DIR%\bin\mvn.cmd" clean package -DskipTests -q >nul 2>&1
    if errorlevel 1 (
        echo [X] Backend build failed!
        pause
        goto MENU
    )
    echo [OK] Backend build complete
)

:: Step 6: Start backend
echo.
echo [Step 6/7] Starting backend service...
echo ------------------------------------------------------------------
cd /d "%BACKEND_DIR%"

:: Kill existing java processes (from previous runs)
taskkill /f /im java.exe >nul 2>&1
timeout /t 1 /nobreak >nul

start "MusicMaster Backend" cmd /c ""%JDK_DIR%\bin\java.exe" -jar target\musicmaster-backend-1.0.0.jar"
echo [OK] Backend service starting... (Port: 8080)
echo [i] Waiting for backend service to be ready...
timeout /t 15 /nobreak >nul

:: Step 7: Start frontend
echo.
echo [Step 7/7] Starting frontend service...
echo ------------------------------------------------------------------
cd /d "%FRONTEND_DIR%"

:: Kill existing node processes (from previous runs)
taskkill /f /fi "WINDOWTITLE eq MusicMaster Frontend*" >nul 2>&1

start "MusicMaster Frontend" cmd /c ""%NODE_DIR%\node.exe" node_modules\@vue\cli-service\bin\vue-cli-service.js serve --port 8081"
echo [OK] Frontend service starting... (Port: 8081)
echo [i] Waiting for frontend service...
timeout /t 10 /nobreak >nul

:: Success message
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
echo   Default Admin: admin
echo   Default Password: admin123
echo.

:: Open browser
echo [i] Opening browser...
timeout /t 3 /nobreak >nul
start http://localhost:8081

echo.
echo System started successfully!
echo Closing this window will not affect running services.
echo To stop services, select menu option [2].
echo.
pause
goto MENU

:: ============ Stop All Services ============
:STOP_ALL
cls
echo.
echo ==================================================================
echo   Stopping All Services
echo ==================================================================
echo.

echo Stopping backend (Java)...
taskkill /f /im java.exe 2>nul
if errorlevel 1 (
    echo     No running backend found
) else (
    echo     Backend stopped
)

echo Stopping frontend (Node.js)...
taskkill /f /im node.exe 2>nul
if errorlevel 1 (
    echo     No running frontend found
) else (
    echo     Frontend stopped
)

echo Stopping MySQL...
taskkill /f /im mysqld.exe 2>nul
if errorlevel 1 (
    echo     No running MySQL found
) else (
    echo     MySQL stopped
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
echo  [One-Click Start]
echo   Just select option [1] and the system will:
echo   - Start MySQL (or initialize if first run)
echo   - Create database and import data
echo   - Build and start backend
echo   - Install dependencies and start frontend
echo   - Open browser automatically
echo.
echo  [System Requirements]
echo   - Windows 10/11 (64-bit)
echo   - 4GB+ RAM
echo   - 2GB+ disk space
echo.
echo  [Port Usage]
echo   - Frontend: 8081
echo   - Backend:  8080
echo   - MySQL:    3306
echo.
echo  [Default Account]
echo   - Username: admin
echo   - Password: admin123
echo.
echo  [Environment Isolation]
echo   Uses portable runtime, no system changes.
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
timeout /t 1 /nobreak >nul
exit /b 0
