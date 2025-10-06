#!/bin/bash

# EasyDarwin 快速启动脚本

echo "🚀 启动 EasyDarwin 服务..."

# 创建数据目录
mkdir -p data/{configs,logs,web}

# 启动服务
docker-compose up -d

# 等待服务启动
echo "⏳ 等待服务启动..."
sleep 10

# 检查服务状态
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