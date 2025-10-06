#!/bin/bash

# SSL 证书配置脚本
# 支持 Let's Encrypt 自动获取免费证书

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

# 检查域名配置
check_domain() {
    if [ -f .env ]; then
        DOMAIN=$(grep "DOMAIN=" .env | cut -d'=' -f2)
        if [ "$DOMAIN" = "your-domain.com" ] || [ -z "$DOMAIN" ]; then
            print_error "请先在 .env 文件中配置正确的域名"
            exit 1
        fi
    else
        print_error "未找到 .env 文件"
        exit 1
    fi
    
    print_message "使用域名: $DOMAIN"
}

# 安装 Certbot
install_certbot() {
    print_message "安装 Certbot..."
    
    if command -v certbot &> /dev/null; then
        print_message "Certbot 已安装"
        return
    fi
    
    # 检测操作系统并安装
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$NAME
    fi
    
    if [[ $OS == *"Ubuntu"* ]] || [[ $OS == *"Debian"* ]]; then
        apt update
        apt install -y certbot python3-certbot-nginx
    elif [[ $OS == *"CentOS"* ]] || [[ $OS == *"Red Hat"* ]]; then
        yum install -y certbot python3-certbot-nginx
    else
        print_error "不支持的操作系统，请手动安装 Certbot"
        exit 1
    fi
    
    print_message "✅ Certbot 安装完成"
}

# 停止 Nginx 容器以释放 80 端口
stop_nginx() {
    print_message "临时停止 Nginx 容器..."
    docker-compose stop nginx || true
}

# 获取 Let's Encrypt 证书
get_letsencrypt_cert() {
    print_message "获取 Let's Encrypt 证书..."
    
    # 使用 standalone 模式获取证书
    certbot certonly \
        --standalone \
        --non-interactive \
        --agree-tos \
        --email admin@${DOMAIN} \
        --domains ${DOMAIN} \
        --keep-until-expiring
    
    if [ $? -eq 0 ]; then
        print_message "✅ 证书获取成功"
    else
        print_error "证书获取失败"
        exit 1
    fi
}

# 复制证书到项目目录
copy_certificates() {
    print_message "复制证书文件..."
    
    mkdir -p ssl
    
    # 复制证书文件
    cp /etc/letsencrypt/live/${DOMAIN}/fullchain.pem ssl/cert.pem
    cp /etc/letsencrypt/live/${DOMAIN}/privkey.pem ssl/key.pem
    
    # 设置权限
    chmod 644 ssl/cert.pem
    chmod 600 ssl/key.pem
    
    print_message "✅ 证书文件复制完成"
}

# 更新 Nginx 配置中的域名
update_nginx_config() {
    print_message "更新 Nginx 配置..."
    
    # 替换域名占位符
    sed -i "s/your-domain.com/${DOMAIN}/g" nginx/nginx.conf
    
    print_message "✅ Nginx 配置更新完成"
}

# 启动 Nginx 容器
start_nginx() {
    print_message "启动 Nginx 容器..."
    docker-compose up -d nginx
    
    # 等待服务启动
    sleep 5
    
    # 检查服务状态
    if docker-compose ps nginx | grep -q "Up"; then
        print_message "✅ Nginx 启动成功"
    else
        print_error "Nginx 启动失败"
        docker-compose logs nginx
        exit 1
    fi
}

# 设置证书自动续期
setup_auto_renewal() {
    print_message "设置证书自动续期..."
    
    # 创建续期脚本
    cat > /usr/local/bin/renew-ssl.sh << EOF
#!/bin/bash
# EasyDarwin SSL 证书续期脚本

cd $(pwd)

# 停止 Nginx
docker-compose stop nginx

# 续期证书
certbot renew --quiet

# 复制新证书
cp /etc/letsencrypt/live/${DOMAIN}/fullchain.pem ssl/cert.pem
cp /etc/letsencrypt/live/${DOMAIN}/privkey.pem ssl/key.pem
chmod 644 ssl/cert.pem
chmod 600 ssl/key.pem

# 重启 Nginx
docker-compose up -d nginx

echo "SSL 证书续期完成: \$(date)"
EOF

    chmod +x /usr/local/bin/renew-ssl.sh
    
    # 添加到 crontab（每月1号凌晨2点执行）
    (crontab -l 2>/dev/null; echo "0 2 1 * * /usr/local/bin/renew-ssl.sh >> /var/log/ssl-renewal.log 2>&1") | crontab -
    
    print_message "✅ 自动续期设置完成"
}

# 测试 HTTPS 访问
test_https() {
    print_message "测试 HTTPS 访问..."
    
    sleep 5
    
    if curl -s -k https://${DOMAIN}/health | grep -q "healthy"; then
        print_message "✅ HTTPS 访问测试成功"
    else
        print_warning "HTTPS 访问测试失败，请检查配置"
    fi
}

# 显示完成信息
show_completion_info() {
    echo ""
    print_message "🎉 SSL 证书配置完成！"
    echo ""
    echo "📱 访问地址:"
    echo "  HTTPS: https://${DOMAIN}"
    echo "  HTTP:  http://${DOMAIN} (自动重定向到HTTPS)"
    echo ""
    echo "🔒 SSL 信息:"
    echo "  证书提供商: Let's Encrypt"
    echo "  证书路径: ./ssl/"
    echo "  自动续期: 已配置（每月1号执行）"
    echo ""
    echo "🛠️ 管理命令:"
    echo "  手动续期: /usr/local/bin/renew-ssl.sh"
    echo "  查看证书: openssl x509 -in ssl/cert.pem -text -noout"
    echo "  测试SSL: curl -I https://${DOMAIN}"
    echo ""
    echo "📋 注意事项:"
    echo "  1. 证书有效期90天，已设置自动续期"
    echo "  2. 续期日志位于: /var/log/ssl-renewal.log"
    echo "  3. 如需手动续期，请先停止nginx容器"
    echo ""
}

# 主函数
main() {
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}  SSL 证书配置工具${NC}"
    echo -e "${BLUE}================================${NC}"
    echo ""
    
    # 检查是否为 root 用户
    if [ "$EUID" -ne 0 ]; then
        print_error "请使用 root 用户运行此脚本"
        exit 1
    fi
    
    check_domain
    install_certbot
    stop_nginx
    get_letsencrypt_cert
    copy_certificates
    update_nginx_config
    start_nginx
    setup_auto_renewal
    test_https
    show_completion_info
}

# 运行主函数
main "$@"