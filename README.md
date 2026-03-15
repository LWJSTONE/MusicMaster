# MusicMaster 音乐后台管理系统

## 项目简介
基于 Spring Boot + Vue 的前后端分离音乐后台管理系统，为用户提供完整的音乐管理、播放和互动体验。

## 技术栈
- **后端**：Spring Boot + MySQL
- **前端**：Vue + ElementUI + Axios
- **架构**：前后端分离，RESTful API

## 项目结构
```
MusicMaster/
├── backend/          # 后端项目
│   ├── src/
│   │   ├── main/
│   │   │   ├── java/com/musicmaster/
│   │   │   │   ├── controller/      # 控制层
│   │   │   │   ├── service/         # 业务逻辑层
│   │   │   │   ├── mapper/          # 数据访问层
│   │   │   │   ├── entity/          # 实体类
│   │   │   │   ├── dto/             # 数据传输对象
│   │   │   │   ├── config/          # 配置类
│   │   │   │   └── MusicMasterApplication.java
│   │   │   └── resources/
│   │   │       ├── application.yml  # 配置文件
│   │   │       └── mapper/          # MyBatis映射文件
│   │   └── test/
│   └── pom.xml
├── frontend/         # 前端项目
│   ├── src/
│   │   ├── components/   # 组件
│   │   ├── views/        # 页面
│   │   ├── router/       # 路由
│   │   ├── api/          # API调用
│   │   ├── assets/       # 静态资源
│   │   └── App.vue
│   ├── package.json
│   └── vue.config.js
├── docs/            # 文档
│   ├── 应用背景.md
│   ├── 技术文档.md
│   └── 部署教程.md
└── README.md
```

## 主要功能

### 管理员端
- 用户信息管理
- 歌手管理
- 歌曲管理
- 歌单管理
- 评论管理
- 数据统计分析

### 用户端
- 登录/注册
- **音乐播放**（已修复，支持真实播放）
- 收藏功能
- 下载功能
- 评论互动
- **上传音乐**（新增功能）

## 快速开始

### 后端启动
```bash
cd backend
# 配置数据库连接（application.yml）
mvn clean install
mvn spring-boot:run
```

### 前端启动
```bash
cd frontend
npm install
npm run serve
```

## 更新日志

### v1.1.0 (fix分支更新)

#### 🎵 修复音乐播放问题
**问题描述**：原播放器只是 UI 状态变化，没有实际播放音乐

**解决方案**：
- 添加 HTML5 `<audio>` 元素实现真实音频播放
- 实现播放/暂停控制功能
- 实现进度条实时更新（100ms 刷新）
- 实现进度条拖动定位功能
- 实现音量控制和静音切换
- 实现上一曲/下一曲切换
- 实现自动播放下一曲

**修改文件**：`frontend/src/views/Player.vue`

#### 📤 添加音乐上传功能
**新增功能**：
- 音乐文件上传（支持 MP3、WAV、OGG、M4A 格式）
- 封面图片上传（支持 JPG、PNG、GIF、WebP 格式）
- 文件保存到服务器本地 uploads 目录
- 返回可访问的 URL

**修改文件**：`backend/src/main/java/com/musicmaster/controller/SongController.java`

**新增接口**：
- `POST /api/song/upload` - 上传音乐文件
- `POST /api/song/pic` - 上传封面图片

#### 🎶 更新测试数据
**更新内容**：
- 使用 SoundHelix 免费音乐作为测试数据
- 添加 6 首可实际播放的测试音乐
- 更新歌手和歌单数据
- 测试账号：admin / admin123

**修改文件**：`backend/src/main/resources/sql/init.sql`

## 详细文档
- [应用背景](docs/应用背景.md)
- [技术文档](docs/技术文档.md)
- [部署教程](docs/部署教程.md)

## 作者
MusicMaster Team

## 许可证
MIT License
