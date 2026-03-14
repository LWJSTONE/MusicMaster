@echo off
chcp 65001 >nul
REM =====================================================
REM MusicMaster - 启动MySQL服务 (Windows)
REM =====================================================

setlocal enabledelayedexpansion

set "SCRIPT_DIR=%~dp0"
cd /d "%SCRIPT_DIR%"
set "MYSQL_DIR=%SCRIPT_DIR%mysql"

echo ========================================
echo     启动 MySQL 服务
echo ========================================
echo.

REM 检查MySQL是否存在
if not exist "%MYSQL_DIR%\bin\mysqld.exe" (
    echo [错误] MySQL未安装
    echo [提示] 请先运行 setup-mysql.bat 安装MySQL
    pause
    exit /b 1
)

REM 检查MySQL是否已运行
tasklist /FI "IMAGENAME eq mysqld.exe" 2>NUL | find /I /N "mysqld.exe">NUL
if "%ERRORLEVEL%"=="0" (
    echo [信息] MySQL已经在运行中
    exit /b 0
)

echo [信息] 正在启动MySQL...
echo [信息] 端口: 13306
echo.

REM 启动MySQL
start "MusicMaster-MySQL" /min "%MYSQL_DIR%\bin\mysqld.exe" --defaults-file="%MYSQL_DIR%\my.ini" --console

REM 等待MySQL启动
echo [信息] 等待MySQL启动...
timeout /t 5 /nobreak >nul

REM 检查MySQL是否成功启动
tasklist /FI "IMAGENAME eq mysqld.exe" 2>NUL | find /I /N "mysqld.exe">NUL
if "%ERRORLEVEL%"=="0" (
    echo [成功] MySQL启动成功！
) else (
    echo [错误] MySQL启动失败
    pause
    exit /b 1
)
