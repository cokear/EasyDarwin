#!/bin/bash

# EasyDarwin Docker镜像推送到Docker Hub脚本
# 使用方法: ./push-to-dockerhub.sh <your-dockerhub-username>

set -e

# 检查参数
if [ $# -eq 0 ]; then
    echo "错误: 请提供Docker Hub用户名"
    echo "使用方法: $0 <your-dockerhub-username>"
    echo "示例: $0 myusername"
    exit 1
fi

DOCKERHUB_USERNAME=$1
IMAGE_NAME="easydarwin"
VERSION="v8.3.3"

echo "🚀 开始推送 EasyDarwin 镜像到 Docker Hub..."
echo "用户名: $DOCKERHUB_USERNAME"
echo "镜像名: $IMAGE_NAME"
echo "版本: $VERSION"
echo ""

# 设置环境变量忽略cgroups警告
export PODMAN_IGNORE_CGROUPSV1_WARNING=1

# 检查本地镜像是否存在
echo "📋 检查本地镜像..."
if ! podman images | grep -q "localhost/easydarwin.*latest"; then
    echo "❌ 错误: 本地未找到 easydarwin:latest 镜像"
    echo "请先构建镜像: podman build -t easydarwin:latest ."
    exit 1
fi

# 为镜像打标签
echo "🏷️  为镜像打标签..."
podman tag localhost/easydarwin:latest $DOCKERHUB_USERNAME/$IMAGE_NAME:latest
podman tag localhost/easydarwin:latest $DOCKERHUB_USERNAME/$IMAGE_NAME:$VERSION

# 显示标签后的镜像
echo "📦 标签后的镜像列表:"
podman images | grep $IMAGE_NAME

# 登录Docker Hub
echo ""
echo "🔐 登录 Docker Hub..."
echo "请输入你的Docker Hub凭据:"
podman login docker.io

# 推送镜像
echo ""
echo "⬆️  推送镜像到 Docker Hub..."
echo "推送 latest 标签..."
podman push $DOCKERHUB_USERNAME/$IMAGE_NAME:latest

echo "推送版本标签 $VERSION..."
podman push $DOCKERHUB_USERNAME/$IMAGE_NAME:$VERSION

echo ""
echo "✅ 推送完成!"
echo "你的镜像现在可以通过以下命令拉取:"
echo "  docker pull $DOCKERHUB_USERNAME/$IMAGE_NAME:latest"
echo "  docker pull $DOCKERHUB_USERNAME/$IMAGE_NAME:$VERSION"
echo ""
echo "🌐 Docker Hub链接:"
echo "  https://hub.docker.com/r/$DOCKERHUB_USERNAME/$IMAGE_NAME"