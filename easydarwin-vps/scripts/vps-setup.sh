#!/bin/bash

# EasyDarwin VPS 部署脚本
# 适用于 Ubuntu 20.04+ / CentOS 8+ / Debian 11+

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
    echo -e "${BLUE}  EasyDarwin VPS 部署工具${NC}"
    echo -e "${BLUE}================================${NC}"
    echo ""
}

# 检测操作系统
detect_os() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$NAME
        VER=$VERSION_ID
    else
        print_error "无法检测操作系统"
        exit 1
    fi
    
    print_message "检测到操作系统: $OS $VER"
}

# 更新系统
update_system() {
    print_message "更新系统包..."
    
    if [[ $OS == *"Ubuntu"* ]] || [[ $OS == *"Debian"* ]]; then
        apt update && apt upgrade -y
        apt install -y curl wget git ufw fail2ban
    elif [[ $OS == *"CentOS"* ]] || [[ $OS == *"Red Hat"* ]]; then
        yum update -y
        yum install -y curl wget git firewalld fail2ban
    else
        print_warning "未知操作系统，请手动安装依赖"
    fi
}

# 安装 Docker
install_docker() {
    print_message "安装 Docker..."
    
    if command -v docker &> /dev/null; then
        print_message "Docker 已安装"
        return
    fi
    
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    rm get-docker.sh
    
    # 启动 Docker
    systemctl enable docker
    systemctl start docker
    
    # 添加当前用户到 docker 组
    usermod -aG docker $USER
    
    print_message "✅ Docker 安装完成"
}

# 安装 Docker Compose
install_docker_compose() {
    print_message "安装 Docker Compose..."
    
    if command -v docker-compose &> /dev/null; then
        print_message "Docker Compose 已安装"
        return
    fi
    
    # 获取最新版本
    DOCKER_COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep 'tag_name' | cut -d\" -f4)
    
    # 下载并安装
    curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
    
    # 创建软链接
    ln -sf /usr/local/bin/docker-compose /usr/bin/docker-compose
    
    print_message "✅ Docker Compose 安装完成"
}

# 配置防火墙
setup_firewall() {
    print_message "配置防火墙..."
    
    if [[ $OS == *"Ubuntu"* ]] || [[ $OS == *"Debian"* ]]; then
        # 使用 UFW
        ufw --force reset
        ufw default deny incoming
        ufw default allow outgoing
        
        # 允许 SSH
        ufw allow ssh
        ufw allow 22/tcp
        
        # 允许 HTTP/HTTPS
        ufw allow 80/tcp
        ufw allow 443/tcp
        
        # 允许流媒体端口
        ufw allow 554/tcp    # RTSP
        ufw allow 1935/tcp   # RTMP
        ufw allow 4433/tcp   # WebRTC
        ufw allow 5544/tcp   # WebRTC
        ufw allow 30000:30100/udp  # RTP
        ufw allow 6001/udp
        ufw allow 4888/udp
        
        # 启用防火墙
        ufw --force enable
        
    elif [[ $OS == *"CentOS"* ]] || [[ $OS == *"Red Hat"* ]]; then
        # 使用 firewalld
        systemctl enable firewalld
        systemctl start firewalld
        
        # 配置规则
        firewall-cmd --permanent --add-service=ssh
        firewall-cmd --permanent --add-service=http
        firewall-cmd --permanent --add-service=https
        firewall-cmd --permanent --add-port=554/tcp
        firewall-cmd --permanent --add-port=1935/tcp
        firewall-cmd --permanent --add-port=4433/tcp
        firewall-cmd --permanent --add-port=5544/tcp
        firewall-cmd --permanent --add-port=30000-30100/udp
        firewall-cmd --permanent --add-port=6001/udp
        firewall-cmd --permanent --add-port=4888/udp
        
        firewall-cmd --reload
    fi
    
    print_message "✅ 防火墙配置完成"
}

# 配置 Fail2Ban
setup_fail2ban() {
    print_message "配置 Fail2Ban..."
    
    # 创建 Nginx 配置
    cat > /etc/fail2ban/filter.d/nginx-limit-req.conf << 'EOF'
[Definition]
failregex = limiting requests, excess: .* by zone .*, client: <HOST>
ignoreregex =
EOF

    # 创建主配置
    cat > /etc/fail2ban/jail.local << 'EOF'
[DEFAULT]
bantime = 3600
findtime = 600
maxretry = 5
backend = auto

[sshd]
enabled = true
port = ssh
logpath = %(sshd_log)s
maxretry = 3

[nginx-http-auth]
enabled = true
port = http,https
logpath = /var/log/nginx/error.log

[nginx-limit-req]
enabled = true
port = http,https
logpath = /var/log/nginx/error.log
maxretry = 10

[nginx-botsearch]
enabled = true
port = http,https
logpath = /var/log/nginx/access.log
maxretry = 2
EOF

    # 启动 Fail2Ban
    systemctl enable fail2ban
    systemctl restart fail2ban
    
    print_message "✅ Fail2Ban 配置完成"
}

