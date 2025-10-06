#!/bin/bash

# 登录并推送 cakeor/easydarwin 到 Docker Hub
# 使用方法: ./login-and-push.sh

set -e

DOCKERHUB_USERNAME="cakeor"
IMAGE_NAME="easydarwin"
VERSION="v8.3.3"

echo "🔐 Docker Hub 登录和推送脚本"
echo "用户名: $DOCKERHUB_USERNAME"
echo "镜像: $IMAGE_NAME"
echo ""

# 设置环境变量
export PODMAN_IGNORE_CGROUPSV1_WARNING=1

# 方法1: 交互式登录
echo "=== 方法1: 交互式登录 ==="
echo "请手动运行以下命令进行登录:"
echo "podman login docker.io"
echo "然后输入用户名: cakeor"
echo "输入密码: [你的Docker Hub密码]"
echo ""

# 方法2: 使用环境变量登录 (如果设置了的话)
if [ ! -z "$DOCKER_PASSWORD" ]; then
    echo "=== 方法2: 使用环境变量登录 ==="
    echo "检测到 DOCKER_PASSWORD 环境变量，尝试自动登录..."
    echo "$DOCKER_PASSWORD" | podman login docker.io --username $DOCKERHUB_USERNAME --password-stdin
    
    if [ $? -eq 0 ]; then
        echo "✅ 登录成功！开始推送..."
        
        # 推送镜像
        echo "⬆️  推送 latest 标签..."
        podman push $DOCKERHUB_USERNAME/$IMAGE_NAME:latest
        
        echo "⬆️  推送版本标签 $VERSION..."
        podman push $DOCKERHUB_USERNAME/$IMAGE_NAME:$VERSION
        
        echo ""
        echo "🎉 推送完成！"
        echo "🌐 Docker Hub链接: https://hub.docker.com/r/$DOCKERHUB_USERNAME/$IMAGE_NAME"
        exit 0
    fi
fi

# 方法3: 使用访问令牌文件
if [ -f "docker_token.txt" ]; then
    echo "=== 方法3: 使用访问令牌文件 ==="
    echo "检测到 docker_token.txt 文件，尝试使用访问令牌登录..."
    cat docker_token.txt | podman login docker.io --username $DOCKERHUB_USERNAME --password-stdin
    
    if [ $? -eq 0 ]; then
        echo "✅ 登录成功！开始推送..."
        
        # 推送镜像
        echo "⬆️  推送 latest 标签..."
        podman push $DOCKERHUB_USERNAME/$IMAGE_NAME:latest
        
        echo "⬆️  推送版本标签 $VERSION..."
        podman push $DOCKERHUB_USERNAME/$IMAGE_NAME:$VERSION
        
        echo ""
        echo "🎉 推送完成！"
        echo "🌐 Docker Hub链接: https://hub.docker.com/r/$DOCKERHUB_USERNAME/$IMAGE_NAME"
        exit 0
    fi
fi

echo ""
echo "📋 手动登录和推送步骤:"
echo "1. 运行: podman login docker.io"
echo "2. 输入用户名: cakeor"
echo "3. 输入密码或访问令牌"
echo "4. 推送镜像:"
echo "   podman push cakeor/easydarwin:latest"
echo "   podman push cakeor/easydarwin:v8.3.3"
echo ""
echo "💡 提示: 你也可以:"
echo "- 设置环境变量: export DOCKER_PASSWORD='your_password'"
echo "- 或创建文件: echo 'your_token' > docker_token.txt"
echo "然后重新运行此脚本"