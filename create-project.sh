#!/bin/bash

# 创建 EasyDarwin Docker 项目完整结构

PROJECT_DIR="easydarwin-docker"

echo "🚀 创建 EasyDarwin Docker 项目..."

# 创建目录结构
mkdir -p $PROJECT_DIR/{compose,scripts,docs,nginx,examples}

# 创建主 docker-compose.yml
cat > $PROJECT_DIR/docker-compose.yml << 'EOF'
version: '3.8'

services:
  easydarwin:
    image: cakeor/easydarwin:latest
    container_name: easydarwin
    restart: unless-stopped
    ports:
      - "8080:8080"
      - "554:554"
      - "1935:1935"
      - "4433:4433"
      - "5544:5544"
      - "8083:8083"
      - "8084:8084"
      - "1290:1290"
      - "30000-30100:30000-30100/udp"
      - "6001:6001/udp"
      - "4888:4888/udp"
    volumes:
      - ./data/configs:/app/configs
      - ./data/logs:/app/logs
      - ./data/web:/app/web
    environment:
      - TZ=Asia/Shanghai
      - LOG_LEVEL=info
    networks:
      - easydarwin-network
    healthcheck:
      test: ["CMD", "wget", "--quiet", "--tries=1", "--spider", "http://localhost:8080/api/v1/getserverinfo"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s

networks:
  easydarwin-network:
    driver: bridge
EOF

# 创建简化版 compose
cat > $PROJECT_DIR/compose/docker-compose.simple.yml << 'EOF'
version: '3.8'

services:
  easydarwin:
    image: cakeor/easydarwin:latest
    container_name: easydarwin-simple
    restart: unless-stopped
    ports:
      - "8080:8080"
      - "554:554"
      - "1935:1935"
    volumes:
      - ./data:/app/configs
    environment:
      - TZ=Asia/Shanghai
EOF

# 创建生产版 compose
cat > $PROJECT_DIR/compose/docker-compose.prod.yml << 'EOF'
version: '3.8'

services:
  easydarwin:
    image: cakeor/easydarwin:v8.3.3
    container_name: easydarwin-prod
    restart: always
    ports:
      - "8080:8080"
      - "554:554"
      - "1935:1935"
      - "4433:4433"
      - "5544:5544"
      - "8083:8083"
      - "8084:8084"
      - "1290:1290"
      - "30000-30100:30000-30100/udp"
      - "6001:6001/udp"
      - "4888:4888/udp"
    volumes:
      - easydarwin-configs:/app/configs
      - easydarwin-logs:/app/logs
      - easydarwin-data:/app/data
    environment:
      - TZ=Asia/Shanghai
      - LOG_LEVEL=warn
      - ENVIRONMENT=production
    networks:
      - easydarwin-network
    deploy:
      resources:
        limits:
          cpus: '2.0'
          memory: 1G
    healthcheck:
      test: ["CMD", "wget", "--quiet", "--tries=1", "--spider", "http://localhost:8080/api/v1/getserverinfo"]
      interval: 30s
      timeout: 10s
      retries: 5
      start_period: 60s
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"

  nginx:
    image: nginx:alpine
    container_name: easydarwin-nginx
    restart: always
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx/nginx.conf:/etc/nginx/nginx.conf:ro
      - ./nginx/ssl:/etc/nginx/ssl:ro
    depends_on:
      - easydarwin
    networks:
      - easydarwin-network

networks:
  easydarwin-network:
    driver: bridge

volumes:
  easydarwin-configs:
  easydarwin-logs:
  easydarwin-data:
EOF

# 创建启动脚本
cat > $PROJECT_DIR/scripts/start.sh << 'EOF'
#!/bin/bash

echo "🚀 启动 EasyDarwin 服务..."
mkdir -p data/{configs,logs,web}
docker-compose up -d

echo "⏳ 等待服务启动..."
sleep 10

if docker-compose ps | grep -q "Up"; then
    echo "✅ EasyDarwin 启动成功！"
    echo ""
    echo "📱 访问地址:"
    echo "  Web管理界面: http://localhost:8080"
    echo "  API文档:     http://localhost:8080/apidoc.html"
    echo ""
    echo "📋 常用命令:"
    echo "  查看日志: docker-compose logs -f"
    echo "  停止服务: docker-compose down"
    echo "  重启服务: docker-compose restart"
else
    echo "❌ 服务启动失败，请查看日志:"
    docker-compose logs
fi
EOF

# 创建管理脚本
cat > $PROJECT_DIR/scripts/manage.sh << 'EOF'
#!/bin/bash

COMPOSE_FILE="docker-compose.yml"

show_help() {
    echo "EasyDarwin 管理工具"
    echo ""
    echo "用法: $0 [命令]"
    echo ""
    echo "命令:"
    echo "  start     启动服务"
    echo "  stop      停止服务"
    echo "  restart   重启服务"
    echo "  status    查看状态"
    echo "  logs      查看日志"
    echo "  update    更新镜像"
    echo ""
}

case "$1" in
    start)
        echo "🚀 启动服务..."
        mkdir -p data/{configs,logs,web}
        docker-compose up -d
        ;;
    stop)
        echo "🛑 停止服务..."
        docker-compose down
        ;;
    restart)
        echo "🔄 重启服务..."
        docker-compose restart
        ;;
    status)
        echo "📊 服务状态:"
        docker-compose ps
        ;;
    logs)
        echo "📋 服务日志:"
        docker-compose logs -f
        ;;
    update)
        echo "🔄 更新镜像..."
        docker-compose pull
        docker-compose up -d --force-recreate
        ;;
    *)
        show_help
        ;;
