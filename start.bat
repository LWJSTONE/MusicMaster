@echo off
REM =====================================================
REM MusicMaster - One-Click Startup Script
REM Auto MySQL Setup - Fully Automated
REM =====================================================

setlocal enabledelayedexpansion

title MusicMaster Launcher

color 0A

echo.
echo +================================================================+
echo :    M U S I C M A S T E R   -   Music Management System         :
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
set MYSQL_PORT=3306
set MYSQL_USER=root
set MYSQL_PASSWORD=root
set DB_NAME=musicmaster

:: ============ Display Menu ============
:MENU
cls
echo.
echo +================================================================+
echo :    Main Menu                                                   :
echo +================================================================+
echo.
echo   [1] One-Click Start
echo   [2] Stop All Services
echo   [3] Help
echo   [0] Exit
echo.
set /p CHOICE="Select: "

if "%CHOICE%"=="1" goto START_ALL
if "%CHOICE%"=="2" goto STOP_ALL
if "%CHOICE%"=="3" goto HELP
if "%CHOICE%"=="0" goto END
echo Invalid option!
timeout /t 2 /nobreak >nul
goto MENU

:: ============ Start All ============
:START_ALL
cls
echo.
echo ==================================================================
echo   Starting MusicMaster (Auto Setup)
echo ==================================================================

:: Step 1: Check runtime
echo.
echo [1/7] Checking runtime...
if not exist "%JDK_DIR%\bin\java.exe" (echo [X] JDK missing! & pause & goto MENU)
if not exist "%NODE_DIR%\node.exe" (echo [X] Node.js missing! & pause & goto MENU)
if not exist "%MAVEN_DIR%\bin\mvn.cmd" (echo [X] Maven missing! & pause & goto MENU)
echo [OK] Runtime ready

:: Step 2: Setup MySQL
echo.
echo [2/7] Setting up MySQL...

:: Check for portable MySQL
if exist "%MYSQL_DIR%\bin\mysqld.exe" (
    :: Check if running
    tasklist /fi "imagename eq mysqld.exe" 2>nul | find /i "mysqld.exe" >nul
    if not errorlevel 1 (
        echo [OK] MySQL already running
        goto :MYSQL_CONNECTED
    )
    
    :: First run - initialize
    if not exist "%MYSQL_DIR%\data" (
        echo [i] First run - initializing MySQL...
        
        :: Create config
        (
            echo [mysqld]
            echo port=%MYSQL_PORT%
            echo basedir=%MYSQL_DIR%
            echo datadir=%MYSQL_DIR%\data
            echo character-set-server=utf8mb4
            echo default-storage-engine=INNODB
            echo default_authentication_plugin=mysql_native_password
            echo [client]
            echo port=%MYSQL_PORT%
            echo default-character-set=utf8mb4
        ) > "%MYSQL_DIR%\my.ini"
        
        :: Initialize without password
        cd /d "%MYSQL_DIR%"
        "%MYSQL_DIR%\bin\mysqld.exe" --initialize-insecure --console 2>nul
        
        echo [OK] MySQL initialized
    )
    
    :: Start MySQL
    echo [i] Starting MySQL...
    start "MySQL" /min "%MYSQL_DIR%\bin\mysqld.exe"
    
    :: Wait for MySQL
    set W=0
    :WAIT_LOOP
    timeout /t 2 /nobreak >nul
    set /a W+=2
    "%MYSQL_DIR%\bin\mysqladmin.exe" ping -u root 2>nul | find "alive" >nul
    if errorlevel 1 (
        if !W! LSS 30 goto :WAIT_LOOP
        echo [X] MySQL start timeout!
        pause & goto MENU
    )
    echo [OK] MySQL started
    
    :: Set password for new MySQL
    if not exist "%MYSQL_DIR%\data\password_set" (
        echo [i] Setting root password...
        "%MYSQL_DIR%\bin\mysql.exe" -u root -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '%MYSQL_PASSWORD%'; FLUSH PRIVILEGES;" 2>nul
        echo. > "%MYSQL_DIR%\data\password_set"
        echo [OK] Password set
    )
    
) else (
    :: No portable MySQL
    tasklist /fi "imagename eq mysqld.exe" 2>nul | find /i "mysqld.exe" >nul
    if errorlevel 1 (
        echo [X] MySQL not found!
        echo     Extract MySQL to: %MYSQL_DIR%
        pause & goto MENU
    )
    echo [OK] System MySQL running
)

