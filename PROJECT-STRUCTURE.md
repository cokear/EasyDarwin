# EasyDarwin Docker 项目文件整理

## 📦 项目包含内容

我已经为你整理了完整的EasyDarwin Docker部署方案，包含以下文件：

### 🏗️ 项目结构

```
easydarwin-docker-final/
├── docker-compose.yml          # 主配置文件（标准部署）
├── scripts/
│   └── start.sh               # 一键启动脚本
├── compose/                   # 不同环境的配置文件目录
├── nginx/                     # Nginx反向代理配置目录
├── docs/                      # 文档目录
├── examples/                  # 示例配置目录
└── README.md                  # 详细使用说明
```

### 📁 核心文件说明

#### 1. `docker-compose.yml` - 主配置文件
- 基于 `cakeor/easydarwin:latest` 镜像
- 完整端口映射（Web、RTSP、RTMP、WebRTC等）
- 数据持久化配置
- 健康检查配置
- 网络配置

#### 2. `scripts/start.sh` - 一键启动脚本
- 自动创建数据目录
- 启动Docker Compose服务
- 等待服务就绪
- 显示访问地址和常用命令

#### 3. `README.md` - 完整使用文档
- 快速开始指南
- 端口说明
- 管理命令
- 故障排除
- 安全建议

## 🚀 使用方法

### 方法1：解压并使用（推荐）
```bash
# 解压项目文件
tar -xzf easydarwin-docker-complete.tar.gz

# 进入项目目录
cd easydarwin-docker-final

# 一键启动
./scripts/start.sh
```

### 方法2：手动启动
```bash
cd easydarwin-docker-final
mkdir -p data/{configs,logs,web}
docker-compose up -d
```

## 🌐 访问地址

启动成功后，可通过以下地址访问：

- **Web管理界面**: http://localhost:8080
- **API文档**: http://localhost:8080/apidoc.html
- **健康检查**: http://localhost:8080/api/v1/getserverinfo

## 📋 端口映射

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

## 🛠️ 常用管理命令

```bash
# 查看服务状态
docker-compose ps

# 查看实时日志
docker-compose logs -f

# 停止服务
docker-compose down

# 重启服务
docker-compose restart

# 更新镜像
docker-compose pull && docker-compose up -d --force-recreate
```

## 📊 服务特性

- ✅ **完整功能**: 支持RTSP、RTMP、WebRTC、HLS等协议
- ✅ **数据持久化**: 配置、日志、Web文件持久保存
- ✅ **健康检查**: 自动监控服务状态
- ✅ **自动重启**: 容器异常时自动重启
- ✅ **网络隔离**: 独立的Docker网络
- ✅ **时区配置**: 默认中国时区
- ✅ **日志管理**: 结构化日志输出

## 🔧 自定义配置

### 修改端口
编辑 `docker-compose.yml` 文件中的 `ports` 部分：
```yaml
ports:
  - "8080:8080"  # 改为其他端口，如 "9080:8080"
```

### 修改数据目录
编辑 `docker-compose.yml` 文件中的 `volumes` 部分：
```yaml
volumes:
  - ./custom-data/configs:/app/configs
```

### 环境变量
在 `docker-compose.yml` 中的 `environment` 部分添加：
```yaml
environment:
  - TZ=Asia/Shanghai
  - LOG_LEVEL=debug  # 修改日志级别
```

## 📦 项目文件

- `easydarwin-docker-complete.tar.gz` - 完整项目压缩包
- `easydarwin-docker-final/` - 项目目录
- `PROJECT-STRUCTURE.md` - 本说明文件

## 🎯 下一步

1. 解压项目文件
2. 进入项目目录
3. 运行启动脚本
4. 访问Web界面进行配置
5. 开始推流测试

## 📞 技术支持

- **Docker镜像**: https://hub.docker.com/r/cakeor/easydarwin
- **官方文档**: https://www.easydarwin.org
- **项目地址**: https://github.com/EasyDarwin/EasyDarwin

---

**项目创建时间**: 2023-12-01  
**EasyDarwin版本**: v8.3.3  
**Docker Compose版本**: 3.8