# EasyDarwin API 文档

## 基础信息

- **API Base URL**: `http://localhost:8080/api/v1`
- **API文档地址**: `http://localhost:8080/apidoc.html`

## 主要API接口

### 1. 服务器信息
```http
GET /api/v1/getserverinfo
```

获取服务器基本信息和状态。

**响应示例**:
```json
{
  "code": 200,
  "msg": "success",
  "data": {
    "server": "EasyDarwin",
    "version": "v8.3.3",
    "build_time": "2023-12-01 10:00:00",
    "start_time": "2023-12-01 12:00:00"
  }
}
```

### 2. 推流列表
```http
GET /api/v1/pushers
```

获取当前所有推流信息。

### 3. 拉流列表
```http
GET /api/v1/players
```

获取当前所有拉流信息。

### 4. 录像管理
```http
GET /api/v1/record/files
POST /api/v1/record/start
POST /api/v1/record/stop
```

录像文件管理和录制控制。

## 推流地址

### RTMP推流
```
rtmp://localhost:1935/live/stream_key
```

### RTSP推流
```
rtsp://localhost:554/stream_key
```

## 拉流地址

### RTMP拉流
```
rtmp://localhost:1935/live/stream_key
```

### RTSP拉流
```
rtsp://localhost:554/stream_key
```

### HTTP-FLV拉流
```
http://localhost:8080/live/stream_key.flv
```

### WebSocket-FLV拉流
```
ws://localhost:8080/live/stream_key.flv
```

### HLS拉流
```
http://localhost:8080/live/stream_key/index.m3u8
```

## WebRTC

### 推流
使用WebRTC推流到：
```
http://localhost:8080/webrtc/push.html
```

### 拉流
使用WebRTC拉流：
```
http://localhost:8080/webrtc/play.html
```

## 认证

默认情况下API无需认证，生产环境建议启用认证。

在配置文件中设置：
```toml
[auth]
enable = true
username = "admin"
password = "password"
```