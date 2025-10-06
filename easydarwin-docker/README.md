# EasyDarwin Docker 部署方案

基于Docker和Docker Compose的EasyDarwin流媒体服务器完整部署方案。

## 📁 项目结构

```
easydarwin-docker/
├── docker-compose.yml          # 主配置文件
├── compose/                    # 不同环境的compose文件
│   ├── docker-compose.simple.yml
│   ├── docker-compose.prod.yml
│   └── docker-compose.dev.yml
├── scripts/                    # 管理脚本
│   ├── start.sh               # 快速启动
│   ├── deploy.sh              # 部署脚本
│   └── manage.sh              # 管理工具
├── nginx/                     # Nginx配置
│   └── nginx.conf
├── docs/                      # 文档
├── examples/                  # 示例配置
├── .env.example              # 环境变量模板
└── README.md                 # 本文件
```

## 🚀 快速开始

### 方法1：使用部署脚本（推荐）
```bash
cd easydarwin-docker
chmod +x scripts/*.sh
./scripts/deploy.sh
```

### 方法2：手动启动
```bash
cd easydarwin-docker
mkdir -p data/{configs,logs,web}
docker-compose up -d
```

### 方法3：使用管理脚本
```bash
# 启动服务
./scripts/manage.sh start

# 查看状态
./scripts/manage.sh status

# 查看日志
./scripts/manage.sh logs
```

## 🎯 部署模式

### 1. 简单模式
```bash
docker-compose -f compose/docker-compose.simple.yml up -d
```
- 最小配置，只暴露核心端口
- 适合快速测试

### 2. 标准模式
```bash
docker-compose up -d
```
- 完整功能，推荐使用
- 包含健康检查和数据持久化

### 3. 生产模式
```bash
docker-compose -f compose/docker-compose.prod.yml up -d
```
- 包含Nginx反向代理
- 资源限制和日志轮转
- 适合生产环境

### 4. 开发模式
```bash
docker-compose -f compose/docker-compose.dev.yml up -d
```
- 包含开发工具
- Portainer容器管理
- Dozzle日志查看

## 🔌 端口说明

| 端口 | 协议 | 用途 |
|------|------|------|
| 8080 | HTTP | Web管理界面 |
| 554 | TCP | RTSP服务 |
| 1935 | TCP | RTMP服务 |
| 4433/5544 | TCP | WebRTC |
| 8083/8084 | HTTP | API服务 |
| 30000-30100 | UDP | RTP传输 |

## 🛠️ 管理命令

### 使用管理脚本
```bash
./scripts/manage.sh start      # 启动服务
./scripts/manage.sh stop       # 停止服务
./scripts/manage.sh restart    # 重启服务
./scripts/manage.sh status     # 查看状态
./scripts/manage.sh logs       # 查看日志
./scripts/manage.sh update     # 更新镜像
./scripts/manage.sh clean      # 清理资源
```

### 直接使用Docker Compose
```bash
docker-compose up -d           # 启动
docker-compose down            # 停止
docker-compose ps              # 状态
docker-compose logs -f         # 日志
docker-compose pull            # 更新镜像
```

## 🔧 配置说明

### 环境变量
复制 `.env.example` 为 `.env` 并修改配置：
```bash
cp .env.example .env
```

### 自定义配置
- 配置文件：`data/configs/`
- 日志文件：`data/logs/`
- Web文件：`data/web/`

## 🌐 访问地址

- **Web管理界面**: http://localhost:8080
- **API文档**: http://localhost:8080/apidoc.html
- **健康检查**: http://localhost:8080/api/v1/getserverinfo

### 开发模式额外地址
- **Portainer**: http://localhost:9000
- **Dozzle日志**: http://localhost:9999

### 生产模式
- **Nginx代理**: http://localhost

## 📊 监控和维护

### 健康检查
```bash
docker-compose ps
curl http://localhost:8080/api/v1/getserverinfo
```

### 日志管理
```bash
# 查看日志
docker-compose logs -f easydarwin

# 清理日志
docker-compose down
docker system prune -f
```

### 备份数据
```bash
tar -czf easydarwin-backup-$(date +%Y%m%d).tar.gz data/
```

## 🔒 安全配置

### 1. 端口限制
只暴露必要端口：
```yaml
ports:
  - "127.0.0.1:8080:8080"  # 只允许本地访问
```

### 2. SSL配置
在生产模式中配置SSL证书：
```bash
mkdir -p nginx/ssl
# 将证书文件放入 nginx/ssl/ 目录
```

### 3. 防火墙
```bash
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw allow 554/tcp
sudo ufw allow 1935/tcp
```

## 🆘 故障排除

### 常见问题

1. **端口冲突**
   ```bash
   netstat -tulpn | grep :8080
   # 修改docker-compose.yml中的端口映射
   ```

2. **权限问题**
   ```bash
   sudo chown -R $USER:$USER data/
   ```

3. **容器无法启动**
   ```bash
   docker-compose logs easydarwin
   docker-compose config
   ```

4. **网络问题**
   ```bash
   docker network ls
   docker network prune
   ```

### 性能优化

1. **资源限制**（生产模式已配置）
2. **日志轮转**（生产模式已配置）
3. **缓存配置**（Nginx已配置）

## 📞 支持

- **镜像地址**: https://hub.docker.com/r/cakeor/easydarwin
- **官方文档**: https://www.easydarwin.org
- **问题反馈**: GitHub Issues

## 📝 更新日志

- v1.0.0: 初始版本，支持多种部署模式
- 基于 EasyDarwin v8.3.3
- 支持 Docker Compose 3.8