@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

echo.
echo ╔══════════════════════════════════════════════════════╗
echo ║       MySQL 便携版安装工具                            ║
echo ╚══════════════════════════════════════════════════════╝
echo.

set "RUNTIME_DIR=%~dp0"
set "MYSQL_DIR=%RUNTIME_DIR%mysql"

if exist "%MYSQL_DIR%\bin\mysqld.exe" (
    echo MySQL 便携版已安装!
    echo 位置: %MYSQL_DIR%
    echo.
    goto :START_MYSQL
)

echo 正在下载 MySQL 8.0 便携版...
echo 请稍候，这可能需要几分钟...
echo.

:: 使用 PowerShell 下载 MySQL
powershell -Command "& {[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; $url = 'https://downloads.mysql.com/archives/get/p/23/file/mysql-8.0.36-winx64.zip'; $output = '%RUNTIME_DIR%mysql.zip'; Write-Host '下载中...'; try { Invoke-WebRequest -Uri $url -OutFile $output -UseBasicParsing; Write-Host '下载完成，解压中...'; Expand-Archive -Path $output -DestinationPath '%RUNTIME_DIR%' -Force; Rename-Item -Path '%RUNTIME_DIR%mysql-8.0.36-winx64' -NewName 'mysql' -Force; Remove-Item $output -Force; Write-Host 'MySQL 安装完成!' } catch { Write-Host '下载失败: ' $_.Exception.Message; Write-Host ''; Write-Host '请手动下载 MySQL 便携版:'; Write-Host '1. 访问: https://dev.mysql.com/downloads/mysql/'; Write-Host '2. 选择 Windows (x86, 64-bit), ZIP Archive'; Write-Host '3. 解压到 runtime\mysql 目录' }}"

if not exist "%MYSQL_DIR%\bin\mysqld.exe" (
    echo.
    echo MySQL 安装失败，请手动安装
    pause
    exit /b 1
)

:START_MYSQL

echo.
echo 正在初始化 MySQL 数据目录...
echo.

:: 创建数据目录
if not exist "%MYSQL_DIR%\data" (
    "%MYSQL_DIR%\bin\mysqld.exe" --initialize-insecure --basedir="%MYSQL_DIR%" --datadir="%MYSQL_DIR%\data"
    echo 数据目录初始化完成!
)

echo.
echo 正在启动 MySQL 服务...
echo.

:: 创建配置文件
if not exist "%MYSQL_DIR%\my.ini" (
    echo [mysqld] > "%MYSQL_DIR%\my.ini"
    echo basedir=%MYSQL_DIR% >> "%MYSQL_DIR%\my.ini"
    echo datadir=%MYSQL_DIR%\data >> "%MYSQL_DIR%\my.ini"
    echo port=3306 >> "%MYSQL_DIR%\my.ini"
    echo character-set-server=utf8mb4 >> "%MYSQL_DIR%\my.ini"
    echo default-storage-engine=INNODB >> "%MYSQL_DIR%\my.ini"
    echo. >> "%MYSQL_DIR%\my.ini"
    echo [client] >> "%MYSQL_DIR%\my.ini"
    echo port=3306 >> "%MYSQL_DIR%\my.ini"
    echo default-character-set=utf8mb4 >> "%MYSQL_DIR%\my.ini"
    echo 配置文件已创建
)

:: 启动MySQL
start "MySQL Server" "%MYSQL_DIR%\bin\mysqld.exe" --console

echo.
echo 等待 MySQL 启动...
timeout /t 5 /nobreak >nul

echo.
echo 设置 root 密码为 'root'...
"%MYSQL_DIR%\bin\mysql.exe" -u root -e "ALTER USER 'root'@'localhost' IDENTIFIED BY 'root'; FLUSH PRIVILEGES;" 2>nul

echo.
echo ╔══════════════════════════════════════════════════════╗
echo ║             MySQL 便携版已启动!                       ║
echo ╠══════════════════════════════════════════════════════╣
echo ║  连接信息:                                            ║
echo ║    主机: localhost                                    ║
echo ║    端口: 3306                                         ║
echo ║    用户: root                                         ║
echo ║    密码: root                                         ║
echo ╚══════════════════════════════════════════════════════╝
echo.
pause
