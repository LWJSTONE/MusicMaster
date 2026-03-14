#!/bin/bash
# =====================================================
# MusicMaster - 停止所有服务 (Linux/Mac)
# =====================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}    停止 MusicMaster 所有服务${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# 停止Java应用
echo -e "${YELLOW}[信息] 正在停止应用程序...${NC}"
if pgrep -f "musicmaster.jar" > /dev/null; then
    pkill -f "musicmaster.jar"
    echo -e "${GREEN}[成功] 应用程序已停止${NC}"
else
    echo -e "${YELLOW}[信息] 应用程序未在运行${NC}"
fi

# 停止MySQL
echo ""
echo -e "${YELLOW}[信息] 正在停止MySQL...${NC}"
./stop-mysql.sh

echo ""
echo -e "${GREEN}[完成] 所有服务已停止${NC}"
