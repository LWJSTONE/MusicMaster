@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

echo ============================================
echo   MusicMaster 运行环境安装工具
echo ============================================
echo.

set "RUNTIME_DIR=%~dp0"
set "JDK_DIR=%RUNTIME_DIR%jdk"
set "NODE_DIR=%RUNTIME_DIR%nodejs"
set "MAVEN_DIR=%RUNTIME_DIR%maven"

:: 创建目录
if not exist "%JDK_DIR%" mkdir "%JDK_DIR%"
if not exist "%NODE_DIR%" mkdir "%NODE_DIR%"
if not exist "%MAVEN_DIR%" mkdir "%MAVEN_DIR%"

echo [1/3] 检查 JDK 环境...
if exist "%JDK_DIR%\bin\java.exe" (
    echo     JDK 已安装
    "%JDK_DIR%\bin\java.exe" -version 2>&1 | findstr "version"
) else (
    echo     正在下载 JDK 8...
    echo     请稍候，这可能需要几分钟...
    
    :: 使用 PowerShell 下载 Adoptium JDK 8
    powershell -Command "& {[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; $url = 'https://github.com/adoptium/temurin8-binaries/releases/download/jdk8u402-b06/OpenJDK8U-jdk_x64_windows_hotspot_8u402b06.zip'; $output = '%RUNTIME_DIR%jdk.zip'; Write-Host '下载中...'; try { Invoke-WebRequest -Uri $url -OutFile $output -UseBasicParsing; Write-Host '下载完成，解压中...'; Expand-Archive -Path $output -DestinationPath '%RUNTIME_DIR%' -Force; Move-Item -Path '%RUNTIME_DIR%jdk8u402-b06' -Destination '%JDK_DIR%' -Force; Remove-Item $output -Force; Write-Host 'JDK 安装完成!' } catch { Write-Host '下载失败，请手动下载 JDK 8'; Write-Host '下载地址: https://adoptium.net/temurin/releases/?version=8' }}"
)

echo.
echo [2/3] 检查 Node.js 环境...
if exist "%NODE_DIR%\node.exe" (
    echo     Node.js 已安装
    "%NODE_DIR%\node.exe" -v
) else (
    echo     正在下载 Node.js 18...
    echo     请稍候，这可能需要几分钟...
    
    :: 使用 PowerShell 下载 Node.js
    powershell -Command "& {[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; $url = 'https://nodejs.org/dist/v18.20.0/node-v18.20.0-win-x64.zip'; $output = '%RUNTIME_DIR%node.zip'; Write-Host '下载中...'; try { Invoke-WebRequest -Uri $url -OutFile $output -UseBasicParsing; Write-Host '下载完成，解压中...'; Expand-Archive -Path $output -DestinationPath '%RUNTIME_DIR%' -Force; Move-Item -Path '%RUNTIME_DIR%node-v18.20.0-win-x64' -Destination '%NODE_DIR%' -Force; Remove-Item $output -Force; Write-Host 'Node.js 安装完成!' } catch { Write-Host '下载失败，请手动下载 Node.js 18'; Write-Host '下载地址: https://nodejs.org/' }}"
)

echo.
echo [3/3] 检查 Maven 环境...
if exist "%MAVEN_DIR%\bin\mvn.cmd" (
    echo     Maven 已安装
    call "%MAVEN_DIR%\bin\mvn.cmd" -version 2>&1 | findstr "Apache Maven"
) else (
    echo     正在下载 Maven...
    echo     请稍候...
    
    :: 使用 PowerShell 下载 Maven
    powershell -Command "& {[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; $url = 'https://dlcdn.apache.org/maven/maven-3/3.9.6/binaries/apache-maven-3.9.6-bin.zip'; $output = '%RUNTIME_DIR%maven.zip'; Write-Host '下载中...'; try { Invoke-WebRequest -Uri $url -OutFile $output -UseBasicParsing; Write-Host '下载完成，解压中...'; Expand-Archive -Path $output -DestinationPath '%RUNTIME_DIR%' -Force; Move-Item -Path '%RUNTIME_DIR%apache-maven-3.9.6' -Destination '%MAVEN_DIR%' -Force; Remove-Item $output -Force; Write-Host 'Maven 安装完成!' } catch { Write-Host '下载失败，请手动下载 Maven'; Write-Host '下载地址: https://maven.apache.org/download.cgi' }}"
)

echo.
echo ============================================
echo   环境安装检查完成
echo ============================================
echo.

:: 显示安装结果
echo 环境状态:
echo -----------
if exist "%JDK_DIR%\bin\java.exe" (
    echo [OK] JDK: 
    "%JDK_DIR%\bin\java.exe" -version 2>&1 | findstr "version"
) else (
    echo [X] JDK: 未安装
)

if exist "%NODE_DIR%\node.exe" (
    echo [OK] Node.js: 
    "%NODE_DIR%\node.exe" -v
) else (
    echo [X] Node.js: 未安装
)

if exist "%MAVEN_DIR%\bin\mvn.cmd" (
    echo [OK] Maven: 
    call "%MAVEN_DIR%\bin\mvn.cmd" -version 2>&1 | findstr "Apache Maven"
) else (
    echo [X] Maven: 未安装
)

echo.
echo 如有环境未安装成功，请手动下载并解压到 runtime 目录
echo.
pause
