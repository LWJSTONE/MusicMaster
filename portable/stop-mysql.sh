#!/bin/bash
# =====================================================
# MusicMaster - 停止MySQL服务 (Linux/Mac)
# =====================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MYSQL_DIR="$SCRIPT_DIR/mysql"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}    停止 MySQL 服务${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# 检查MySQL是否在运行
if ! pgrep -f "mysqld.*--port=13306" > /dev/null; then
    echo -e "${YELLOW}[信息] MySQL未在运行${NC}"
    exit 0
fi

echo -e "${GREEN}[信息] 正在停止MySQL...${NC}"

# 使用mysqladmin优雅关闭
if [ -x "$MYSQL_DIR/bin/mysqladmin" ]; then
    "$MYSQL_DIR/bin/mysqladmin" -u root -P 13306 --socket="/tmp/mysql_musicmaster.sock" shutdown 2>/dev/null
    sleep 3
fi

# 检查是否还有MySQL进程
if pgrep -f "mysqld.*--port=13306" > /dev/null; then
    echo -e "${YELLOW}[警告] 优雅关闭失败，正在强制终止...${NC}"
    pkill -f "mysqld.*--port=13306"
fi

echo -e "${GREEN}[成功] MySQL已停止${NC}"