:MYSQL_CONNECTED

:: Step 3: Init database
echo.
echo [3/7] Checking database...

:: Test connection with password
"%MYSQL_DIR%\bin\mysql.exe" -u%MYSQL_USER% -p%MYSQL_PASSWORD% -e "SELECT 1;" >nul 2>&1
if errorlevel 1 (
    :: Try without password
    "%MYSQL_DIR%\bin\mysql.exe" -u%MYSQL_USER% -e "SELECT 1;" >nul 2>&1
    if not errorlevel 1 (
        "%MYSQL_DIR%\bin\mysql.exe" -u%MYSQL_USER% -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '%MYSQL_PASSWORD%'; FLUSH PRIVILEGES;" 2>nul
    ) else (
        echo [X] Cannot connect to MySQL!
        pause & goto MENU
    )
)

:: Check database
"%MYSQL_DIR%\bin\mysql.exe" -u%MYSQL_USER% -p%MYSQL_PASSWORD% -e "USE %DB_NAME%;" >nul 2>&1
if errorlevel 1 (
    echo [i] Initializing database...
    "%MYSQL_DIR%\bin\mysql.exe" -u%MYSQL_USER% -p%MYSQL_PASSWORD% < "%BACKEND_DIR%\src\main\resources\sql\init.sql" 2>nul
    if errorlevel 1 (
        echo [X] Database init failed!
        pause & goto MENU
    )
    echo [OK] Database ready
) else (
    echo [OK] Database exists
)

:: Step 4: Frontend dependencies
echo.
echo [4/7] Frontend dependencies...
cd /d "%FRONTEND_DIR%"
if not exist "node_modules" (
    echo [i] Installing (please wait)...
    set "PATH=%NODE_DIR%;%PATH%"
    call npm config set registry https://registry.npmmirror.com >nul 2>&1
    call npm install >nul 2>&1
)
echo [OK] Ready

:: Step 5: Build backend
echo.
echo [5/7] Building backend...
cd /d "%BACKEND_DIR%"
if not exist "target\musicmaster-backend-1.0.0.jar" (
    echo [i] Building (please wait)...
    set "PATH=%JDK_DIR%\bin;%MAVEN_DIR%\bin;%PATH%"
    call mvn clean package -DskipTests -q >nul 2>&1
)
echo [OK] Ready

:: Step 6: Start backend
echo.
echo [6/7] Starting backend...
taskkill /f /im java.exe >nul 2>&1
timeout /t 1 /nobreak >nul
start "Backend" cmd /c ""%JDK_DIR%\bin\java.exe" -jar target\musicmaster-backend-1.0.0.jar"
echo [OK] Starting on port 8080
timeout /t 15 /nobreak >nul

:: Step 7: Start frontend
echo.
echo [7/7] Starting frontend...
taskkill /f /fi "WINDOWTITLE eq Frontend*" >nul 2>&1
start "Frontend" cmd /c ""%NODE_DIR%\node.exe" node_modules\@vue\cli-service\bin\vue-cli-service.js serve --port 8081"
echo [OK] Starting on port 8081
timeout /t 10 /nobreak >nul

:: Done
echo.
echo +================================================================+
echo :   STARTUP COMPLETE!                                            :
echo +================================================================+
echo.
echo   URL: http://localhost:8081
echo   User: admin / admin123
echo.
echo Opening browser...
timeout /t 3 /nobreak >nul
start http://localhost:8081
echo.
pause
goto MENU

:: ============ Stop All ============
:STOP_ALL
cls
echo.
echo Stopping all services...
taskkill /f /im java.exe 2>nul
taskkill /f /im node.exe 2>nul
taskkill /f /im mysqld.exe 2>nul
echo Done.
pause
goto MENU

:: ============ Help ============
:HELP
cls
echo.
echo ==================================================================
echo   Help
echo ==================================================================
echo.
echo  [1] One-Click Start
echo      Automatically starts MySQL, initializes database,
echo      builds and runs backend and frontend.
echo.
echo  [Ports] Frontend:8081  Backend:8080  MySQL:3306
echo.
echo  [Default Login] admin / admin123
echo.
echo ==================================================================
pause
goto MENU

:: ============ Exit ============
:END
exit /b 0
