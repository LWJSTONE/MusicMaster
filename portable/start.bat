@echo off
chcp 65001 >nul
REM =====================================================
REM MusicMaster 音乐管理系统 - 一键启动脚本
REM 支持Windows系统
REM =====================================================

setlocal enabledelayedexpansion

REM 获取脚本所在目录
set "SCRIPT_DIR=%~dp0"
cd /d "%SCRIPT_DIR%"

echo ========================================
echo     MusicMaster 音乐管理系统
echo ========================================
echo.

REM 检查端口是否被占用
netstat -ano | findstr ":8080" | findstr "LISTENING" >nul
if %errorlevel% equ 0 (
    echo [警告] 端口8080已被占用
    echo [警告] 请关闭占用该端口的程序后重试
    set /p continue_choice="是否继续启动？(y/n): "
    if /i "!continue_choice!" neq "y" (
        exit /b 1
    )
)

REM 查找Java命令
set "JAVA_CMD="

REM 优先使用内置JRE
if exist "%SCRIPT_DIR%jre\bin\java.exe" (
    set "JAVA_CMD=%SCRIPT_DIR%jre\bin\java.exe"
    goto :found_java
)

REM 检查JAVA_HOME环境变量
if defined JAVA_HOME (
    if exist "%JAVA_HOME%\bin\java.exe" (
        set "JAVA_CMD=%JAVA_HOME%\bin\java.exe"
        goto :found_java
    )
)

REM 检查系统PATH中的java
where java >nul 2>&1
if %errorlevel% equ 0 (
    set "JAVA_CMD=java"
    goto :found_java
)

echo [错误] 未找到Java运行环境
echo.
echo 请执行以下步骤之一:
echo 1. 安装Java 11或更高版本
echo 2. 运行 setup-jre.bat 下载便携式JRE
echo.
echo 下载Java: https://adoptium.net/
pause
exit /b 1

:found_java
echo [信息] 找到Java: %JAVA_CMD%

REM 检查Java版本
%JAVA_CMD% -version 2>&1 | findstr /r "version" | findstr /r "1[1-9]\|[2-9][0-9]" >nul
if %errorlevel% neq 0 (
    %JAVA_CMD% -version 2>&1 | findstr /r "version" >nul
    echo [信息] Java版本检查通过
)

echo.
echo [信息] 正在启动MusicMaster...
echo.

REM 创建必要的目录
if not exist "%SCRIPT_DIR%data" mkdir "%SCRIPT_DIR%data"
if not exist "%SCRIPT_DIR%uploads\music" mkdir "%SCRIPT_DIR%uploads\music"
if not exist "%SCRIPT_DIR%uploads\image" mkdir "%SCRIPT_DIR%uploads\image"
if not exist "%SCRIPT_DIR%logs" mkdir "%SCRIPT_DIR%logs"

REM 启动参数
echo [信息] 启动参数:
echo   - 应用路径: %SCRIPT_DIR%app\musicmaster.jar
echo   - 数据目录: %SCRIPT_DIR%data
echo   - 日志目录: %SCRIPT_DIR%logs
echo   - 访问地址: http://localhost:8080
echo.
echo [提示] 按 Ctrl+C 停止服务
echo.

REM 启动应用
"%JAVA_CMD%" ^
    -Dspring.profiles.active=portable ^
    -Dspring.datasource.url="jdbc:h2:%SCRIPT_DIR%data\musicmaster;MODE=MySQL;DB_CLOSE_ON_EXIT=FALSE;AUTO_RECONNECT=TRUE" ^
    -Dfile.upload.path="%SCRIPT_DIR%uploads\" ^
    -Dfile.upload.music-path="%SCRIPT_DIR%uploads\music\" ^
    -Dfile.upload.image-path="%SCRIPT_DIR%uploads\image\" ^
    -jar "%SCRIPT_DIR%app\musicmaster.jar"

pause
