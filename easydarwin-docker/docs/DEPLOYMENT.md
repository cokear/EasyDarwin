# EasyDarwin 部署指南

## 系统要求

- Docker 20.10+
- Docker Compose 2.0+
- 至少 2GB 内存
- 至少 10GB 磁盘空间

## 部署步骤

### 1. 下载项目
```bash
git clone <repository-url>
cd easydarwin-docker
```

### 2. 配置环境
```bash
cp .env.example .env
# 编辑 .env 文件修改配置
```

### 3. 选择部署模式

#### 简单模式（测试用）
```bash
docker-compose -f compose/docker-compose.simple.yml up -d
```

#### 标准模式（推荐）
```bash
docker-compose up -d
```

#### 生产模式
```bash
docker-compose -f compose/docker-compose.prod.yml up -d
```

#### 开发模式
```bash
docker-compose -f compose/docker-compose.dev.yml up -d
```

### 4. 验证部署
```bash
# 检查服务状态
docker-compose ps

# 检查健康状态
curl http://localhost:8080/api/v1/getserverinfo

# 访问Web界面
open http://localhost:8080
```

## 配置说明

### 端口配置
根据需要修改 docker-compose.yml 中的端口映射。

### 数据持久化
- 配置文件：`./data/configs`
- 日志文件：`./data/logs`
- Web文件：`./data/web`

### 环境变量
在 `.env` 文件中配置：
- 时区设置
- 日志级别
- 端口映射
- 资源限制

## 生产环境配置

### SSL证书配置
1. 将证书文件放入 `nginx/ssl/` 目录
2. 修改 `nginx/nginx.conf` 启用HTTPS
3. 重启服务

### 资源限制
生产模式已配置资源限制：
- CPU: 2核心
- 内存: 1GB

### 日志管理
生产模式配置了日志轮转：
- 最大文件大小: 10MB
- 保留文件数: 3个

## 监控配置

### 健康检查
所有模式都包含健康检查，自动监控服务状态。

### 日志监控
开发模式包含Dozzle日志查看工具。

### 容器管理
开发模式包含Portainer容器管理工具。