# EasyDarwin Docker Compose 部署指南

本文档提供了使用Docker Compose部署EasyDarwin的完整指南。

## 📁 文件说明

- `docker-compose.yml` - 基础版本，适合大多数用户
- `docker-compose.simple.yml` - 简化版本，最小配置
- `docker-compose.prod.yml` - 生产环境版本，包含监控和反向代理
- `docker-compose.dev.yml` - 开发环境版本，包含开发工具
- `nginx/nginx.conf` - Nginx反向代理配置

## 🚀 快速开始

### 方法1：基础部署

```bash
# 下载配置文件
wget https://raw.githubusercontent.com/your-repo/docker-compose.yml

# 创建数据目录
mkdir -p data/{configs,logs,web}

# 启动服务
docker-compose up -d

# 查看日志
docker-compose logs -f easydarwin
```

### 方法2：简化部署

```bash
# 使用简化版本
docker-compose -f docker-compose.simple.yml up -d
```

### 方法3：生产环境部署

```bash
# 使用生产环境配置
docker-compose -f docker-compose.prod.yml up -d
```

## 🔧 配置说明

### 端口映射

| 端口 | 协议 | 用途 |
|------|------|------|
| 8080 | HTTP | Web管理界面 |
| 554 | TCP | RTSP服务 |
| 1935 | TCP | RTMP服务 |
| 4433 | TCP | WebRTC信令 |
| 5544 | TCP | WebRTC媒体 |
| 8083 | HTTP | API服务 |
| 8084 | HTTP | 扩展API |
| 1290 | TCP | 其他服务 |
| 30000-30100 | UDP | RTP媒体传输 |
| 6001 | UDP | 媒体传输 |
| 4888 | UDP | 媒体传输 |

### 环境变量

| 变量名 | 默认值 | 说明 |
|--------|--------|------|
| TZ | Asia/Shanghai | 时区设置 |
| LOG_LEVEL | info | 日志级别 (debug/info/warn/error) |
| ENVIRONMENT | production | 运行环境 |

### 数据卷

| 容器路径 | 主机路径 | 用途 |
|----------|----------|------|
| /app/configs | ./data/configs | 配置文件 |
| /app/logs | ./data/logs | 日志文件 |
| /app/web | ./data/web | Web界面文件 |

## 📋 常用命令

### 启动服务

```bash
# 启动所有服务
docker-compose up -d

# 启动特定服务
docker-compose up -d easydarwin

# 查看服务状态
docker-compose ps

# 查看日志
docker-compose logs -f easydarwin
```

### 停止服务

```bash
# 停止所有服务
docker-compose down

# 停止并删除数据卷
docker-compose down -v

# 停止特定服务
docker-compose stop easydarwin
```

### 更新服务

```bash
# 拉取最新镜像
docker-compose pull

# 重新创建容器
docker-compose up -d --force-recreate

# 重启服务
docker-compose restart easydarwin
```

### 查看和管理

```bash
# 查看容器状态
docker-compose ps

# 查看资源使用情况
docker-compose top

# 进入容器
docker-compose exec easydarwin sh

# 查看配置
docker-compose config
```

## 🏗️ 不同环境配置

### 开发环境

```bash
# 启动开发环境（包含调试工具）
docker-compose -f docker-compose.dev.yml up -d

# 访问管理工具
# Portainer: http://localhost:9000
# Dozzle (日志查看): http://localhost:9999
```

### 生产环境

```bash
# 启动生产环境（包含Nginx和监控）
docker-compose -f docker-compose.prod.yml up -d

# 通过Nginx访问: http://localhost
# 直接访问EasyDarwin: http://localhost:8080
```

## 🔒 安全配置

### 1. 使用HTTPS

编辑 `nginx/nginx.conf`，取消HTTPS部分的注释，并准备SSL证书：

```bash
mkdir -p nginx/ssl
# 将证书文件放入 nginx/ssl/ 目录
```

### 2. 限制访问

在 `docker-compose.yml` 中修改端口映射，只暴露必要的端口：

```yaml
ports:
  - "127.0.0.1:8080:8080"  # 只允许本地访问
```

### 3. 防火墙配置

```bash
# 只允许特定端口
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw allow 554/tcp
sudo ufw allow 1935/tcp
```

## 🔧 故障排除

### 常见问题

1. **端口冲突**
   ```bash
   # 检查端口占用
   netstat -tulpn | grep :8080
   
   # 修改docker-compose.yml中的端口映射
   ```

2. **权限问题**
   ```bash
   # 修复数据目录权限
   sudo chown -R $USER:$USER data/
   ```

3. **容器无法启动**
   ```bash
   # 查看详细日志
   docker-compose logs easydarwin
   
   # 检查配置文件
   docker-compose config
   ```

4. **网络问题**
   ```bash
   # 重建网络
   docker-compose down
   docker network prune
   docker-compose up -d
   ```

### 性能优化

1. **资源限制**
   ```yaml
   deploy:
     resources:
       limits:
         cpus: '2.0'
         memory: 1G
   ```

2. **日志轮转**
   ```yaml
   logging:
     driver: "json-file"
     options:
       max-size: "10m"
       max-file: "3"
   ```

## 📊 监控和维护

### 健康检查

所有compose文件都包含健康检查配置：

```bash
# 查看健康状态
docker-compose ps
```

### 备份

```bash
# 备份配置和数据
tar -czf easydarwin-backup-$(date +%Y%m%d).tar.gz data/

# 恢复备份
tar -xzf easydarwin-backup-20231201.tar.gz
```

### 日志管理

```bash
# 查看日志大小
du -sh data/logs/

# 清理旧日志
find data/logs/ -name "*.log" -mtime +7 -delete
```

## 🌐 访问地址

部署完成后，可以通过以下地址访问：

- **Web管理界面**: http://localhost:8080
- **API文档**: http://localhost:8080/apidoc.html
- **健康检查**: http://localhost:8080/api/v1/getserverinfo

## 📞 支持

如有问题，请查看：
- [EasyDarwin官方文档](https://www.easydarwin.org)
- [Docker Hub页面](https://hub.docker.com/r/cakeor/easydarwin)
- [GitHub Issues](https://github.com/EasyDarwin/EasyDarwin/issues)