@echo off
REM =====================================================
REM MusicMaster 音乐管理系统 - 一键启动脚本
REM 使用ANSI编码兼容，纯ASCII字符
REM 内置环境，不影响系统环境
REM =====================================================

setlocal enabledelayedexpansion

title MusicMaster 音乐管理系统启动器

color 0A

echo.
echo +================================================================+
echo :                                                                :
echo :    M U S I C M A S T E R                                       :
echo :                                                                :
echo :    音乐管理系统 v1.0.0 - 一键启动工具                           :
echo :                                                                :
echo +================================================================+
echo.

:: 获取项目根目录（使用短路径避免空格问题）
set "PROJECT_ROOT=%~dp0"
set "RUNTIME_DIR=%PROJECT_ROOT%runtime"
set "JDK_DIR=%RUNTIME_DIR%\jdk"
set "NODE_DIR=%RUNTIME_DIR%\nodejs"
set "MAVEN_DIR=%RUNTIME_DIR%\maven"
set "MYSQL_DIR=%RUNTIME_DIR%\mysql"
set "BACKEND_DIR=%PROJECT_ROOT%backend"
set "FRONTEND_DIR=%PROJECT_ROOT%frontend"

:: ============ 显示菜单 ============
:MENU
echo.
echo ==================================================================
echo   请选择操作:
echo ==================================================================
echo.
echo   [1] 一键启动系统 (推荐)
echo   [2] 初始化数据库
echo   [3] 停止所有服务
echo   [4] 查看帮助文档
echo   [0] 退出
echo.
set /p CHOICE="请输入选项 (0-4): "

if "%CHOICE%"=="1" goto START_ALL
if "%CHOICE%"=="2" goto INIT_DB
if "%CHOICE%"=="3" goto STOP_ALL
if "%CHOICE%"=="4" goto HELP
if "%CHOICE%"=="0" goto END
echo.
echo 无效选项，请重新选择!
goto MENU

:: ============ 一键启动 ============
:START_ALL
cls
echo.
echo ==================================================================
echo   一键启动 MusicMaster 系统
echo ==================================================================

:: 步骤1: 检查并设置环境
echo.
echo [步骤 1/6] 检查运行环境...
echo ------------------------------------------------------------------

:: 检查JDK (使用局部环境变量，不影响系统)
if exist "%JDK_DIR%\bin\java.exe" (
    set "JAVA_HOME=%JDK_DIR%"
    set "LOCAL_PATH=%JDK_DIR%\bin"
    echo [OK] JDK 已就绪
) else (
    echo [X] JDK 未安装!
    echo     请将 JDK 8 解压到: %JDK_DIR%
    echo     下载地址: https://adoptium.net/temurin/releases/?version=8
    pause
    goto MENU
)

:: 检查Node.js
if exist "%NODE_DIR%\node.exe" (
    set "LOCAL_PATH=%LOCAL_PATH%;%NODE_DIR%"
    echo [OK] Node.js 已就绪
) else (
    echo [X] Node.js 未安装!
    echo     请将 Node.js 18 解压到: %NODE_DIR%
    echo     下载地址: https://nodejs.org/
    pause
    goto MENU
)

:: 检查Maven
if exist "%MAVEN_DIR%\bin\mvn.cmd" (
    set "MAVEN_HOME=%MAVEN_DIR%"
    set "LOCAL_PATH=%LOCAL_PATH%;%MAVEN_DIR%\bin"
    echo [OK] Maven 已就绪
) else (
    echo [X] Maven 未安装!
    echo     请将 Maven 解压到: %MAVEN_DIR%
    echo     下载地址: https://maven.apache.org/download.cgi
    pause
    goto MENU
)

:: 步骤2: 检查MySQL
echo.
echo [步骤 2/6] 检查数据库连接...
echo ------------------------------------------------------------------

