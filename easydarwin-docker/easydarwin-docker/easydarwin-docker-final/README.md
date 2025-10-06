# EasyDarwin Docker 部署方案

基于Docker和Docker Compose的EasyDarwin流媒体服务器完整部署方案。

## 🚀 快速开始

### 方法1：使用启动脚本（推荐）
```bash
cd easydarwin-docker-final
./scripts/start.sh
```

### 方法2：手动启动
```bash
cd easydarwin-docker-final
mkdir -p data/{configs,logs,web}
docker-compose up -d
```

## 📁 项目结构

```
easydarwin-docker-final/
├── docker-compose.yml          # 主配置文件
├── compose/                    # 不同环境配置
├── scripts/                    # 管理脚本
│   └── start.sh               # 快速启动
├── nginx/                     # Nginx配置
├── docs/                      # 文档
├── examples/                  # 示例配置
└── README.md                  # 本文件
```

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

```bash
# 启动服务
docker-compose up -d

# 停止服务
docker-compose down

# 查看状态
docker-compose ps

# 查看日志
docker-compose logs -f

# 重启服务
docker-compose restart

# 更新镜像
docker-compose pull && docker-compose up -d --force-recreate
```

## 🌐 访问地址

- **Web管理界面**: http://localhost:8080
- **API文档**: http://localhost:8080/apidoc.html
- **健康检查**: http://localhost:8080/api/v1/getserverinfo

## 🔧 配置说明

### 数据持久化
- 配置文件：`./data/configs`
- 日志文件：`./data/logs`
- Web文件：`./data/web`

### 环境变量
- `TZ`: 时区设置（默认：Asia/Shanghai）
- `LOG_LEVEL`: 日志级别（默认：info）

## 📊 监控

服务包含健康检查，可通过以下方式监控：

```bash
# 检查容器状态
docker-compose ps

# 检查服务健康
curl http://localhost:8080/api/v1/getserverinfo

# 查看资源使用
docker stats easydarwin
```

## 🆘 故障排除

### 常见问题

1. **端口冲突**
   ```bash
   # 检查端口占用
   netstat -tulpn | grep :8080
   # 修改 docker-compose.yml 中的端口映射
   ```

2. **权限问题**
   ```bash
   sudo chown -R $USER:$USER data/
   ```

3. **容器无法启动**
   ```bash
   # 查看详细日志
   docker-compose logs easydarwin
   
   # 检查配置
   docker-compose config
   ```

4. **网络问题**
   ```bash
   # 重建网络
   docker-compose down
   docker network prune
   docker-compose up -d
   ```

## 🔒 安全建议

1. **生产环境**：修改默认端口和配置
2. **防火墙**：只开放必要的端口
3. **认证**：启用推流和管理认证
4. **SSL**：配置HTTPS访问

## 📞 支持

- **Docker Hub**: https://hub.docker.com/r/cakeor/easydarwin
- **官方文档**: https://www.easydarwin.org
- **GitHub**: https://github.com/EasyDarwin/EasyDarwin

## 📝 版本信息

- EasyDarwin: v8.3.3
- Docker Compose: 3.8
- 创建时间: 2023-12-01
