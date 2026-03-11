-- =====================================
-- MusicMaster 音乐管理系统数据库初始化脚本
-- =====================================

-- 创建数据库
CREATE DATABASE IF NOT EXISTS `musicmaster` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE `musicmaster`;

-- =====================================
-- 用户表
-- =====================================
DROP TABLE IF EXISTS `user`;
CREATE TABLE `user` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '用户ID',
  `username` varchar(50) NOT NULL COMMENT '用户名',
  `password` varchar(255) NOT NULL COMMENT '密码',
  `nickname` varchar(50) DEFAULT NULL COMMENT '昵称',
  `email` varchar(100) DEFAULT NULL COMMENT '邮箱',
  `phone` varchar(20) DEFAULT NULL COMMENT '手机号',
  `avatar` varchar(255) DEFAULT NULL COMMENT '头像URL',
  `role` tinyint(4) DEFAULT '0' COMMENT '用户角色：0-普通用户，1-管理员',
  `status` tinyint(4) DEFAULT '1' COMMENT '状态：0-禁用，1-启用',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` tinyint(4) DEFAULT '0' COMMENT '删除标记：0-未删除，1-已删除',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户表';

-- =====================================
-- 歌手表
-- =====================================
DROP TABLE IF EXISTS `singer`;
CREATE TABLE `singer` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '歌手ID',
  `name` varchar(100) NOT NULL COMMENT '歌手姓名',
  `sex` tinyint(4) DEFAULT '0' COMMENT '性别：0-女，1-男，2-组合',
  `birth` date DEFAULT NULL COMMENT '出生日期',
  `location` varchar(100) DEFAULT NULL COMMENT '地区',
  `introduction` varchar(500) DEFAULT NULL COMMENT '简介',
  `pic` varchar(255) DEFAULT NULL COMMENT '歌手头像URL',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` tinyint(4) DEFAULT '0' COMMENT '删除标记：0-未删除，1-已删除',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='歌手表';

-- =====================================
-- 歌曲表
-- =====================================
DROP TABLE IF EXISTS `song`;
CREATE TABLE `song` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '歌曲ID',
  `name` varchar(100) NOT NULL COMMENT '歌曲名称',
  `singer_id` bigint(20) DEFAULT NULL COMMENT '歌手ID',
  `singer_name` varchar(100) DEFAULT NULL COMMENT '歌手名称',
  `album` varchar(100) DEFAULT NULL COMMENT '专辑名称',
  `style` varchar(50) DEFAULT NULL COMMENT '歌曲风格',
  `language` varchar(50) DEFAULT NULL COMMENT '歌曲语言',
  `url` varchar(255) DEFAULT NULL COMMENT '歌曲URL',
  `pic` varchar(255) DEFAULT NULL COMMENT '歌曲封面图片URL',
  `duration` int(11) DEFAULT NULL COMMENT '歌曲时长（秒）',
  `play_count` int(11) DEFAULT '0' COMMENT '播放量',
  `comment_count` int(11) DEFAULT '0' COMMENT '评论数',
  `collect_count` int(11) DEFAULT '0' COMMENT '收藏数',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` tinyint(4) DEFAULT '0' COMMENT '删除标记：0-未删除，1-已删除',
  PRIMARY KEY (`id`),
  KEY `idx_singer_id` (`singer_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='歌曲表';

-- =====================================
-- 歌单表
-- =====================================
DROP TABLE IF EXISTS `song_list`;
CREATE TABLE `song_list` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '歌单ID',
  `title` varchar(100) NOT NULL COMMENT '歌单标题',
  `pic` varchar(255) DEFAULT NULL COMMENT '歌单封面图片URL',
  `introduction` varchar(500) DEFAULT NULL COMMENT '歌单简介',
  `style` varchar(50) DEFAULT NULL COMMENT '风格',
  `creator_id` bigint(20) DEFAULT NULL COMMENT '创建者ID',
  `creator_name` varchar(50) DEFAULT NULL COMMENT '创建者用户名',
  `collect_count` int(11) DEFAULT '0' COMMENT '收藏数',
  `play_count` int(11) DEFAULT '0' COMMENT '播放量',
  `song_count` int(11) DEFAULT '0' COMMENT '歌曲数量',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` tinyint(4) DEFAULT '0' COMMENT '删除标记：0-未删除，1-已删除',
  PRIMARY KEY (`id`),
  KEY `idx_creator_id` (`creator_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='歌单表';

