#!/bin/bash

# EasyDarwin Docker Compose 快速启动脚本

set -e

COMPOSE_FILE="docker-compose.yml"
PROJECT_NAME="easydarwin"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 打印带颜色的消息
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
    echo -e "${BLUE}  EasyDarwin Docker Compose${NC}"
    echo -e "${BLUE}================================${NC}"
    echo ""
}

# 检查Docker和Docker Compose
check_requirements() {
    print_message "检查系统要求..."
    
    if ! command -v docker &> /dev/null; then
        print_error "Docker 未安装，请先安装Docker"
        exit 1
    fi
    
    if ! command -v docker-compose &> /dev/null; then
        print_error "Docker Compose 未安装，请先安装Docker Compose"
        exit 1
    fi
    
    print_message "✅ Docker 和 Docker Compose 已安装"
}

# 创建必要的目录
create_directories() {
    print_message "创建数据目录..."
    
    mkdir -p data/{configs,logs,web}
    mkdir -p nginx/ssl
    
    print_message "✅ 目录创建完成"
}

# 选择部署模式
select_mode() {
    echo ""
    print_message "请选择部署模式:"
    echo "1) 简单模式 (最小配置)"
    echo "2) 标准模式 (推荐)"
    echo "3) 生产模式 (包含Nginx和监控)"
    echo "4) 开发模式 (包含开发工具)"
    echo ""
    
    read -p "请输入选择 (1-4): " choice
    
    case $choice in
        1)
            COMPOSE_FILE="docker-compose.simple.yml"
            print_message "选择了简单模式"
            ;;
        2)
            COMPOSE_FILE="docker-compose.yml"
            print_message "选择了标准模式"
            ;;
        3)
            COMPOSE_FILE="docker-compose.prod.yml"
            print_message "选择了生产模式"
            ;;
        4)
            COMPOSE_FILE="docker-compose.dev.yml"
            print_message "选择了开发模式"
            ;;
        *)
            print_warning "无效选择，使用标准模式"
            COMPOSE_FILE="docker-compose.yml"
            ;;
    esac
}

# 检查端口占用
check_ports() {
    print_message "检查端口占用..."
    
    PORTS=(8080 554 1935)
    OCCUPIED_PORTS=()
    
    for port in "${PORTS[@]}"; do
        if netstat -tuln 2>/dev/null | grep -q ":$port "; then
            OCCUPIED_PORTS+=($port)
        fi
    done
    
    if [ ${#OCCUPIED_PORTS[@]} -gt 0 ]; then
        print_warning "以下端口已被占用: ${OCCUPIED_PORTS[*]}"
        print_warning "请确保这些端口可用，或修改docker-compose文件中的端口映射"
        
        read -p "是否继续? (y/N): " continue_choice
        if [[ ! $continue_choice =~ ^[Yy]$ ]]; then
            print_message "部署已取消"
            exit 0
        fi
    else
        print_message "✅ 端口检查通过"
    fi
}

# 启动服务
start_services() {
    print_message "启动EasyDarwin服务..."
    
    # 拉取最新镜像
    docker-compose -f $COMPOSE_FILE pull
    
    # 启动服务
    docker-compose -f $COMPOSE_FILE up -d
    
    print_message "✅ 服务启动完成"
}

# 等待服务就绪
wait_for_service() {
    print_message "等待服务启动..."
    
    max_attempts=30
    attempt=0
    
    while [ $attempt -lt $max_attempts ]; do
        if curl -s http://localhost:8080/api/v1/getserverinfo > /dev/null 2>&1; then
            print_message "✅ 服务已就绪"
            return 0
        fi
        
        echo -n "."
        sleep 2
        ((attempt++))
    done
    
    print_warning "服务启动超时，请检查日志"
    return 1
}

# 显示访问信息
show_access_info() {
    echo ""
    print_message "🎉 EasyDarwin 部署完成!"
    echo ""
    print_message "访问地址:"
    echo "  Web管理界面: http://localhost:8080"
    echo "  API文档:     http://localhost:8080/apidoc.html"
    echo "  健康检查:   http://localhost:8080/api/v1/getserverinfo"
    echo ""
    
    if [ "$COMPOSE_FILE" = "docker-compose.prod.yml" ]; then
        print_message "Nginx反向代理: http://localhost"
    fi
    
    if [ "$COMPOSE_FILE" = "docker-compose.dev.yml" ]; then
        print_message "开发工具:"
        echo "  Portainer:   http://localhost:9000"
        echo "  Dozzle日志:  http://localhost:9999"
    fi
    
    echo ""
    print_message "常用命令:"
    echo "  查看状态: docker-compose -f $COMPOSE_FILE ps"
    echo "  查看日志: docker-compose -f $COMPOSE_FILE logs -f"
    echo "  停止服务: docker-compose -f $COMPOSE_FILE down"
    echo "  重启服务: docker-compose -f $COMPOSE_FILE restart"
    echo ""
}

# 主函数
main() {
    print_header
    
    # 检查要求
    check_requirements
    
    # 创建目录
    create_directories
    
    # 选择模式
    select_mode
    
    # 检查端口
    check_ports
    
    # 启动服务
    start_services
    
    # 等待服务就绪
    if wait_for_service; then
        show_access_info
    else
        print_error "服务启动失败，请查看日志:"
        echo "docker-compose -f $COMPOSE_FILE logs"
    fi
}

# 运行主函数
main "$@"