:: 检查MySQL是否运行
tasklist /fi "imagename eq mysqld.exe" 2>nul | find /i "mysqld.exe" >nul
if errorlevel 1 (
    echo [!] MySQL 未运行

    :: 检查是否有便携版MySQL
    if exist "%MYSQL_DIR%\bin\mysqld.exe" (
        echo [i] 检测到 MySQL 便携版，正在启动...
        start "MySQL Server" "%MYSQL_DIR%\bin\mysqld.exe" --console
        echo 等待 MySQL 启动...
        timeout /t 8 /nobreak >nul
    ) else (
        echo [!] 请确保 MySQL 服务已启动
        echo     或将 MySQL 解压到: %MYSQL_DIR%
        echo.
        set /p MYSQL_CONFIRM="MySQL 是否已在其他位置运行? (Y/N): "
        if /i not "!MYSQL_CONFIRM!"=="Y" (
            pause
            goto MENU
        )
    )
) else (
    echo [OK] MySQL 已运行
)

:: 步骤3: 安装前端依赖
echo.
echo [步骤 3/6] 检查前端依赖...
echo ------------------------------------------------------------------
cd /d "%FRONTEND_DIR%"

if exist "node_modules" (
    echo [OK] 前端依赖已安装
) else (
    echo 正在安装前端依赖...
    echo 使用淘宝镜像加速下载...
    set "PATH=%LOCAL_PATH%;%PATH%"
    call npm config set registry https://registry.npmmirror.com
    call npm install
    if errorlevel 1 (
        echo [X] 前端依赖安装失败!
        pause
        goto MENU
    )
    echo [OK] 前端依赖安装完成
)

:: 步骤4: 构建后端
echo.
echo [步骤 4/6] 构建后端项目...
echo ------------------------------------------------------------------
cd /d "%BACKEND_DIR%"

if exist "target\musicmaster-backend-1.0.0.jar" (
    echo [OK] 后端已构建
) else (
    echo 首次运行，正在构建后端项目...
    echo 这可能需要几分钟，请耐心等待...
    set "PATH=%LOCAL_PATH%;%PATH%"
    call "%MAVEN_DIR%\bin\mvn.cmd" clean package -DskipTests -q
    if errorlevel 1 (
        echo [X] 后端构建失败!
        pause
        goto MENU
    )
    echo [OK] 后端构建完成
)

:: 步骤5: 启动后端
echo.
echo [步骤 5/6] 启动后端服务...
echo ------------------------------------------------------------------
cd /d "%BACKEND_DIR%"
start "MusicMaster Backend" cmd /c ""%JDK_DIR%\bin\java.exe" -jar target\musicmaster-backend-1.0.0.jar"
echo [OK] 后端服务启动中... (端口: 8080)
echo 等待后端服务就绪...
timeout /t 12 /nobreak >nul

:: 步骤6: 启动前端
echo.
echo [步骤 6/6] 启动前端服务...
echo ------------------------------------------------------------------
cd /d "%FRONTEND_DIR%"
start "MusicMaster Frontend" cmd /c ""%NODE_DIR%\node.exe" node_modules\@vue\cli-service\bin\vue-cli-service.js serve --port 8081"
echo [OK] 前端服务启动中... (端口: 8081)
echo 等待前端服务就绪...
timeout /t 15 /nobreak >nul

echo.
echo +================================================================+
echo :                                                                :
echo :                  启 动 成 功 !                                  :
echo :                                                                :
echo +================================================================+
echo.
echo   前端访问地址: http://localhost:8081
echo   后端 API 地址: http://localhost:8080/api
echo.
echo   默认管理员账号: admin
echo   默认管理员密码: admin123
echo.

:: 自动打开浏览器
echo 正在打开浏览器...
timeout /t 3 /nobreak >nul
start http://localhost:8081

echo.
echo 系统已启动成功!
echo 关闭此窗口不会影响服务运行
echo 如需停止服务，请选择菜单选项 [3] 或关闭后端/前端窗口
echo.
pause
goto MENU

:: ============ 初始化数据库 ============
:INIT_DB
cls
echo.
echo ==================================================================
echo   初始化数据库
echo ==================================================================
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
    goto MENU
)

echo.
echo [步骤 1/2] 测试 MySQL 连接...
echo.

:: 检查是否有便携版MySQL
if exist "%MYSQL_DIR%\bin\mysql.exe" (
    set "MYSQL_CMD=%MYSQL_DIR%\bin\mysql.exe"
) else (
    set "MYSQL_CMD=mysql"
)

