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
- 音乐播放
- 收藏功能
- 下载功能
- 评论互动

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

## 详细文档
- [应用背景](docs/应用背景.md)
- [技术文档](docs/技术文档.md)
- [部署教程](docs/部署教程.md)

## 作者
MusicMaster Team

## 许可证
MIT License