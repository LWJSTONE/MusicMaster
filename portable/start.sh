#!/bin/bash
# =====================================================
# MusicMaster 音乐管理系统 - 一键启动脚本 (Linux/Mac)
# 使用便携式MySQL数据库
# =====================================================

# 获取脚本所在目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"
MYSQL_DIR="$SCRIPT_DIR/mysql"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║               MusicMaster 音乐管理系统                        ║${NC}"
echo -e "${BLUE}║                  便携版 - 一键启动                           ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""

# 检查MySQL是否已安装
if [ ! -x "$MYSQL_DIR/bin/mysqld" ]; then
    echo -e "${YELLOW}[警告] MySQL便携版未安装${NC}"
    echo ""
    echo "请选择:"
    echo "  1. 运行 ./setup-mysql.sh 下载并安装MySQL便携版"
    echo "  2. 使用系统已安装的MySQL (需要手动创建数据库)"
    echo ""
    read -p "请输入选择 (1/2): " choice
    
    case $choice in
        1)
            ./setup-mysql.sh
            if [ $? -ne 0 ]; then
                echo -e "${RED}[错误] MySQL安装失败${NC}"
                exit 1
            fi
            ;;
        2)
            echo -e "${GREEN}[信息] 将使用系统MySQL，请确保数据库已创建${NC}"
            ;;
        *)
            echo -e "${RED}[错误] 无效的选择${NC}"
            exit 1
            ;;
    esac
fi

# 启动MySQL
echo -e "${GREEN}[步骤 1/2] 启动MySQL数据库...${NC}"
./start-mysql.sh
if [ $? -ne 0 ]; then
    echo -e "${RED}[错误] MySQL启动失败${NC}"
    exit 1
fi

echo ""

# 检查应用JAR是否存在
if [ ! -f "$SCRIPT_DIR/app/musicmaster.jar" ]; then
    echo -e "${RED}[错误] 应用程序不存在${NC}"
    echo -e "${YELLOW}[提示] 请将编译好的JAR文件复制到: $SCRIPT_DIR/app/musicmaster.jar${NC}"
    echo ""
    echo "构建方法:"
    echo "  cd backend"
    echo "  mvn clean package -DskipTests"
    echo "  复制 target/musicmaster-backend-1.0.0.jar 到 portable/app/musicmaster.jar"
    ./stop-mysql.sh
    exit 1
fi

# 查找Java命令
find_java() {
    if [ -x "$SCRIPT_DIR/jre/bin/java" ]; then
        echo "$SCRIPT_DIR/jre/bin/java"
        return 0
    fi
    if [ -n "$JAVA_HOME" ] && [ -x "$JAVA_HOME/bin/java" ]; then
        echo "$JAVA_HOME/bin/java"
        return 0
    fi
    if command -v java &> /dev/null; then
        echo "java"
        return 0
    fi
    return 1
}

JAVA_CMD=$(find_java)
if [ -z "$JAVA_CMD" ]; then
    echo -e "${RED}[错误] 未找到Java运行环境${NC}"
    echo -e "${YELLOW}[提示] 请安装Java 8或更高版本${NC}"
    echo "下载地址: https://adoptium.net/"
    ./stop-mysql.sh
    exit 1
fi

echo -e "${GREEN}[步骤 2/2] 启动应用程序...${NC}"
echo ""

# 创建必要的目录
mkdir -p "$SCRIPT_DIR/data"
mkdir -p "$SCRIPT_DIR/uploads/music"
mkdir -p "$SCRIPT_DIR/uploads/image"
mkdir -p "$SCRIPT_DIR/logs"

echo -e "${BLUE}========================================${NC}"
echo "启动参数:"
echo "  - 应用路径: $SCRIPT_DIR/app/musicmaster.jar"
echo "  - MySQL端口: 13306"
echo "  - Web端口: 8080"
echo -e "${BLUE}========================================${NC}"
echo ""
echo -e "${GREEN}访问地址: http://localhost:8080${NC}"
echo -e "${GREEN}默认账号: admin${NC}"
echo -e "${GREEN}默认密码: 123456${NC}"
echo ""
echo -e "${YELLOW}[提示] 按 Ctrl+C 停止服务${NC}"
echo ""

# 捕获退出信号，确保MySQL被停止
trap 'echo ""; echo "[信息] 正在停止MySQL..."; ./stop-mysql.sh; exit 0' SIGINT SIGTERM

# 启动应用
"$JAVA_CMD" -jar "$SCRIPT_DIR/app/musicmaster.jar"

# 应用停止后，停止MySQL
echo ""
echo "[信息] 正在停止MySQL..."
./stop-mysql.sh
