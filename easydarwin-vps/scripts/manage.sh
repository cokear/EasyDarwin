#!/bin/bash

# EasyDarwin VPS 管理脚本

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

# 显示帮助信息
show_help() {
    echo "EasyDarwin VPS 管理工具"
    echo ""
    echo "用法: $0 [命令] [选项]"
    echo ""
    echo "命令:"
    echo "  start         启动所有服务"
    echo "  stop          停止所有服务"
    echo "  restart       重启所有服务"
    echo "  status        查看服务状态"
    echo "  logs          查看日志"
    echo "  update        更新镜像"
    echo "  backup        备份数据"
    echo "  restore       恢复数据"
    echo "  monitor       系统监控"
    echo "  security      安全检查"
    echo "  ssl-renew     续期SSL证书"
    echo "  cleanup       清理系统"
    echo ""
    echo "选项:"
    echo "  -f, --follow  跟踪日志输出"
    echo "  -h, --help    显示帮助"
    echo ""
}

# 启动服务
start_services() {
    print_message "启动 EasyDarwin 服务..."
    docker-compose up -d
    
    # 等待服务启动
    sleep 10
    
    # 检查服务状态
    if docker-compose ps | grep -q "Up"; then
        print_message "✅ 服务启动成功"
        show_access_info
    else
        print_error "服务启动失败"
        docker-compose logs
    fi
}

# 停止服务
stop_services() {
    print_message "停止 EasyDarwin 服务..."
    docker-compose down
    print_message "✅ 服务已停止"
}

# 重启服务
restart_services() {
    print_message "重启 EasyDarwin 服务..."
    docker-compose restart
    
    sleep 5
    print_message "✅ 服务重启完成"
    show_access_info
}

# 查看服务状态
show_status() {
    print_message "服务状态:"
    docker-compose ps
    echo ""
    
    print_message "系统资源使用:"
    docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}"
    echo ""
    
    print_message "磁盘使用:"
    df -h | grep -E "(Filesystem|/dev/)"
    echo ""
    
    # 检查端口占用
    print_message "端口占用:"
    netstat -tlnp | grep -E ":(80|443|554|1935|4433|5544|8080) "
}

# 查看日志
show_logs() {
    if [ "$1" = "--follow" ] || [ "$1" = "-f" ]; then
        print_message "实时查看日志 (Ctrl+C 退出):"
        docker-compose logs -f --tail=100
    else
        print_message "最近日志:"
        docker-compose logs --tail=50
    fi
}

# 更新镜像
update_images() {
    print_message "更新 Docker 镜像..."
    
    # 拉取最新镜像
    docker-compose pull
    
    # 重新创建容器
    docker-compose up -d --force-recreate
    
    # 清理旧镜像
    docker image prune -f
    
    print_message "✅ 镜像更新完成"
}

# 备份数据
backup_data() {
    print_message "备份数据..."
    
    BACKUP_DIR="backups"
    BACKUP_FILE="easydarwin-backup-$(date +%Y%m%d-%H%M%S).tar.gz"
    
    mkdir -p $BACKUP_DIR
    
    # 创建备份
    docker run --rm \
        -v $(pwd):/backup \
        -v easydarwin-vps_easydarwin-configs:/data/configs \
        -v easydarwin-vps_easydarwin-logs:/data/logs \
        -v easydarwin-vps_easydarwin-data:/data/data \
        alpine:latest \
        tar -czf /backup/$BACKUP_DIR/$BACKUP_FILE -C /data .
    
    # 备份配置文件
    tar -czf $BACKUP_DIR/config-backup-$(date +%Y%m%d-%H%M%S).tar.gz \
        docker-compose.yml nginx/ ssl/ .env 2>/dev/null || true
    
    print_message "✅ 备份完成: $BACKUP_DIR/$BACKUP_FILE"
    
    # 清理旧备份（保留最近7个）
    ls -t $BACKUP_DIR/easydarwin-backup-*.tar.gz | tail -n +8 | xargs rm -f 2>/dev/null || true
}

