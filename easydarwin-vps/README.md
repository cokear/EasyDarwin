# EasyDarwin VPS 部署方案

专为VPS服务器设计的EasyDarwin流媒体服务器生产环境部署方案，包含完整的安全配置、SSL证书、监控和管理工具。

## 🌟 特性

- ✅ **生产就绪**: 完整的生产环境配置
- ✅ **安全加固**: 防火墙、Fail2Ban、SSL证书
- ✅ **自动化部署**: 一键安装脚本
- ✅ **监控告警**: 服务监控和邮件通知
- ✅ **自动更新**: Watchtower自动更新容器
- ✅ **SSL证书**: Let's Encrypt自动获取和续期
- ✅ **负载均衡**: Nginx反向代理和缓存
- ✅ **日志管理**: 自动轮转和清理
- ✅ **备份恢复**: 自动备份和恢复功能

## 📋 系统要求

- **操作系统**: Ubuntu 20.04+ / CentOS 8+ / Debian 11+
- **内存**: 最少2GB，推荐4GB+
- **磁盘**: 最少20GB可用空间
- **网络**: 公网IP地址
- **域名**: 已解析到服务器IP的域名

## 🚀 快速部署

### 1. 下载项目
```bash
# 方法1：使用git（推荐）
git clone <repository-url>
cd easydarwin-vps

# 方法2：直接下载
wget <download-url>
tar -xzf easydarwin-vps.tar.gz
cd easydarwin-vps
```

### 2. 配置环境变量
```bash
# 复制环境变量模板
cp .env.example .env

# 编辑配置文件
nano .env

# 必须修改的配置：
# - DOMAIN: 你的域名
# - NOTIFICATION_EMAIL: 通知邮箱
# - ADMIN_PASSWORD: 管理员密码
```

### 3. 一键部署
```bash
# 给脚本执行权限
chmod +x scripts/*.sh

# 运行部署脚本（需要root权限）
sudo ./scripts/vps-setup.sh
```

### 4. 配置SSL证书
```bash
# 自动获取Let's Encrypt证书
sudo ./scripts/setup-ssl.sh
```

## 📁 项目结构

```
easydarwin-vps/
├── docker-compose.yml          # 主配置文件
├── .env.example               # 环境变量模板
├── scripts/                   # 管理脚本
│   ├── vps-setup.sh          # VPS初始化脚本
│   ├── setup-ssl.sh          # SSL证书配置
│   └── manage.sh             # 服务管理工具
├── nginx/                     # Nginx配置
│   └── nginx.conf            # 主配置文件
├── ssl/                       # SSL证书目录
├── monitoring/                # 监控配置
└── docs/                     # 文档
```

## 🔧 服务管理

### 使用管理脚本
```bash
# 查看服务状态
./scripts/manage.sh status

# 启动服务
./scripts/manage.sh start

# 停止服务
./scripts/manage.sh stop

# 重启服务
./scripts/manage.sh restart

# 查看日志
./scripts/manage.sh logs

# 实时日志
./scripts/manage.sh logs -f

# 更新镜像
./scripts/manage.sh update

# 备份数据
./scripts/manage.sh backup

# 系统监控
./scripts/manage.sh monitor

# 安全检查
./scripts/manage.sh security

# 续期SSL证书
./scripts/manage.sh ssl-renew

# 系统清理
./scripts/manage.sh cleanup
```

### 直接使用Docker Compose
```bash
# 启动服务
docker-compose up -d

# 查看状态
docker-compose ps

# 查看日志
docker-compose logs -f

# 停止服务
docker-compose down

# 重启特定服务
docker-compose restart nginx
```

## 🌐 访问地址

部署完成后，可通过以下地址访问：

- **HTTPS Web界面**: https://your-domain.com
- **HTTP**: http://your-domain.com (自动重定向到HTTPS)
- **API文档**: https://your-domain.com/apidoc.html
- **健康检查**: https://your-domain.com/health

## 🔌 流媒体端口