-- =====================================
-- 评论表
-- =====================================
DROP TABLE IF EXISTS `comment`;
CREATE TABLE `comment` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '评论ID',
  `user_id` bigint(20) DEFAULT NULL COMMENT '用户ID',
  `username` varchar(50) DEFAULT NULL COMMENT '用户名',
  `avatar` varchar(255) DEFAULT NULL COMMENT '用户头像',
  `song_id` bigint(20) DEFAULT NULL COMMENT '歌曲ID',
  `song_list_id` bigint(20) DEFAULT NULL COMMENT '歌单ID',
  `type` tinyint(4) DEFAULT '0' COMMENT '评论类型：0-歌曲评论，1-歌单评论',
  `content` text COMMENT '评论内容',
  `up` int(11) DEFAULT '0' COMMENT '点赞数',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` tinyint(4) DEFAULT '0' COMMENT '删除标记：0-未删除，1-已删除',
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_song_id` (`song_id`),
  KEY `idx_song_list_id` (`song_list_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='评论表';

-- =====================================
-- 收藏表
-- =====================================
DROP TABLE IF EXISTS `collect`;
CREATE TABLE `collect` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '收藏ID',
  `user_id` bigint(20) NOT NULL COMMENT '用户ID',
  `song_list_id` bigint(20) NOT NULL COMMENT '歌单ID',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '收藏时间',
  `deleted` tinyint(4) DEFAULT '0' COMMENT '删除标记：0-未删除，1-已删除',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_user_song_list` (`user_id`, `song_list_id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_song_list_id` (`song_list_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='收藏表';

-- =====================================
-- 初始化测试数据
-- =====================================

-- 插入管理员用户（密码：admin123）
INSERT INTO `user` (`username`, `password`, `nickname`, `email`, `phone`, `avatar`, `role`, `status`) VALUES
('admin', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKIUi', '系统管理员', 'admin@musicmaster.com', '13800138000', 'https://p1.music.126.net/SUeqj8xv8hJY-_0pAe5mRA==/109951165696893946.jpg', 1, 1),
('testuser', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKIUi', '测试用户', 'test@musicmaster.com', '13800138001', 'https://p1.music.126.net/SUeqj8xv8hJY-_0pAe5mRA==/109951165696893946.jpg', 0, 1);

-- 插入测试歌手数据
INSERT INTO `singer` (`name`, `sex`, `birth`, `location`, `introduction`, `pic`) VALUES
('周杰伦', 1, '1979-01-18', '台湾', '华语流行乐坛天王级人物', 'https://p1.music.126.net/SUeqj8xv8hJY-_0pAe5mRA==/109951165696893946.jpg'),
('林俊杰', 1, '1981-03-27', '新加坡', '华语流行乐坛著名男歌手', 'https://p1.music.126.net/SUeqj8xv8hJY-_0pAe5mRA==/109951165696893946.jpg'),
('Taylor Swift', 0, '1989-12-13', '美国', '美国著名流行音乐歌手', 'https://p1.music.126.net/SUeqj8xv8hJY-_0pAe5mRA==/109951165696893946.jpg');

-- 插入测试歌曲数据（使用 SoundHelix 免费音乐）
INSERT INTO `song` (`name`, `singer_id`, `singer_name`, `album`, `style`, `language`, `url`, `pic`, `duration`, `play_count`, `comment_count`, `collect_count`) VALUES
('钢琴旋律', 1, 'SoundHelix', 'SoundHelix Collection', '古典', '纯音乐', 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3', 'https://picsum.photos/200?random=1', 373, 100000, 500, 200),
('摇滚吉他', 1, 'SoundHelix', 'SoundHelix Rock', '摇滚', '纯音乐', 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-4.mp3', 'https://picsum.photos/200?random=2', 295, 90000, 450, 180),
('电子节拍', 2, 'Electronic Waves', 'Electronic Waves Vol.1', '电子', '纯音乐', 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3', 'https://picsum.photos/200?random=3', 420, 80000, 400, 150),
('梦幻氛围', 3, 'Piano Dreams', 'Piano Dreams', '氛围', '纯音乐', 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3', 'https://picsum.photos/200?random=4', 335, 60000, 300, 120),
('爵士钢琴', 3, 'Piano Dreams', 'Jazz Collection', '爵士', '纯音乐', 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-5.mp3', 'https://picsum.photos/200?random=5', 267, 70000, 350, 140),
('古典弦乐', 3, 'Piano Dreams', 'Classical Strings', '古典', '纯音乐', 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-6.mp3', 'https://picsum.photos/200?random=6', 272, 50000, 250, 100);

-- 插入测试歌单数据
INSERT INTO `song_list` (`title`, `pic`, `introduction`, `style`, `creator_id`, `creator_name`, `collect_count`, `play_count`, `song_count`) VALUES
('华语流行经典', 'https://p1.music.126.net/SUeqj8xv8hJY-_0pAe5mRA==/109951165696893946.jpg', '精选华语流行音乐经典曲目', '流行', 2, 'testuser', 500, 20000, 10),
('欧美流行热榜', 'https://p1.music.126.net/SUeqj8xv8hJY-_0pAe5mRA==/109951165696893946.jpg', '最新欧美流行音乐排行榜', '流行', 2, 'testuser', 300, 15000, 8),
('深夜治愈系', 'https://p1.music.126.net/SUeqj8xv8hJY-_0pAe5mRA==/109951165696893946.jpg', '适合深夜聆听的治愈音乐', '轻音乐', 2, 'testuser', 400, 18000, 12);

-- 插入测试评论数据
INSERT INTO `comment` (`user_id`, `username`, `avatar`, `song_id`, `song_list_id`, `type`, `content`, `up`) VALUES
(2, 'testuser', 'https://p1.music.126.net/SUeqj8xv8hJY-_0pAe5mRA==/109951165696893946.jpg', 1, NULL, 0, '这首歌真的很好听！', 10),
(2, 'testuser', 'https://p1.music.126.net/SUeqj8xv8hJY-_0pAe5mRA==/109951165696893946.jpg', NULL, 1, 1, '这个歌单很棒，收藏了！', 8),
(1, 'admin', 'https://p1.music.126.net/SUeqj8xv8hJY-_0pAe5mRA==/109951165696893946.jpg', 1, NULL, 0, '经典老歌，回味无穷', 15);

-- 插入测试收藏数据
INSERT INTO `collect` (`user_id`, `song_list_id`) VALUES
(2, 1),
(2, 2),
(1, 1);

-- =====================================
-- 数据初始化完成
-- =====================================