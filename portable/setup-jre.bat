@echo off
chcp 65001 >nul
REM =====================================================
REM MusicMaster - 便携式JRE下载脚本
REM 支持Windows系统
REM =====================================================

setlocal enabledelayedexpansion

set "SCRIPT_DIR=%~dp0"
cd /d "%SCRIPT_DIR%"

echo ========================================
echo     MusicMaster - JRE下载工具
echo ========================================
echo.

REM 检测系统架构
if "%PROCESSOR_ARCHITECTURE%"=="AMD64" (
    set "ARCH=x64"
) else (
    set "ARCH=x86"
)

echo [信息] 检测到系统架构: %ARCH%
echo.

REM 设置下载URL (Windows x64)
set "JRE_URL=https://github.com/adoptium/temurin21-binaries/releases/download/jdk-21.0.2%%2B13/OpenJDK21U-jre_x64_windows_hotspot_21.0.2_13.zip"
set "FILE_NAME=OpenJDK21U-jre_x64_windows_hotspot_21.0.2_13.zip"

echo [信息] 将下载JRE:
echo   - URL: %JRE_URL%
echo   - 文件: %FILE_NAME%
echo.

set /p confirm="是否继续下载？(y/n): "
if /i "%confirm%" neq "y" (
    echo 已取消
    pause
    exit /b 0
)

REM 检查是否有curl或powershell
where curl >nul 2>&1
if %errorlevel% equ 0 (
    echo.
    echo [信息] 正在使用curl下载JRE...
    curl -L -o "%TEMP%\%FILE_NAME%" "%JRE_URL%"
) else (
    echo.
    echo [信息] 正在使用PowerShell下载JRE...
    powershell -Command "Invoke-WebRequest -Uri '%JRE_URL%' -OutFile '%TEMP%\%FILE_NAME%'"
)

if not exist "%TEMP%\%FILE_NAME%" (
    echo [错误] 下载失败
    pause
    exit /b 1
)

REM 解压JRE
echo.
echo [信息] 正在解压JRE...

REM 创建临时目录
if exist "%SCRIPT_DIR%jre_temp" rmdir /s /q "%SCRIPT_DIR%jre_temp"
mkdir "%SCRIPT_DIR%jre_temp"

REM 使用PowerShell解压
powershell -Command "Expand-Archive -Path '%TEMP%\%FILE_NAME%' -DestinationPath '%SCRIPT_DIR%jre_temp' -Force"

REM 移动文件到jre目录
if exist "%SCRIPT_DIR%jre" rmdir /s /q "%SCRIPT_DIR%jre"

REM 找到解压后的目录并移动
for /d %%d in ("%SCRIPT_DIR%jre_temp\*") do (
    move "%%d" "%SCRIPT_DIR%jre" >nul
)

REM 清理
rmdir /s /q "%SCRIPT_DIR%jre_temp"
del "%TEMP%\%FILE_NAME%"

echo.
echo [成功] JRE安装完成！
echo [信息] 现在可以运行 start.bat 启动应用
pause
