@echo off
chcp 65001 >nul
REM =====================================================
REM MusicMaster - 初始化数据库 (Windows)
REM =====================================================

setlocal enabledelayedexpansion

set "SCRIPT_DIR=%~dp0"
cd /d "%SCRIPT_DIR%"
set "MYSQL_DIR=%SCRIPT_DIR%mysql"

echo ========================================
echo     初始化 MusicMaster 数据库
echo ========================================
echo.

REM 检查MySQL是否存在
if not exist "%MYSQL_DIR%\bin\mysql.exe" (
    echo [错误] MySQL未安装
    echo [提示] 请先运行 setup-mysql.bat 安装MySQL
    pause
    exit /b 1
)

REM 检查MySQL是否在运行
tasklist /FI "IMAGENAME eq mysqld.exe" 2>NUL | find /I /N "mysqld.exe">NUL
if not "%ERRORLEVEL%"=="0" (
    echo [信息] MySQL未运行，正在启动...
    call start-mysql.bat
    timeout /t 5 /nobreak >nul
)

echo [信息] 正在初始化数据库...
echo.

REM 执行初始化SQL
"%MYSQL_DIR%\bin\mysql.exe" -u root -P 13306 --protocol=tcp -e "source ..\backend\src\main\resources\sql\init.sql" 2>&1

if %errorlevel% equ 0 (
    echo.
    echo ========================================
    echo [成功] 数据库初始化完成！
    echo ========================================
    echo.
    echo 数据库名: musicmaster
    echo 管理员账号: admin
    echo 管理员密码: 123456
    echo.
) else (
    echo.
    echo [错误] 数据库初始化失败
    echo [提示] 请检查MySQL是否正常运行
    pause
    exit /b 1
)

pause
