@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

title MusicMaster 音乐管理系统启动器

color 0A

echo.
echo ╔════════════════════════════════════════════════════════════════╗
echo ║                                                                ║
echo ║   ██████╗ ███╗   ███╗██╗██╗  ██╗ ██████╗ ███╗   ███╗███████╗   ║
echo ║  ██╔════╝ ████╗ ████║██║██║ ██╔╝██╔════╝ ████╗ ████║██╔════╝   ║
echo ║  ██║  ███╗██╔████╔██║██║█████╔╝ ██║  ███╗██╔████╔██║█████╗     ║
echo ║  ██║   ██║██║╚██╔╝██║██║██╔═██╗ ██║   ██║██║╚██╔╝██║██╔══╝     ║
echo ║  ╚██████╔╝██║ ╚═╝ ██║██║██║  ██╗╚██████╔╝██║ ╚═╝ ██║███████╗   ║
echo ║   ╚═════╝ ╚═╝     ╚═╝╚═╝╚═╝  ╚═╝ ╚═════╝ ╚═╝     ╚═╝╚══════╝   ║
echo ║                                                                ║
echo ║           音乐管理系统 v1.0.0 - 一键启动工具                    ║
echo ╚════════════════════════════════════════════════════════════════╝
echo.

:: 获取项目根目录
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
echo ══════════════════════════════════════════════════════════════════
echo   请选择操作:
echo ══════════════════════════════════════════════════════════════════
echo.
echo   [1] 一键启动系统 (推荐)
echo   [2] 安装运行环境 (JDK/Node.js/Maven)
echo   [3] 安装 MySQL 便携版
echo   [4] 初始化数据库
echo   [5] 启动 MySQL 便携版
echo   [6] 停止所有服务
echo   [7] 查看帮助文档
echo   [0] 退出
echo.
set /p CHOICE="请输入选项 (0-7): "

if "%CHOICE%"=="1" goto START_ALL
if "%CHOICE%"=="2" goto INSTALL_ENV
if "%CHOICE%"=="3" goto INSTALL_MYSQL
if "%CHOICE%"=="4" goto INIT_DB
if "%CHOICE%"=="5" goto START_MYSQL
if "%CHOICE%"=="6" goto STOP_ALL
if "%CHOICE%"=="7" goto HELP
if "%CHOICE%"=="0" goto END
echo.
echo 无效选项，请重新选择!
goto MENU

:: ============ 一键启动 ============
:START_ALL
cls
echo.
echo ══════════════════════════════════════════════════════════════════
echo   一键启动 MusicMaster 系统
echo ══════════════════════════════════════════════════════════════════

:: 步骤1: 检查并设置环境
echo.
echo [步骤 1/6] 检查运行环境...
echo ────────────────────────────────────────────────────────────────

:: 设置环境变量
if exist "%JDK_DIR%\bin\java.exe" (
    set "JAVA_HOME=%JDK_DIR%"
    set "PATH=%JDK_DIR%\bin;%PATH%"
    echo [OK] JDK 已就绪
) else (
    echo [X] JDK 未安装! 请先运行选项 [2] 安装环境
    pause
    goto MENU
)

if exist "%NODE_DIR%\node.exe" (
    set "PATH=%NODE_DIR%;%PATH%"
    echo [OK] Node.js 已就绪
) else (
    echo [X] Node.js 未安装! 请先运行选项 [2] 安装环境
    pause
    goto MENU
)

if exist "%MAVEN_DIR%\bin\mvn.cmd" (
    set "MAVEN_HOME=%MAVEN_DIR%"
    set "PATH=%MAVEN_DIR%\bin;%PATH%"
    echo [OK] Maven 已就绪
) else (
    echo [X] Maven 未安装! 请先运行选项 [2] 安装环境
    pause
    goto MENU
)

:: 步骤2: 检查MySQL
echo.
echo [步骤 2/6] 检查数据库连接...
echo ────────────────────────────────────────────────────────────────

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
        echo [!] 请确保 MySQL 服务已启动，或运行选项 [3] 安装 MySQL 便携版
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
echo ────────────────────────────────────────────────────────────────
cd /d "%FRONTEND_DIR%"

