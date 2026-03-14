@echo off
chcp 65001 >nul
REM =====================================================
REM MusicMaster - 停止MySQL服务 (Windows)
REM =====================================================

setlocal enabledelayedexpansion

set "SCRIPT_DIR=%~dp0"
cd /d "%SCRIPT_DIR%"
set "MYSQL_DIR=%SCRIPT_DIR%mysql"

echo ========================================
echo     停止 MySQL 服务
echo ========================================
echo.

REM 检查MySQL是否在运行
tasklist /FI "IMAGENAME eq mysqld.exe" 2>NUL | find /I /N "mysqld.exe">NUL
if not "%ERRORLEVEL%"=="0" (
    echo [信息] MySQL未在运行
    exit /b 0
)

echo [信息] 正在停止MySQL...

REM 使用mysqladmin优雅关闭
if exist "%MYSQL_DIR%\bin\mysqladmin.exe" (
    "%MYSQL_DIR%\bin\mysqladmin.exe" -u root -P 13306 --protocol=tcp shutdown 2>nul
    timeout /t 3 /nobreak >nul
)

REM 强制关闭（如果优雅关闭失败）
tasklist /FI "IMAGENAME eq mysqld.exe" 2>NUL | find /I /N "mysqld.exe">NUL
if "%ERRORLEVEL%"=="0" (
    echo [警告] 优雅关闭失败，正在强制终止...
    taskkill /F /IM mysqld.exe >nul 2>&1
)

echo [成功] MySQL已停止
