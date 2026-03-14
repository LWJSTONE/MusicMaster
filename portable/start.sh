#!/bin/bash
# =====================================================
# MusicMaster 音乐管理系统 - 一键启动脚本
# 支持Linux和Mac系统
# =====================================================

# 获取脚本所在目录的绝对路径
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}    MusicMaster 音乐管理系统${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# 检查端口是否被占用
check_port() {
    if lsof -Pi :8080 -sTCP:LISTEN -t >/dev/null 2>&1; then
        echo -e "${YELLOW}警告: 端口8080已被占用${NC}"
        echo -e "${YELLOW}请关闭占用该端口的程序后重试${NC}"
        read -p "是否继续启动？(y/n): " continue_choice
        if [[ ! "$continue_choice" =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
}

# 查找Java命令
find_java() {
    # 优先使用内置JRE
    if [ -x "$SCRIPT_DIR/jre/bin/java" ]; then
        echo "$SCRIPT_DIR/jre/bin/java"
        return 0
    fi
    
    # 检查JAVA_HOME环境变量
    if [ -n "$JAVA_HOME" ] && [ -x "$JAVA_HOME/bin/java" ]; then
        echo "$JAVA_HOME/bin/java"
        return 0
    fi
    
    # 检查系统PATH中的java
    if command -v java &> /dev/null; then
        echo "java"
        return 0
    fi
    
    return 1
}

# 检查Java版本
check_java_version() {
    local java_cmd="$1"
    local version=$("$java_cmd" -version 2>&1 | head -n 1 | cut -d'"' -f2 | cut -d'.' -f1)
    
    if [ "$version" -ge 11 ]; then
        echo -e "${GREEN}Java版本: $($java_cmd -version 2>&1 | head -n 1)${NC}"
        return 0
    else
        echo -e "${RED}Java版本过低，需要Java 11或更高版本${NC}"
        return 1
    fi
}

# 检查端口
check_port

# 查找Java
JAVA_CMD=$(find_java)

if [ -z "$JAVA_CMD" ]; then
    echo -e "${RED}错误: 未找到Java运行环境${NC}"
    echo ""
    echo -e "${YELLOW}请执行以下步骤之一:${NC}"
    echo "1. 安装Java 11或更高版本"
    echo "2. 运行 ./setup-jre.sh 下载便携式JRE"
    echo ""
    echo "下载Java: https://adoptium.net/"
    exit 1
fi

# 检查Java版本
if ! check_java_version "$JAVA_CMD"; then
    exit 1
fi

echo ""
echo -e "${GREEN}正在启动MusicMaster...${NC}"
echo ""

# 创建必要的目录
mkdir -p "$SCRIPT_DIR/data"
mkdir -p "$SCRIPT_DIR/uploads/music"
mkdir -p "$SCRIPT_DIR/uploads/image"
mkdir -p "$SCRIPT_DIR/logs"

# 启动应用
echo -e "${BLUE}启动参数:${NC}"
echo "  - 应用路径: $SCRIPT_DIR/app/musicmaster.jar"
echo "  - 数据目录: $SCRIPT_DIR/data"
echo "  - 日志目录: $SCRIPT_DIR/logs"
echo "  - 访问地址: http://localhost:8080"
echo ""
echo -e "${YELLOW}提示: 按 Ctrl+C 停止服务${NC}"
echo ""

# 使用便携式配置运行
"$JAVA_CMD" \
    -Dspring.profiles.active=portable \
    -Dspring.datasource.url="jdbc:h2:$SCRIPT_DIR/data/musicmaster;MODE=MySQL;DB_CLOSE_ON_EXIT=FALSE;AUTO_RECONNECT=TRUE" \
    -Dfile.upload.path="$SCRIPT_DIR/uploads/" \
    -Dfile.upload.music-path="$SCRIPT_DIR/uploads/music/" \
    -Dfile.upload.image-path="$SCRIPT_DIR/uploads/image/" \
    -jar "$SCRIPT_DIR/app/musicmaster.jar"
