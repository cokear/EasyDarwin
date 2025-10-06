#!/bin/bash

# EasyDarwin 管理脚本

COMPOSE_FILE="docker-compose.yml"

# 显示帮助
show_help() {
    echo "EasyDarwin 管理工具"
    echo ""
    echo "用法: $0 [命令] [选项]"
    echo ""
    echo "命令:"
    echo "  start     启动服务"
    echo "  stop      停止服务"
    echo "  restart   重启服务"
    echo "  status    查看状态"
    echo "  logs      查看日志"
    echo "  update    更新镜像"
    echo "  clean     清理资源"
    echo ""
    echo "选项:"
    echo "  -f FILE   指定compose文件"
    echo "  -h        显示帮助"
    echo ""
}

# 启动服务
start_service() {
    echo "🚀 启动 EasyDarwin 服务..."
    mkdir -p data/{configs,logs,web}
    docker-compose -f $COMPOSE_FILE up -d
    echo "✅ 服务已启动"
}

# 停止服务
stop_service() {
    echo "🛑 停止 EasyDarwin 服务..."
    docker-compose -f $COMPOSE_FILE down
    echo "✅ 服务已停止"
}

# 重启服务
restart_service() {
    echo "🔄 重启 EasyDarwin 服务..."
    docker-compose -f $COMPOSE_FILE restart
    echo "✅ 服务已重启"
}

# 查看状态
show_status() {
    echo "📊 服务状态:"
    docker-compose -f $COMPOSE_FILE ps
}

# 查看日志
show_logs() {
    echo "📋 服务日志:"
    docker-compose -f $COMPOSE_FILE logs -f --tail=100
}

# 更新镜像
update_service() {
    echo "🔄 更新 EasyDarwin 镜像..."
    docker-compose -f $COMPOSE_FILE pull
    docker-compose -f $COMPOSE_FILE up -d --force-recreate
    echo "✅ 更新完成"
}

# 清理资源
clean_resources() {
    echo "🧹 清理 Docker 资源..."
    docker-compose -f $COMPOSE_FILE down -v
    docker system prune -f
    echo "✅ 清理完成"
}

# 解析参数
while getopts "f:h" opt; do
    case $opt in
        f) COMPOSE_FILE="$OPTARG" ;;
        h) show_help; exit 0 ;;
        *) show_help; exit 1 ;;
    esac
done

shift $((OPTIND-1))

# 执行命令
case "$1" in
    start) start_service ;;
    stop) stop_service ;;
    restart) restart_service ;;
    status) show_status ;;
    logs) show_logs ;;
    update) update_service ;;
    clean) clean_resources ;;
    *) show_help ;;
esac