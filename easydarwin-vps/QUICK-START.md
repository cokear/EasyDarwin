# EasyDarwin VPS 快速部署指南

## 🚀 5分钟快速部署

### 前提条件
- ✅ VPS服务器（Ubuntu 20.04+）
- ✅ 域名已解析到服务器IP
- ✅ Root权限

### 步骤1：下载项目
```bash
# 上传项目文件到服务器
scp -r easydarwin-vps root@your-server-ip:/root/

# 或者直接在服务器上下载
wget <download-url>
tar -xzf easydarwin-vps.tar.gz
cd easydarwin-vps
```

### 步骤2：配置域名
```bash
# 编辑环境变量
cp .env.example .env
nano .env

# 修改以下配置：
DOMAIN=your-domain.com                    # 你的域名
NOTIFICATION_EMAIL=admin@your-domain.com  # 通知邮箱
ADMIN_PASSWORD=your-secure-password       # 管理员密码
```

### 步骤3：一键部署
```bash
# 运行部署脚本
chmod +x scripts/*.sh
sudo ./scripts/vps-setup.sh
```

### 步骤4：配置SSL证书
```bash
# 获取Let's Encrypt证书
sudo ./scripts/setup-ssl.sh
```

### 步骤5：验证部署
```bash
# 检查服务状态
./scripts/manage.sh status

# 访问Web界面
# https://your-domain.com
```

## 🎯 推流测试

### RTMP推流
```bash
# 使用OBS或FFmpeg推流
rtmp://your-domain.com:1935/live/test
```

### RTSP推流
```bash
# 使用FFmpeg推流
ffmpeg -re -i input.mp4 -c copy -f rtsp rtsp://your-domain.com:554/test
```

### 拉流测试
```bash
# RTMP拉流
ffplay rtmp://your-domain.com:1935/live/test

# RTSP拉流
ffplay rtsp://your-domain.com:554/test

# HLS拉流
https://your-domain.com/live/test/index.m3u8
```

## 📋 常用命令

```bash
# 查看服务状态
./scripts/manage.sh status

# 查看实时日志
./scripts/manage.sh logs -f

# 重启服务
./scripts/manage.sh restart

# 备份数据
./scripts/manage.sh backup

# 系统监控
./scripts/manage.sh monitor
```

## 🔧 常见配置

### 启用推流认证
```bash
# 编辑 .env 文件
RTMP_AUTH_ENABLE=true
STREAM_USERNAME=streamer
STREAM_PASSWORD=your-stream-password

# 重启服务
./scripts/manage.sh restart
```

### 启用录像功能
```bash
# 编辑 .env 文件
RECORD_ENABLE=true
RECORD_PATH=/app/records

# 重启服务
./scripts/manage.sh restart
```

## 🆘 故障排除

### 域名无法访问
```bash
# 检查域名解析
nslookup your-domain.com

# 检查防火墙
ufw status
```

### SSL证书问题
```bash
# 重新获取证书
sudo ./scripts/setup-ssl.sh

# 检查证书状态
openssl x509 -in ssl/cert.pem -text -noout
```

### 服务启动失败
```bash
# 查看详细日志
./scripts/manage.sh logs

# 检查配置
docker-compose config
```

## 📞 获取帮助

如遇问题，请：
1. 查看日志: `./scripts/manage.sh logs`
2. 检查状态: `./scripts/manage.sh status`
3. 运行安全检查: `./scripts/manage.sh security`

---

**部署完成后记得**:
- 🔒 修改默认密码
- 📧 配置邮件通知
- 🔐 启用推流认证
- 💾 定期备份数据