╔══════════════════════════════════════════════════════════════╗
║               MusicMaster 音乐管理系统                        ║
║                  便携版 - 一键启动                           ║
╚══════════════════════════════════════════════════════════════╝

【快速开始】
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

首次使用：

  步骤 1: 准备应用程序
  ─────────────────────────────────────────
  编译后端项目，将JAR文件复制到 portable/app/ 目录：
  
  Windows:
    cd backend
    mvn clean package -DskipTests
    copy target\musicmaster-backend-1.0.0.jar ..\portable\app\musicmaster.jar
  
  Linux/Mac:
    cd backend
    mvn clean package -DskipTests
    cp target/musicmaster-backend-1.0.0.jar ../portable/app/musicmaster.jar

  步骤 2: 安装MySQL便携版
  ─────────────────────────────────────────
  Windows: 双击运行 setup-mysql.bat
  Linux/Mac: 运行 ./setup-mysql.sh

  步骤 3: 初始化数据库
  ─────────────────────────────────────────
  Windows: 双击运行 init-database.bat
  Linux/Mac: 运行 ./init-database.sh

  步骤 4: 启动系统
  ─────────────────────────────────────────
  Windows: 双击运行 start.bat
  Linux/Mac: 运行 ./start.sh


日常使用：
  启动: 运行 start.bat (Windows) 或 ./start.sh (Linux/Mac)
  停止: 运行 stop.bat (Windows) 或 ./stop.sh (Linux/Mac)

【访问系统】
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

启动成功后，打开浏览器访问：
  http://localhost:8080

默认管理员账号：
  用户名: admin
  密码: 123456

【目录结构】
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

portable/
├── app/                     # 应用程序
│   └── musicmaster.jar      # 主程序 (需要手动复制)
├── mysql/                   # MySQL便携版 (自动下载)
│   ├── bin/                 # MySQL可执行文件
│   ├── data/                # 数据库数据
│   └── my.ini / my.cnf      # MySQL配置
├── jre/                     # Java运行环境 (可选)
├── uploads/                 # 上传文件目录
│   ├── music/               # 音乐文件
│   └── image/               # 图片文件
├── logs/                    # 日志文件
├── start.bat                # Windows一键启动
├── start.sh                 # Linux/Mac一键启动
├── stop.bat                 # Windows停止服务
├── stop.sh                  # Linux/Mac停止服务
├── setup-mysql.bat          # Windows MySQL安装
├── setup-mysql.sh           # Linux/Mac MySQL安装
├── start-mysql.bat          # Windows 启动MySQL
├── start-mysql.sh           # Linux/Mac 启动MySQL
├── stop-mysql.bat           # Windows 停止MySQL
├── stop-mysql.sh            # Linux/Mac 停止MySQL
├── init-database.bat        # Windows 初始化数据库
├── init-database.sh         # Linux/Mac 初始化数据库
└── README.txt               # 本说明文件

【端口配置】
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

MySQL端口: 13306 (避免与系统MySQL冲突)
Web服务端口: 8080

【功能特性】
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✓ 用户管理 - 用户注册、登录、权限管理
✓ 歌手管理 - 歌手信息维护
✓ 歌曲管理 - 歌曲上传、播放、管理
✓ 歌单管理 - 创建和管理歌单
✓ 评论系统 - 歌曲和歌单评论
✓ 收藏功能 - 收藏喜欢的歌单
✓ 数据统计 - 系统数据可视化

【便携版特点】
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✓ 内置MySQL - 使用便携式MySQL，无需安装
✓ 零配置启动 - 自动管理数据库服务
✓ 数据持久化 - 所有数据保存在本地mysql/data目录
✓ 绿色便携 - 可放在U盘任意位置运行
✓ 不影响系统 - 使用独立端口，不与系统MySQL冲突
✓ 跨平台支持 - Windows/Linux/Mac一键启动

【常见问题】
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Q: 启动时提示"端口被占用"怎么办？
A: 请关闭占用8080或13306端口的程序，或修改配置文件中的端口号。

Q: MySQL下载太慢怎么办？
A: 可以手动下载MySQL ZIP包，解压到portable/mysql目录。
   下载地址: https://dev.mysql.com/downloads/mysql/
   选择: Windows ZIP Archive 或 Linux - Generic

Q: 如何迁移数据？
A: 直接复制整个portable目录即可，包括mysql/data文件夹。

Q: 如何备份数据？
A: 备份mysql/data目录和uploads目录即可。

Q: 忘记管理员密码怎么办？
A: 运行 init-database.bat/sh 重新初始化数据库（会清除所有数据）。

Q: 支持哪些操作系统？
A: Windows 10/11、主流Linux发行版(Ubuntu/CentOS等)、macOS 10.14+

Q: 需要什么配置？
A: 最低配置：2GB内存、1GB磁盘空间
   推荐配置：4GB内存、2GB磁盘空间

【技术支持】
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

项目地址: https://github.com/LWJSTONE/MusicMaster

【版本信息】
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

版本: v1.0.0 便携版
数据库: MySQL 8.0 (便携式)
作者: LWJSTONE

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                    感谢使用 MusicMaster！
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
