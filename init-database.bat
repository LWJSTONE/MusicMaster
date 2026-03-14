@echo off
chcp 65001 >nul
echo.
echo ╔══════════════════════════════════════════════════════╗
echo ║       MusicMaster 数据库初始化工具                     ║
echo ╚══════════════════════════════════════════════════════╝
echo.
echo 此工具将帮助您初始化 MySQL 数据库
echo.

:: 设置MySQL连接信息
set MYSQL_HOST=localhost
set MYSQL_PORT=3306
set MYSQL_USER=root
set MYSQL_PASSWORD=root
set DB_NAME=musicmaster

echo 当前数据库配置:
echo   主机: %MYSQL_HOST%:%MYSQL_PORT%
echo   用户: %MYSQL_USER%
echo   密码: %MYSQL_PASSWORD%
echo   数据库: %DB_NAME%
echo.

set /p CONFIRM="确认以上配置正确? (Y/N): "
if /i not "%CONFIRM%"=="Y" (
    echo.
    echo 请手动编辑此脚本修改数据库配置
    pause
    exit /b 1
)

echo.
echo [步骤 1/2] 测试 MySQL 连接...
echo.

:: 测试MySQL连接
mysql -h%MYSQL_HOST% -P%MYSQL_PORT% -u%MYSQL_USER% -p%MYSQL_PASSWORD% -e "SELECT 1;" >nul 2>&1
if errorlevel 1 (
    echo [X] MySQL 连接失败!
    echo.
    echo 请检查:
    echo 1. MySQL 服务是否已启动
    echo 2. 用户名和密码是否正确
    echo 3. MySQL 是否允许本地连接
    echo.
    pause
    exit /b 1
)

echo [OK] MySQL 连接成功

echo.
echo [步骤 2/2] 导入数据库结构...
echo.

:: 执行SQL文件
set "SQL_FILE=%~dp0backend\src\main\resources\sql\init.sql"

if not exist "%SQL_FILE%" (
    echo [X] SQL文件不存在: %SQL_FILE%
    pause
    exit /b 1
)

echo 正在导入: %SQL_FILE%
echo.

mysql -h%MYSQL_HOST% -P%MYSQL_PORT% -u%MYSQL_USER% -p%MYSQL_PASSWORD% < "%SQL_FILE%"

if errorlevel 1 (
    echo [X] 数据库导入失败!
    pause
    exit /b 1
)

echo.
echo ╔══════════════════════════════════════════════════════╗
echo ║             数据库初始化完成!                         ║
echo ╠══════════════════════════════════════════════════════╣
echo ║  数据库名: musicmaster                                ║
echo ║  管理员账号: admin                                    ║
echo ║  管理员密码: admin123 (数据库中加密存储)              ║
echo ╚══════════════════════════════════════════════════════╝
echo.
pause
