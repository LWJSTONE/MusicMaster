@echo off
chcp 65001 >nul
REM =====================================================
REM MusicMaster - 便携式MySQL下载和配置脚本 (Windows)
REM =====================================================

setlocal enabledelayedexpansion

set "SCRIPT_DIR=%~dp0"
cd /d "%SCRIPT_DIR%"

echo ========================================
echo     MusicMaster - MySQL便携版配置工具
echo ========================================
echo.

REM 设置MySQL版本
set "MYSQL_VERSION=8.0.33"
set "MYSQL_DIR=%SCRIPT_DIR%mysql"

REM 检查是否已存在MySQL
if exist "%MYSQL_DIR%\bin\mysqld.exe" (
    echo [信息] MySQL已存在于此目录
    set /p reinstall="是否重新下载安装？(y/n): "
    if /i "!reinstall!" neq "y" (
        echo [信息] 跳过下载
        goto :init_database
    )
)

echo [信息] 将下载MySQL %MYSQL_VERSION% 便携版
echo [信息] 目标目录: %MYSQL_DIR%
echo.

REM 检查curl或powershell
where curl >nul 2>&1
if %errorlevel% equ 0 (
    set "DOWNLOAD_CMD=curl -L -o"
) else (
    set "DOWNLOAD_CMD=powershell -Command Invoke-WebRequest -Uri"
)

REM 创建临时目录
if not exist "%SCRIPT_DIR%temp" mkdir "%SCRIPT_DIR%temp"

REM 下载MySQL ZIP
set "MYSQL_URL=https://downloads.mysql.com/archives/get/p/23/file/mysql-%MYSQL_VERSION%-winx64.zip"
set "MYSQL_ZIP=%SCRIPT_DIR%temp\mysql.zip"

echo [步骤 1/4] 下载MySQL...
echo URL: %MYSQL_URL%
echo 这可能需要几分钟，请耐心等待...
echo.

if "%DOWNLOAD_CMD%"=="curl -L -o" (
    curl -L -o "%MYSQL_ZIP%" "%MYSQL_URL%"
) else (
    powershell -Command "Invoke-WebRequest -Uri '%MYSQL_URL%' -OutFile '%MYSQL_ZIP%'"
)

if not exist "%MYSQL_ZIP%" (
    echo [错误] MySQL下载失败
    echo [提示] 请手动下载MySQL ZIP包并解压到 %MYSQL_DIR%
    echo 下载地址: https://dev.mysql.com/downloads/mysql/
    pause
    exit /b 1
)

echo.
echo [步骤 2/4] 解压MySQL...

REM 删除旧目录
if exist "%MYSQL_DIR%" rmdir /s /q "%MYSQL_DIR%"

REM 解压
powershell -Command "Expand-Archive -Path '%MYSQL_ZIP%' -DestinationPath '%SCRIPT_DIR%temp\mysql_extract' -Force"

REM 移动文件
for /d %%d in ("%SCRIPT_DIR%temp\mysql_extract\*") do (
    move "%%d" "%MYSQL_DIR%" >nul
)

REM 清理临时文件
rmdir /s /q "%SCRIPT_DIR%temp"

echo [步骤 3/4] 配置MySQL...

REM 创建data目录
if not exist "%MYSQL_DIR%\data" mkdir "%MYSQL_DIR%\data"

REM 创建my.ini配置文件
echo [mysqld] > "%MYSQL_DIR%\my.ini"
echo port=13306 >> "%MYSQL_DIR%\my.ini"
echo basedir=%MYSQL_DIR:\=/% >> "%MYSQL_DIR%\my.ini"
echo datadir=%MYSQL_DIR%\data\:/ >> "%MYSQL_DIR%\my.ini"
echo max_connections=200 >> "%MYSQL_DIR%\my.ini"
echo max_connect_errors=100 >> "%MYSQL_DIR%\my.ini"
echo character-set-server=utf8mb4 >> "%MYSQL_DIR%\my.ini"
echo collation-server=utf8mb4_unicode_ci >> "%MYSQL_DIR%\my.ini"
echo default-storage-engine=INNODB >> "%MYSQL_DIR%\my.ini"
echo default_authentication_plugin=mysql_native_password >> "%MYSQL_DIR%\my.ini"
echo. >> "%MYSQL_DIR%\my.ini"
echo [client] >> "%MYSQL_DIR%\my.ini"
echo port=13306 >> "%MYSQL_DIR%\my.ini"
echo default-character-set=utf8mb4 >> "%MYSQL_DIR%\my.ini"

echo [步骤 4/4] 初始化MySQL...

REM 初始化MySQL（无密码）
cd /d "%MYSQL_DIR%\bin"
mysqld --initialize-insecure --user=root --console

if %errorlevel% neq 0 (
    echo [错误] MySQL初始化失败
    pause
    exit /b 1
)

echo.
echo ========================================
echo [成功] MySQL便携版安装完成！
echo ========================================
echo.
echo MySQL目录: %MYSQL_DIR%
echo MySQL端口: 13306
echo 默认用户: root
echo 默认密码: (空)
echo.
echo 接下来请运行: init-database.bat 初始化数据库
echo.

pause