# 恢复数据
restore_data() {
    if [ -z "$1" ]; then
        print_error "请指定备份文件: $0 restore <backup-file>"
        ls -la backups/
        exit 1
    fi
    
    BACKUP_FILE="$1"
    
    if [ ! -f "$BACKUP_FILE" ]; then
        print_error "备份文件不存在: $BACKUP_FILE"
        exit 1
    fi
    
    print_warning "恢复数据将覆盖现有数据，确认继续？(y/N)"
    read -r response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        print_message "操作已取消"
        exit 0
    fi
    
    print_message "恢复数据: $BACKUP_FILE"
    
    # 停止服务
    docker-compose down
    
    # 恢复数据
    docker run --rm \
        -v $(pwd):/backup \
        -v easydarwin-vps_easydarwin-configs:/data/configs \
        -v easydarwin-vps_easydarwin-logs:/data/logs \
        -v easydarwin-vps_easydarwin-data:/data/data \
        alpine:latest \
        tar -xzf /backup/$BACKUP_FILE -C /data
    
    # 重启服务
    docker-compose up -d
    
    print_message "✅ 数据恢复完成"
}

# 系统监控
system_monitor() {
    print_message "系统监控信息:"
    echo ""
    
    # 系统负载
    echo "系统负载:"
    uptime
    echo ""
    
    # 内存使用
    echo "内存使用:"
    free -h
    echo ""
    
    # 磁盘使用
    echo "磁盘使用:"
    df -h
    echo ""
    
    # 网络连接
    echo "网络连接:"
    ss -tuln | grep -E ":(80|443|554|1935|4433|5544|8080) "
    echo ""
    
    # Docker 资源使用
    echo "容器资源使用:"
    docker stats --no-stream
    echo ""
    
    # 最近的系统日志
    echo "最近的系统日志:"
    journalctl --since "1 hour ago" --no-pager -n 10
}

# 安全检查
security_check() {
    print_message "安全检查..."
    echo ""
    
    # 检查防火墙状态
    echo "防火墙状态:"
    if command -v ufw &> /dev/null; then
        ufw status
    elif command -v firewall-cmd &> /dev/null; then
        firewall-cmd --list-all
    fi
    echo ""
    
    # 检查 Fail2Ban 状态
    echo "Fail2Ban 状态:"
    if systemctl is-active --quiet fail2ban; then
        fail2ban-client status
    else
        print_warning "Fail2Ban 未运行"
    fi
    echo ""
    
    # 检查 SSL 证书
    echo "SSL 证书状态:"
    if [ -f ssl/cert.pem ]; then
        openssl x509 -in ssl/cert.pem -noout -dates
    else
        print_warning "SSL 证书不存在"
    fi
    echo ""
    
    # 检查开放端口
    echo "开放端口:"
    netstat -tlnp | grep LISTEN
    echo ""
    
    # 检查最近登录
    echo "最近登录:"
    last -n 5
}

# SSL 证书续期
renew_ssl() {
    print_message "续期 SSL 证书..."
    
    if [ -f /usr/local/bin/renew-ssl.sh ]; then
        /usr/local/bin/renew-ssl.sh
    else
        print_error "SSL 续期脚本不存在，请先运行 setup-ssl.sh"
        exit 1
    fi
}

# 系统清理
cleanup_system() {
    print_message "清理系统..."
    
    # 清理 Docker
    docker system prune -f
    docker volume prune -f
    
    # 清理日志
    journalctl --vacuum-time=7d
    
    # 清理临时文件
    find /tmp -type f -atime +7 -delete 2>/dev/null || true
    
    # 清理旧的备份文件（保留最近7个）
    if [ -d backups ]; then
        ls -t backups/easydarwin-backup-*.tar.gz | tail -n +8 | xargs rm -f 2>/dev/null || true
    fi
    
    print_message "✅ 系统清理完成"
}

# 显示访问信息
show_access_info() {
    if [ -f .env ]; then
        DOMAIN=$(grep "DOMAIN=" .env | cut -d'=' -f2)
        if [ "$DOMAIN" != "your-domain.com" ] && [ -n "$DOMAIN" ]; then
            echo ""
            print_message "访问地址:"
            echo "  HTTPS: https://$DOMAIN"
            echo "  HTTP:  http://$DOMAIN"
            echo ""
        fi
    fi
}

# 主函数
main() {
    case "$1" in
        start)
            start_services
            ;;
        stop)
            stop_services
            ;;
        restart)
            restart_services
            ;;
        status)
            show_status
            ;;
        logs)
            show_logs "$2"
            ;;
        update)
            update_images
            ;;
        backup)
            backup_data
            ;;
        restore)
            restore_data "$2"
            ;;
        monitor)
            system_monitor
            ;;
        security)
            security_check
            ;;
        ssl-renew)
            renew_ssl
            ;;
        cleanup)
            cleanup_system
            ;;
        -h|--help|help)
            show_help
            ;;
        *)
            show_help
            exit 1
            ;;
    esac
}

# 运行主函数
main "$@"