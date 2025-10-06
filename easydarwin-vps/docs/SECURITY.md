# EasyDarwin VPS 安全配置指南

## 🔒 安全特性

### 网络安全
- ✅ 防火墙自动配置（UFW/Firewalld）
- ✅ Fail2Ban防暴力破解
- ✅ 端口访问控制
- ✅ DDoS基础防护

### 应用安全
- ✅ SSL/TLS加密传输
- ✅ 安全响应头配置
- ✅ API接口限流
- ✅ 推流认证控制

### 系统安全
- ✅ 容器隔离运行
- ✅ 最小权限原则
- ✅ 自动安全更新
- ✅ 日志审计

## 🛡️ 防火墙配置

### Ubuntu/Debian (UFW)
```bash
# 查看防火墙状态
sudo ufw status

# 允许特定IP访问管理端口
sudo ufw allow from YOUR_IP to any port 22

# 限制SSH访问
sudo ufw limit ssh
```

### CentOS/RHEL (Firewalld)
```bash
# 查看防火墙状态
sudo firewall-cmd --list-all

# 添加富规则限制访问
sudo firewall-cmd --permanent --add-rich-rule="rule family='ipv4' source address='YOUR_IP' port protocol='tcp' port='22' accept"
```

## 🚫 Fail2Ban配置

### 查看封禁状态
```bash
# 查看所有jail状态
sudo fail2ban-client status

# 查看特定jail
sudo fail2ban-client status sshd
sudo fail2ban-client status nginx-limit-req

# 解封IP
sudo fail2ban-client set sshd unbanip IP_ADDRESS
```

### 自定义配置
```bash
# 编辑本地配置
sudo nano /etc/fail2ban/jail.local

# 重启服务
sudo systemctl restart fail2ban
```

## 🔐 SSL/TLS配置

### 证书管理
```bash
# 检查证书有效期
openssl x509 -in ssl/cert.pem -noout -dates

# 测试SSL配置
curl -I https://your-domain.com

# 手动续期证书
sudo ./scripts/setup-ssl.sh
```

### SSL安全等级测试
```bash
# 使用SSL Labs测试（在线）
# https://www.ssllabs.com/ssltest/

# 本地测试
nmap --script ssl-enum-ciphers -p 443 your-domain.com
```

## 🔑 认证配置

### 推流认证
```bash
# 启用RTMP认证
RTMP_AUTH_ENABLE=true
STREAM_USERNAME=your-username
STREAM_PASSWORD=strong-password

# 启用RTSP认证
RTSP_AUTH_ENABLE=true
```

### 管理员认证
```bash
# 设置管理员密码
ADMIN_USERNAME=admin
ADMIN_PASSWORD=very-strong-password

# 使用强密码生成器
openssl rand -base64 32
```

## 📊 安全监控

### 日志监控
```bash
# 查看访问日志
docker-compose exec nginx tail -f /var/log/nginx/access.log

# 查看错误日志
docker-compose exec nginx tail -f /var/log/nginx/error.log

# 查看系统日志
journalctl -f -u docker
```

### 入侵检测
```bash
# 检查异常登录
last -n 20

# 检查网络连接
netstat -tuln | grep LISTEN

# 检查进程
ps aux | grep -E "(nginx|easydarwin)"
```

## 🔧 安全加固

### 系统加固
```bash
# 禁用root SSH登录
sudo sed -i 's/#PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config

# 修改SSH端口
sudo sed -i 's/#Port 22/Port 2222/' /etc/ssh/sshd_config

# 重启SSH服务
sudo systemctl restart sshd
```

### Docker安全
```bash
# 限制容器权限
# 在docker-compose.yml中添加：
security_opt:
  - no-new-privileges:true
read_only: true
tmpfs:
  - /tmp:noexec,nosuid,size=100m
```

### 网络隔离
```bash
# 创建自定义网络
docker network create --driver bridge \
  --subnet=172.30.0.0/16 \
  --ip-range=172.30.240.0/20 \
  easydarwin-secure

# 限制容器间通信
# 在docker-compose.yml中配置网络策略
```

## 🚨 应急响应

### 发现攻击时
```bash
# 1. 立即封禁攻击IP
sudo fail2ban-client set nginx-limit-req banip ATTACKER_IP

# 2. 查看攻击日志
grep "ATTACKER_IP" /var/log/nginx/access.log

# 3. 临时关闭服务（如必要）
./scripts/manage.sh stop

# 4. 备份当前状态
./scripts/manage.sh backup
```

### 系统被入侵时
```bash
# 1. 断网隔离
sudo iptables -A INPUT -j DROP
sudo iptables -A OUTPUT -j DROP

# 2. 保存证据
sudo dd if=/dev/sda of=/mnt/backup/disk_image.dd

# 3. 分析日志
sudo journalctl --since "1 hour ago" > /tmp/system.log

# 4. 重装系统（如必要）
```

## 📋 安全检查清单

### 日常检查
- [ ] 检查防火墙状态
- [ ] 查看Fail2Ban日志
- [ ] 检查SSL证书有效期
- [ ] 查看系统更新
- [ ] 检查异常登录
- [ ] 查看资源使用情况

### 每周检查
- [ ] 更新系统补丁
- [ ] 检查容器镜像更新
- [ ] 查看安全日志
- [ ] 测试备份恢复
- [ ] 检查磁盘空间

### 每月检查
- [ ] 安全配置审计
- [ ] 密码策略检查
- [ ] 网络安全扫描
- [ ] 渗透测试
- [ ] 应急预案演练

## 🔍 安全工具

### 系统扫描
```bash
# 安装安全扫描工具
sudo apt install lynis chkrootkit rkhunter

# 运行系统审计
sudo lynis audit system

# 检查rootkit
sudo chkrootkit
sudo rkhunter --check
```

### 网络扫描
```bash
# 端口扫描
nmap -sS -O your-domain.com

# SSL扫描
nmap --script ssl-cert,ssl-enum-ciphers -p 443 your-domain.com

# 漏洞扫描
nmap --script vuln your-domain.com
```

## 📞 安全事件报告

### 联系方式
- 系统管理员: admin@your-domain.com
- 安全团队: security@your-domain.com
- 紧急联系: +86-xxx-xxxx-xxxx

### 报告模板
```
事件时间: YYYY-MM-DD HH:MM:SS
事件类型: [入侵/攻击/异常]
影响范围: [系统/服务/数据]
当前状态: [已控制/处理中/待处理]
处理措施: [具体措施]
后续计划: [预防措施]
```

---

**安全提醒**: 安全是一个持续的过程，需要定期检查和更新安全配置。