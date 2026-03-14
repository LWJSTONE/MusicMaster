@echo off
chcp 65001 >nul
REM =====================================================
REM MusicMaster 音乐管理系统 - 一键启动脚本 (Windows)
REM 使用便携式MySQL数据库
REM =====================================================

setlocal enabledelayedexpansion

set "SCRIPT_DIR=%~dp0"
cd /d "%SCRIPT_DIR%"
set "MYSQL_DIR=%SCRIPT_DIR%mysql"

echo ╔══════════════════════════════════════════════════════════════╗
echo ║               MusicMaster 音乐管理系统                        ║
echo ║                  便携版 - 一键启动                           ║
echo ╚══════════════════════════════════════════════════════════════╝
echo.

REM 检查MySQL是否已安装
if not exist "%MYSQL_DIR%\bin\mysqld.exe" (
    echo [警告] MySQL便携版未安装
    echo.
    echo 请选择:
    echo   1. 运行 setup-mysql.bat 下载并安装MySQL便携版
    echo   2. 使用系统已安装的MySQL (需要手动创建数据库)
    echo.
    set /p choice="请输入选择 (1/2): "
    
    if "!choice!"=="1" (
        call setup-mysql.bat
        if !errorlevel! neq 0 (
            echo [错误] MySQL安装失败
            pause
            exit /b 1
        )
    ) else if "!choice!"=="2" (
        echo [信息] 将使用系统MySQL，请确保数据库已创建
        goto :start_app
    ) else (
        echo [错误] 无效的选择
        pause
        exit /b 1
    )
)

REM 启动MySQL
echo [步骤 1/2] 启动MySQL数据库...
call start-mysql.bat
if !errorlevel! neq 0 (
    echo [错误] MySQL启动失败
    pause
    exit /b 1
)

echo.

:start_app
REM 检查应用JAR是否存在
if not exist "%SCRIPT_DIR%app\musicmaster.jar" (
    echo [错误] 应用程序不存在
    echo [提示] 请将编译好的JAR文件复制到: %SCRIPT_DIR%app\musicmaster.jar
    echo.
    echo 构建方法:
    echo   cd backend
    echo   mvn clean package -DskipTests
    echo   复制 target\musicmaster-backend-1.0.0.jar 到 portable\app\musicmaster.jar
    pause
    exit /b 1
)

REM 查找Java命令
set "JAVA_CMD="
if exist "%SCRIPT_DIR%jre\bin\java.exe" (
    set "JAVA_CMD=%SCRIPT_DIR%jre\bin\java.exe"
)
if defined JAVA_HOME (
    if exist "%JAVA_HOME%\bin\java.exe" (
        set "JAVA_CMD=%JAVA_HOME%\bin\java.exe"
    )
)
where java >nul 2>&1
if %errorlevel% equ 0 (
    set "JAVA_CMD=java"
)

if not defined JAVA_CMD (
    echo [错误] 未找到Java运行环境
    echo [提示] 请安装Java 8或更高版本
    echo 下载地址: https://adoptium.net/
    pause
    exit /b 1
)

echo [步骤 2/2] 启动应用程序...
echo.

REM 创建必要的目录
if not exist "%SCRIPT_DIR%data" mkdir "%SCRIPT_DIR%data"
if not exist "%SCRIPT_DIR%uploads\music" mkdir "%SCRIPT_DIR%uploads\music"
if not exist "%SCRIPT_DIR%uploads\image" mkdir "%SCRIPT_DIR%uploads\image"
if not exist "%SCRIPT_DIR%logs" mkdir "%SCRIPT_DIR%logs"

echo ========================================
echo 启动参数:
echo   - 应用路径: %SCRIPT_DIR%app\musicmaster.jar
echo   - MySQL端口: 13306
echo   - Web端口: 8080
echo ========================================
echo.
echo 访问地址: http://localhost:8080
echo 默认账号: admin
echo 默认密码: 123456
echo.
echo [提示] 按 Ctrl+C 停止服务
echo.

REM 启动应用
"%JAVA_CMD%" -jar "%SCRIPT_DIR%app\musicmaster.jar"

REM 应用停止后，停止MySQL
echo.
echo [信息] 正在停止MySQL...
call stop-mysql.bat

pause
