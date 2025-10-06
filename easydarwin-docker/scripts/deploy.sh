#!/bin/bash

# EasyDarwin 部署脚本

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_message() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}  EasyDarwin Docker 部署工具${NC}"
    echo -e "${BLUE}================================${NC}"
    echo ""
}

# 检查Docker
check_docker() {
    if ! command -v docker &> /dev/null; then
        print_error "Docker 未安装"
        exit 1
    fi
    
    if ! command -v docker-compose &> /dev/null; then
        print_error "Docker Compose 未安装"
        exit 1
    fi
    
    print_message "✅ Docker 环境检查通过"
}

# 选择部署模式
select_mode() {
    echo ""
    print_message "请选择部署模式:"
    echo "1) 简单模式 (最小配置)"
    echo "2) 标准模式 (推荐)"
    echo "3) 生产模式 (包含Nginx)"
    echo "4) 开发模式 (包含工具)"
    echo ""
    
    read -p "请选择 (1-4): " choice
    
    case $choice in
        1) COMPOSE_FILE="compose/docker-compose.simple.yml" ;;
        2) COMPOSE_FILE="docker-compose.yml" ;;
        3) COMPOSE_FILE="compose/docker-compose.prod.yml" ;;
        4) COMPOSE_FILE="compose/docker-compose.dev.yml" ;;
        *) COMPOSE_FILE="docker-compose.yml" ;;
    esac
    
    print_message "选择了: $COMPOSE_FILE"
}

# 创建目录
create_dirs() {
    print_message "创建必要目录..."
    mkdir -p data/{configs,logs,web}
    mkdir -p nginx/ssl
    print_message "✅ 目录创建完成"
}

# 启动服务
start_services() {
    print_message "启动服务..."
    docker-compose -f $COMPOSE_FILE pull
    docker-compose -f $COMPOSE_FILE up -d
    print_message "✅ 服务启动完成"
}

# 显示访问信息
show_info() {
    echo ""
    print_message "🎉 部署完成！"
    echo ""
    echo "📱 访问地址:"
    echo "  Web界面: http://localhost:8080"
    echo "  API文档: http://localhost:8080/apidoc.html"
    echo ""
    echo "📋 管理命令:"
    echo "  查看状态: docker-compose -f $COMPOSE_FILE ps"
    echo "  查看日志: docker-compose -f $COMPOSE_FILE logs -f"
    echo "  停止服务: docker-compose -f $COMPOSE_FILE down"
    echo ""
}

# 主函数
main() {
    print_header
    check_docker
    select_mode
    create_dirs
    start_services
    show_info
}

main "$@"