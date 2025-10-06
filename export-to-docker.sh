#!/bin/bash

# 将Podman镜像导出并导入到Docker的脚本

set -e

echo "📦 将 Podman 镜像导出并导入到 Docker..."

# 设置环境变量
export PODMAN_IGNORE_CGROUPSV1_WARNING=1

# 导出镜像为tar文件
echo "⬇️  从Podman导出镜像..."
podman save -o easydarwin.tar localhost/easydarwin:latest

# 导入到Docker
echo "⬆️  导入镜像到Docker..."
docker load -i easydarwin.tar

# 清理临时文件
echo "🧹 清理临时文件..."
rm easydarwin.tar

# 显示Docker中的镜像
echo "📋 Docker中的镜像列表:"
docker images | grep easydarwin

echo "✅ 导出完成! 现在可以使用Docker命令推送镜像了"