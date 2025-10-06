# EasyDarwin Docker Compose

基于Docker Compose的EasyDarwin流媒体服务器部署方案。

## 🚀 快速开始

### 1. 一键启动
```bash
./start.sh
```

### 2. 手动启动
```bash
# 创建数据目录
mkdir -p data/{configs,logs,web}

# 启动服务
docker-compose up -d

# 查看状态
docker-compose ps
```

## 📋 服务信息

- **镜像**: `cakeor/easydarwin:latest`
- **Web界面**: http://localhost:8080
- **API文档**: http://localhost:8080/apidoc.html

## 🔌 端口说明

| 端口 | 协议 | 用途 |
|------|------|------|
| 8080 | HTTP | Web管理界面 |
| 554 | TCP | RTSP服务 |
| 1935 | TCP | RTMP服务 |
| 4433/5544 | TCP | WebRTC |
| 8083/8084 | HTTP | API服务 |
| 30000-30100 | UDP | RTP传输 |

## 📁 目录结构

```
.
├── docker-compose.yml    # 主配置文件
├── start.sh             # 启动脚本
├── data/                # 数据目录
│   ├── configs/         # 配置文件
│   ├── logs/           # 日志文件
│   └── web/            # Web文件
```

## 🛠️ 常用命令

```bash
# 启动服务
docker-compose up -d

# 停止服务
docker-compose down

# 查看日志
docker-compose logs -f

# 重启服务
docker-compose restart

# 更新镜像
docker-compose pull && docker-compose up -d --force-recreate
```

## 🔧 配置修改

编辑 `data/configs/config.toml` 文件来修改EasyDarwin配置，然后重启服务：

```bash
docker-compose restart
```

## 📊 监控

服务包含健康检查，可通过以下命令查看状态：

```bash
docker-compose ps
```

## 🆘 故障排除

1. **端口冲突**: 修改 `docker-compose.yml` 中的端口映射
2. **权限问题**: `sudo chown -R $USER:$USER data/`
3. **查看日志**: `docker-compose logs easydarwin`