# 优化系统参数
optimize_system() {
    print_message "优化系统参数..."
    
    # 网络优化
    cat >> /etc/sysctl.conf << 'EOF'

# EasyDarwin 优化参数
net.core.rmem_max = 134217728
net.core.wmem_max = 134217728
net.ipv4.tcp_rmem = 4096 65536 134217728
net.ipv4.tcp_wmem = 4096 65536 134217728
net.core.netdev_max_backlog = 5000
net.ipv4.tcp_congestion_control = bbr
net.ipv4.tcp_slow_start_after_idle = 0
net.ipv4.tcp_tw_reuse = 1
fs.file-max = 65535
EOF

    sysctl -p
    
    # 文件描述符限制
    cat >> /etc/security/limits.conf << 'EOF'
* soft nofile 65535
* hard nofile 65535
EOF

    print_message "✅ 系统优化完成"
}

# 创建 SSL 目录和自签名证书（临时使用）
setup_ssl() {
    print_message "设置 SSL 证书..."
    
    mkdir -p ssl
    
    if [ ! -f ssl/cert.pem ] || [ ! -f ssl/key.pem ]; then
        print_warning "创建自签名证书（仅用于测试）"
        openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
            -keyout ssl/key.pem \
            -out ssl/cert.pem \
            -subj "/C=CN/ST=State/L=City/O=Organization/CN=localhost"
        
        print_warning "⚠️  请替换为正式的SSL证书！"
        print_message "建议使用 Let's Encrypt 获取免费证书"
    fi
}

# 创建环境变量文件
create_env_file() {
    print_message "创建环境变量文件..."
    
    if [ ! -f .env ]; then
        cat > .env << 'EOF'
# 域名配置
DOMAIN=your-domain.com

# 邮件通知配置（可选）
NOTIFICATION_EMAIL=admin@your-domain.com
SMTP_SERVER=smtp.gmail.com:587
SMTP_USER=your-email@gmail.com
SMTP_PASSWORD=your-app-password

# 时区
TZ=Asia/Shanghai

# 日志级别
LOG_LEVEL=warn
EOF
        
        print_warning "请编辑 .env 文件配置你的域名和邮件设置"
    fi
}

# 部署服务
deploy_services() {
    print_message "部署 EasyDarwin 服务..."
    
    # 拉取镜像
    docker-compose pull
    
    # 启动服务
    docker-compose up -d
    
    print_message "✅ 服务部署完成"
}

# 显示部署信息
show_deployment_info() {
    echo ""
    print_message "🎉 EasyDarwin VPS 部署完成！"
    echo ""
    echo "📱 访问地址:"
    echo "  HTTPS: https://your-domain.com"
    echo "  HTTP:  http://your-domain.com (会重定向到HTTPS)"
    echo ""
    echo "🔌 流媒体端口:"
    echo "  RTSP: rtsp://your-domain.com:554"
    echo "  RTMP: rtmp://your-domain.com:1935"
    echo ""
    echo "🛠️ 管理命令:"
    echo "  查看状态: docker-compose ps"
    echo "  查看日志: docker-compose logs -f"
    echo "  重启服务: docker-compose restart"
    echo "  停止服务: docker-compose down"
    echo ""
    echo "🔒 安全提醒:"
    echo "  1. 请替换自签名证书为正式SSL证书"
    echo "  2. 修改 .env 文件中的域名配置"
    echo "  3. 配置 EasyDarwin 的推流认证"
    echo "  4. 定期更新系统和容器镜像"
    echo ""
    echo "📋 下一步:"
    echo "  1. 编辑 .env 文件: nano .env"
    echo "  2. 配置域名解析指向此服务器IP"
    echo "  3. 获取正式SSL证书: ./scripts/setup-ssl.sh"
    echo "  4. 重启服务: docker-compose restart nginx"
    echo ""
}

# 主函数
main() {
    print_header
    
    # 检查是否为 root 用户
    if [ "$EUID" -ne 0 ]; then
        print_error "请使用 root 用户运行此脚本"
        exit 1
    fi
    
    detect_os
    update_system
    install_docker
    install_docker_compose
    setup_firewall
    setup_fail2ban
    optimize_system
    setup_ssl
    create_env_file
    deploy_services
    show_deployment_info
    
    print_message "重启系统以确保所有配置生效: reboot"
}

# 运行主函数
main "$@"