esac
EOF

# 创建 Nginx 配置
cat > $PROJECT_DIR/nginx/nginx.conf << 'EOF'
events {
    worker_connections 1024;
}

http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;

    log_format main '$remote_addr - $remote_user [$time_local] "$request" '
                    '$status $body_bytes_sent "$http_referer" '
                    '"$http_user_agent"';

    access_log /var/log/nginx/access.log main;
    sendfile on;
    keepalive_timeout 65;

    upstream easydarwin {
        server easydarwin:8080;
    }

    server {
        listen 80;
        server_name localhost;

        location / {
            proxy_pass http://easydarwin;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
        }

        location /health {
            access_log off;
            return 200 "healthy\n";
            add_header Content-Type text/plain;
        }
    }
}
EOF

# 创建环境变量文件
cat > $PROJECT_DIR/.env.example << 'EOF'
# EasyDarwin 环境变量配置
COMPOSE_PROJECT_NAME=easydarwin
TZ=Asia/Shanghai
EASYDARWIN_IMAGE=cakeor/easydarwin:latest
WEB_PORT=8080
RTSP_PORT=554
RTMP_PORT=1935
LOG_LEVEL=info
DATA_DIR=./data
EOF

# 创建主 README
cat > $PROJECT_DIR/README.md << 'EOF'
# EasyDarwin Docker 部署方案

基于Docker和Docker Compose的EasyDarwin流媒体服务器完整部署方案。

## 🚀 快速开始

### 方法1：使用启动脚本
```bash
cd easydarwin-docker
chmod +x scripts/*.sh
./scripts/start.sh
```

### 方法2：手动启动
```bash
cd easydarwin-docker
mkdir -p data/{configs,logs,web}
docker-compose up -d
```

## 📁 项目结构

```
easydarwin-docker/
├── docker-compose.yml          # 主配置文件
├── compose/                    # 不同环境配置
│   ├── docker-compose.simple.yml
│   └── docker-compose.prod.yml
├── scripts/                    # 管理脚本
│   ├── start.sh               # 快速启动
│   └── manage.sh              # 管理工具
├── nginx/                     # Nginx配置
├── docs/                      # 文档
├── examples/                  # 示例配置
└── .env.example              # 环境变量模板
```

## 🔌 端口说明

| 端口 | 协议 | 用途 |
|------|------|------|
| 8080 | HTTP | Web管理界面 |
| 554 | TCP | RTSP服务 |
| 1935 | TCP | RTMP服务 |
| 4433/5544 | TCP | WebRTC |
| 8083/8084 | HTTP | API服务 |

## 🛠️ 管理命令

```bash
./scripts/manage.sh start      # 启动服务
./scripts/manage.sh stop       # 停止服务
./scripts/manage.sh status     # 查看状态
./scripts/manage.sh logs       # 查看日志
./scripts/manage.sh update     # 更新镜像
```

## 🌐 访问地址

- **Web管理界面**: http://localhost:8080
- **API文档**: http://localhost:8080/apidoc.html

## 📋 部署模式

### 简单模式
```bash
docker-compose -f compose/docker-compose.simple.yml up -d
```

### 生产模式
```bash
docker-compose -f compose/docker-compose.prod.yml up -d
```

## 🔧 配置

复制环境变量文件并修改：
```bash
cp .env.example .env
```

## 📊 监控

查看服务状态：
```bash
docker-compose ps
curl http://localhost:8080/api/v1/getserverinfo
```

## 🆘 故障排除

1. **端口冲突**: 修改docker-compose.yml中的端口映射
2. **权限问题**: `sudo chown -R $USER:$USER data/`
3. **查看日志**: `docker-compose logs easydarwin`

## 📞 支持

- **镜像地址**: https://hub.docker.com/r/cakeor/easydarwin
- **官方文档**: https://www.easydarwin.org
EOF

# 创建示例配置
cat > $PROJECT_DIR/examples/config.toml << 'EOF'
# EasyDarwin 配置文件示例

[server]
name = "EasyDarwin"
listen = ":8080"
debug = false

[rtsp]
enable = true
listen = ":554"

[rtmp]
enable = true
listen = ":1935"

[webrtc]
enable = true
signal_port = 4433
media_port = 5544

[log]
level = "info"
path = "/app/logs"
EOF

# 设置执行权限
chmod +x $PROJECT_DIR/scripts/*.sh

echo "✅ 项目创建完成！"
echo ""
echo "📁 项目目录: $PROJECT_DIR"
echo "🚀 快速启动: cd $PROJECT_DIR && ./scripts/start.sh"
echo "📖 查看文档: cat $PROJECT_DIR/README.md"
echo ""