if exist "node_modules" (
    echo [OK] 前端依赖已安装
) else (
    echo 正在安装前端依赖...
    echo 使用淘宝镜像加速下载...
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
echo ────────────────────────────────────────────────────────────────
cd /d "%BACKEND_DIR%"

if exist "target\musicmaster-backend-1.0.0.jar" (
    echo [OK] 后端已构建
) else (
    echo 首次运行，正在构建后端项目...
    echo 这可能需要几分钟，请耐心等待...
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
echo ────────────────────────────────────────────────────────────────
cd /d "%BACKEND_DIR%"
start "MusicMaster Backend" cmd /c ""%JDK_DIR%\bin\java.exe" -jar target\musicmaster-backend-1.0.0.jar"
echo [OK] 后端服务启动中... (端口: 8080)
echo 等待后端服务就绪...
timeout /t 12 /nobreak >nul

:: 步骤6: 启动前端
echo.
echo [步骤 6/6] 启动前端服务...
echo ────────────────────────────────────────────────────────────────
cd /d "%FRONTEND_DIR%"
start "MusicMaster Frontend" cmd /c ""%NODE_DIR%\node.exe" node_modules\@vue\cli-service\bin\vue-cli-service.js serve --port 8081"
echo [OK] 前端服务启动中... (端口: 8081)
echo 等待前端服务就绪...
timeout /t 15 /nobreak >nul

echo.
echo ╔════════════════════════════════════════════════════════════════╗
echo ║                                                                ║
echo ║   ███████╗██╗   ██╗███████╗███╗   ██╗████████╗                ║
echo ║   ██╔════╝██║   ██║██╔════╝████╗  ██║╚══██╔══╝                ║
echo ║   ███████╗██║   ██║█████╗  ██╔██╗ ██║   ██║                   ║
echo ║   ╚════██║██║   ██║██╔══╝  ██║╚██╗██║   ██║                   ║
echo ║   ███████║╚██████╔╝███████╗██║ ╚████║   ██║                   ║
echo ║   ╚══════╝ ╚═════╝ ╚══════╝╚═╝  ╚═══╝   ╚═╝                   ║
echo ║                                                                ║
echo ╠════════════════════════════════════════════════════════════════╣
echo ║                                                                ║
echo ║   前端访问地址: http://localhost:8081                          ║
echo ║   后端 API 地址: http://localhost:8080/api                     ║
echo ║                                                                ║
echo ║   默认管理员账号: admin                                        ║
echo ║   默认管理员密码: admin123                                      ║
echo ║                                                                ║
echo ╚════════════════════════════════════════════════════════════════╝
echo.

:: 自动打开浏览器
echo 正在打开浏览器...
timeout /t 3 /nobreak >nul
start http://localhost:8081

echo.
echo 系统已启动成功!
echo 关闭此窗口不会影响服务运行
echo 如需停止服务，请选择菜单选项 [6] 或关闭后端/前端窗口
echo.
pause
goto MENU

:: ============ 安装环境 ============
:INSTALL_ENV
cls
echo.
echo ══════════════════════════════════════════════════════════════════
echo   安装运行环境
echo ══════════════════════════════════════════════════════════════════
call "%RUNTIME_DIR%\install-env.bat"
goto MENU

:: ============ 安装MySQL ============
:INSTALL_MYSQL
cls
echo.
echo ══════════════════════════════════════════════════════════════════
echo   安装 MySQL 便携版
echo ══════════════════════════════════════════════════════════════════
call "%RUNTIME_DIR%\install-mysql.bat"
goto MENU

:: ============ 初始化数据库 ============
:INIT_DB
cls
echo.
echo ══════════════════════════════════════════════════════════════════
echo   初始化数据库
echo ══════════════════════════════════════════════════════════════════
call "%PROJECT_ROOT%init-database.bat"
goto MENU

:: ============ 启动MySQL ============
:START_MYSQL
cls
echo.
echo ══════════════════════════════════════════════════════════════════
echo   启动 MySQL 便携版
echo ══════════════════════════════════════════════════════════════════

if not exist "%MYSQL_DIR%\bin\mysqld.exe" (
    echo [X] MySQL 便携版未安装! 请先运行选项 [3] 安装
    pause
    goto MENU
)

:: 检查是否已运行
tasklist /fi "imagename eq mysqld.exe" 2>nul | find /i "mysqld.exe" >nul
if not errorlevel 1 (
    echo [!] MySQL 已在运行中
    pause
    goto MENU
)

start "MySQL Server" "%MYSQL_DIR%\bin\mysqld.exe" --console
echo [OK] MySQL 服务启动中...
timeout /t 5 /nobreak >nul
echo.
echo MySQL 便携版已启动!
echo 连接信息: localhost:3306, 用户: root, 密码: root
echo.
pause
goto MENU

:: ============ 停止所有服务 ============
:STOP_ALL
cls
echo.
echo ══════════════════════════════════════════════════════════════════
echo   停止所有服务
echo ══════════════════════════════════════════════════════════════════
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
echo ══════════════════════════════════════════════════════════════════
echo   所有服务已停止
echo ══════════════════════════════════════════════════════════════════
echo.
pause
goto MENU

:: ============ 帮助文档 ============
:HELP
cls
echo.
echo ══════════════════════════════════════════════════════════════════
echo   MusicMaster 使用帮助
echo ══════════════════════════════════════════════════════════════════
echo.
echo  【快速开始】
echo   1. 首次使用请按顺序执行:
echo      - 选择 [2] 安装运行环境 (JDK, Node.js, Maven)
echo      - 选择 [3] 安装 MySQL 便携版 (或使用已有MySQL)
echo      - 选择 [4] 初始化数据库
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
echo  【常见问题】
echo   Q: 环境安装失败?
echo   A: 请检查网络连接，或手动下载安装包到 runtime 目录
echo.
echo   Q: 数据库连接失败?
echo   A: 确保 MySQL 服务已启动，用户名密码正确
echo.
echo   Q: 前端页面空白?
echo   A: 检查后端服务是否正常启动，查看浏览器控制台错误
echo.
echo ══════════════════════════════════════════════════════════════════
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
