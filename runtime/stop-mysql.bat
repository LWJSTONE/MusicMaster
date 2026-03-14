@echo off
chcp 65001 >nul
echo.
echo ============================================
echo   MySQL 便携版停止工具
echo ============================================
echo.
echo 正在停止 MySQL 服务...
taskkill /f /im mysqld.exe 2>nul
if errorlevel 1 (
    echo 没有找到运行中的 MySQL 服务
) else (
    echo MySQL 服务已停止
)
echo.
pause
