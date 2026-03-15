@echo off
REM =====================================================
REM MusicMaster Service Stop Tool
REM ANSI/GBK Encoding Compatible
REM =====================================================

echo.
echo ==================================================================
echo   MusicMaster Service Stop Tool
echo ==================================================================
echo.
echo Stopping backend service (Java)...
taskkill /f /im java.exe 2>nul
if errorlevel 1 (
    echo     No running backend service found
) else (
    echo     Backend service stopped
)

echo.
echo Stopping frontend service (Node.js)...
taskkill /f /im node.exe 2>nul
if errorlevel 1 (
    echo     No running frontend service found
) else (
    echo     Frontend service stopped
)

echo.
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
