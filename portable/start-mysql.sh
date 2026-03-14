#!/bin/bash
# =====================================================
# MusicMaster - 启动MySQL服务 (Linux/Mac)
# =====================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"
MYSQL_DIR="$SCRIPT_DIR/mysql"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}    启动 MySQL 服务${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# 检查MySQL是否存在
if [ ! -x "$MYSQL_DIR/bin/mysqld" ]; then
    echo -e "${RED}[错误] MySQL未安装${NC}"
    echo -e "${YELLOW}[提示] 请先运行 ./setup-mysql.sh 安装MySQL${NC}"
    exit 1
fi

# 检查MySQL是否已运行
if pgrep -f "mysqld.*--port=13306" > /dev/null; then
    echo -e "${YELLOW}[信息] MySQL已经在运行中${NC}"
    exit 0
fi

echo -e "${GREEN}[信息] 正在启动MySQL...${NC}"
echo -e "${GREEN}[信息] 端口: 13306${NC}"
echo ""

# 启动MySQL
"$MYSQL_DIR/bin/mysqld_safe" \
    --defaults-file="$MYSQL_DIR/my.cnf" \
    --basedir="$MYSQL_DIR" \
    --datadir="$MYSQL_DIR/data" \
    --user="$(whoami)" \
    --port=13306 \
    --socket="/tmp/mysql_musicmaster.sock" \
    &

# 等待MySQL启动
echo -e "${GREEN}[信息] 等待MySQL启动...${NC}"
sleep 5

# 检查MySQL是否成功启动
if pgrep -f "mysqld.*--port=13306" > /dev/null; then
    echo -e "${GREEN}[成功] MySQL启动成功！${NC}"
else
    echo -e "${RED}[错误] MySQL启动失败${NC}"
    exit 1
fi