| 端口 | 协议 | 用途 | 外部访问 |
|------|------|------|----------|
| 80 | HTTP | Web重定向 | ✅ |
| 443 | HTTPS | Web界面 | ✅ |
| 554 | TCP | RTSP服务 | ✅ |
| 1935 | TCP | RTMP服务 | ✅ |
| 4433 | TCP | WebRTC信令 | ✅ |
| 5544 | TCP | WebRTC媒体 | ✅ |
| 8080 | HTTP | 内部API | ❌ (仅本地) |
| 30000-30100 | UDP | RTP传输 | ✅ |

## 🔒 安全配置

### 防火墙配置
- 自动配置UFW/Firewalld
- 只开放必要端口
- 拒绝其他所有入站连接

### Fail2Ban配置
- SSH暴力破解防护
- Nginx访问频率限制
- 自动封禁恶意IP

### SSL/TLS配置
- Let's Encrypt免费证书
- 自动续期（每月1号执行）
- 强制HTTPS重定向
- 现代TLS配置

### 访问控制
- API接口限流
- 登录接口特殊限流
- 静态文件缓存
- 安全响应头

## 📊 监控和告警

### 服务监控
- 容器健康检查
- 自动重启异常容器
- Watchtower自动更新

### 日志管理
- 结构化日志输出
- 自动日志轮转
- 日志大小限制

### 邮件通知
- 容器更新通知
- 系统异常告警
- SSL证书续期通知

## 💾 备份和恢复

### 自动备份
```bash
# 手动备份
./scripts/manage.sh backup

# 查看备份文件
ls -la backups/

# 恢复数据
./scripts/manage.sh restore backups/easydarwin-backup-20231201-120000.tar.gz
```

### 备份内容
- 配置文件
- 用户数据
- 日志文件
- SSL证书

## 🔧 自定义配置

### 修改域名
1. 编辑 `.env` 文件中的 `DOMAIN`
2. 运行 `./scripts/setup-ssl.sh` 重新配置SSL
3. 重启服务: `./scripts/manage.sh restart`

### 启用推流认证
```bash
# 编辑 .env 文件
RTMP_AUTH_ENABLE=true
RTSP_AUTH_ENABLE=true
STREAM_USERNAME=your-username
STREAM_PASSWORD=your-password

# 重启服务
./scripts/manage.sh restart
```

### 配置录像功能
```bash
# 编辑 .env 文件
RECORD_ENABLE=true
RECORD_PATH=/app/records
RECORD_FORMAT=mp4

# 重启服务
./scripts/manage.sh restart
```

## 🆘 故障排除

### 常见问题

1. **域名解析问题**
   ```bash
   # 检查域名解析
   nslookup your-domain.com
   
   # 检查防火墙
   ./scripts/manage.sh security
   ```

2. **SSL证书问题**
   ```bash
   # 检查证书状态
   openssl x509 -in ssl/cert.pem -text -noout
   
   # 重新获取证书
   sudo ./scripts/setup-ssl.sh
   ```

3. **服务无法启动**
   ```bash
   # 查看详细日志
   ./scripts/manage.sh logs
   
   # 检查配置
   docker-compose config
   ```

4. **端口冲突**
   ```bash
   # 检查端口占用
   netstat -tlnp | grep -E ":(80|443|554|1935)"
   
   # 修改端口映射
   nano docker-compose.yml
   ```

### 性能优化

1. **系统参数优化**
   - 已自动配置网络参数
   - 文件描述符限制
   - TCP拥塞控制算法

2. **容器资源限制**
   - CPU限制: 2核心
   - 内存限制: 1GB
   - 可在docker-compose.yml中调整

3. **Nginx缓存配置**
   - 静态文件缓存
   - Gzip压缩
   - 连接复用

## 📞 技术支持

- **Docker镜像**: https://hub.docker.com/r/cakeor/easydarwin
- **官方文档**: https://www.easydarwin.org
- **GitHub**: https://github.com/EasyDarwin/EasyDarwin

## 📝 更新日志

- **v1.0.0**: 初始VPS部署版本
- 基于EasyDarwin v8.3.3
- 支持Ubuntu/CentOS/Debian
- 完整的生产环境配置

---

**部署前请确保**:
1. 域名已正确解析到服务器IP
2. 服务器防火墙允许相关端口
3. 有足够的系统资源
4. 已备份重要数据