:: 测试MySQL连接
"%MYSQL_CMD%" -h%MYSQL_HOST% -P%MYSQL_PORT% -u%MYSQL_USER% -p%MYSQL_PASSWORD% -e "SELECT 1;" >nul 2>&1
if errorlevel 1 (
    echo [X] MySQL 连接失败!
    echo.
    echo 请检查:
    echo 1. MySQL 服务是否已启动
    echo 2. 用户名和密码是否正确
    echo 3. MySQL 是否允许本地连接
    echo.
    pause
    goto MENU
)

echo [OK] MySQL 连接成功

echo.
echo [步骤 2/2] 导入数据库结构...
echo.

:: 执行SQL文件
set "SQL_FILE=%PROJECT_ROOT%backend\src\main\resources\sql\init.sql"

if not exist "%SQL_FILE%" (
    echo [X] SQL文件不存在: %SQL_FILE%
    pause
    goto MENU
)

echo 正在导入: %SQL_FILE%
echo.

"%MYSQL_CMD%" -h%MYSQL_HOST% -P%MYSQL_PORT% -u%MYSQL_USER% -p%MYSQL_PASSWORD% < "%SQL_FILE%"

if errorlevel 1 (
    echo [X] 数据库导入失败!
    pause
    goto MENU
)

echo.
echo +================================================================+
echo :             数据库初始化完成!                                   :
echo +================================================================+
echo.
echo   数据库名: musicmaster
echo   管理员账号: admin
echo   管理员密码: admin123 (数据库中加密存储)
echo.
pause
goto MENU

:: ============ 停止所有服务 ============
:STOP_ALL
cls
echo.
echo ==================================================================
echo   停止所有服务
echo ==================================================================
echo.
echo 正在停止后端服务 (Java)...
taskkill /f /im java.exe 2>nul
if errorlevel 1 (
    echo     没有找到运行中的后端服务
) else (
    echo     后端服务已停止
)

echo 正在停止前端服务 (Node.js)...
taskkill /f /im node.exe 2>nul
if errorlevel 1 (
    echo     没有找到运行中的前端服务
) else (
    echo     前端服务已停止
)

echo 正在停止 MySQL 服务...
taskkill /f /im mysqld.exe 2>nul
if errorlevel 1 (
    echo     没有找到运行中的 MySQL 服务
) else (
    echo     MySQL 服务已停止
)

echo.
echo ==================================================================
echo   所有服务已停止
echo ==================================================================
echo.
pause
goto MENU

:: ============ 帮助文档 ============
:HELP
cls
echo.
echo ==================================================================
echo   MusicMaster 使用帮助
echo ==================================================================
echo.
echo  【快速开始】
echo   1. 首次使用请确保以下环境已安装到 runtime 目录:
echo      - runtime\jdk        (JDK 8)
echo      - runtime\nodejs     (Node.js 18)
echo      - runtime\maven      (Maven 3.9+)
echo      - runtime\mysql      (MySQL 8.0，可选)
echo.
echo   2. 环境下载地址:
echo      - JDK 8:    https://adoptium.net/temurin/releases/?version=8
echo      - Node.js:  https://nodejs.org/
echo      - Maven:    https://maven.apache.org/download.cgi
echo      - MySQL:    https://dev.mysql.com/downloads/mysql/
echo.
echo   3. 运行步骤:
echo      - 选择 [2] 初始化数据库
echo      - 选择 [1] 一键启动系统
echo.
echo  【系统要求】
echo   - Windows 10/11 (64位)
echo   - 至少 4GB 可用内存
echo   - 至少 2GB 可用磁盘空间
echo.
echo  【端口占用】
echo   - 前端端口: 8081
echo   - 后端端口: 8080
echo   - MySQL端口: 3306
echo   如端口被占用，请先关闭占用程序或修改配置
echo.
echo  【默认账号】
echo   - 管理员: admin / admin123
echo   - 登录后请及时修改密码
echo.
echo  【环境隔离说明】
echo   本脚本使用内置运行环境，不会修改系统环境变量
echo   所有环境变量仅在脚本运行期间有效
echo.
echo ==================================================================
echo.
pause
goto MENU

:: ============ 退出 ============
:END
echo.
echo 感谢使用 MusicMaster 音乐管理系统!
echo.
timeout /t 2 /nobreak >nul
exit /b 0
