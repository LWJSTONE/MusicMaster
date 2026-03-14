@echo off
chcp 65001 >nul
REM =====================================================
REM MusicMaster - 停止所有服务 (Windows)
REM =====================================================

setlocal enabledelayedexpansion

set "SCRIPT_DIR=%~dp0"
cd /d "%SCRIPT_DIR%"

echo ========================================
echo     停止 MusicMaster 所有服务
echo ========================================
echo.

REM 停止Java应用
echo [信息] 正在停止应用程序...
tasklist /FI "IMAGENAME eq java.exe" 2>NUL | find /I /N "java.exe">NUL
if "%ERRORLEVEL%"=="0" (
    taskkill /F /IM java.exe >nul 2>&1
    echo [成功] 应用程序已停止
) else (
    echo [信息] 应用程序未在运行
)

REM 停止MySQL
echo [信息] 正在停止MySQL...
call stop-mysql.bat

echo.
echo [完成] 所有服务已停止
