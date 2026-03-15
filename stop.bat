@echo off
REM =====================================================
REM MusicMaster 服务停止工具
REM ANSI编码兼容，纯ASCII字符
REM =====================================================

echo.
echo ==================================================================
echo   MusicMaster 服务停止工具
echo ==================================================================
echo.
echo 正在停止后端服务 (Java)...
taskkill /f /im java.exe 2>nul
if errorlevel 1 (
    echo     没有找到运行中的后端服务
) else (
    echo     后端服务已停止
)

echo.
echo 正在停止前端服务 (Node.js)...
taskkill /f /im node.exe 2>nul
if errorlevel 1 (
    echo     没有找到运行中的前端服务
) else (
    echo     前端服务已停止
)

echo.
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
