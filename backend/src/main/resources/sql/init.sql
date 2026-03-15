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
  `type` tinyint(4) DEFAULT '0' COMMENT '收藏类型：0-歌单收藏，1-歌曲收藏',
  `song_list_id` bigint(20) DEFAULT NULL COMMENT '歌单ID（type=0时使用）',
  `song_id` bigint(20) DEFAULT NULL COMMENT '歌曲ID（type=1时使用）',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '收藏时间',
  `deleted` tinyint(4) DEFAULT '0' COMMENT '删除标记：0-未删除，1-已删除',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_user_song_list` (`user_id`, `song_list_id`, `type`),
  UNIQUE KEY `uk_user_song` (`user_id`, `song_id`, `type`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_song_list_id` (`song_list_id`),
  KEY `idx_song_id` (`song_id`),
  KEY `idx_type` (`type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='收藏表';

-- =====================================
-- 歌单歌曲关联表
-- =====================================
DROP TABLE IF EXISTS `song_list_item`;
CREATE TABLE `song_list_item` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '关联ID',
  `song_list_id` bigint(20) NOT NULL COMMENT '歌单ID',
  `song_id` bigint(20) NOT NULL COMMENT '歌曲ID',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '添加时间',
  `deleted` tinyint(4) DEFAULT '0' COMMENT '删除标记：0-未删除，1-已删除',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_song_list_song` (`song_list_id`, `song_id`),
  KEY `idx_song_list_id` (`song_list_id`),
  KEY `idx_song_id` (`song_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='歌单歌曲关联表';

-- =====================================
-- 歌曲上传者关联字段（为song表添加uploader_id字段）
-- =====================================
ALTER TABLE `song` ADD COLUMN `uploader_id` bigint(20) DEFAULT NULL COMMENT '上传者用户ID' AFTER `collect_count`;
ALTER TABLE `song` ADD COLUMN `uploader_name` varchar(50) DEFAULT NULL COMMENT '上传者用户名' AFTER `uploader_id`;
ALTER TABLE `song` ADD INDEX `idx_uploader_id` (`uploader_id`);

-- =====================================
-- 初始化数据
-- =====================================

-- 插入管理员用户（密码：123456）
INSERT INTO `user` (`username`, `password`, `nickname`, `email`, `phone`, `avatar`, `role`, `status`) VALUES
('admin', '$2a$10$EqKHNa0s0Y/bnvQDnhOvq.J7XVTvH0y3OjBvVZPhYw0LMKvMqK9eG', '系统管理员', 'admin@musicmaster.com', '13800138000', 'https://p1.music.126.net/SUeqj8xv8hJY-_0pAe5mRA==/109951165696893946.jpg', 1, 1);

-- =====================================
-- 数据初始化完成
-- =====================================

-- =====================================
-- 数据库升级脚本（收藏表添加歌曲收藏支持）
-- 如需升级现有数据库，请执行以下语句：
-- =====================================
-- ALTER TABLE `collect` ADD COLUMN `type` tinyint(4) DEFAULT '0' COMMENT '收藏类型：0-歌单收藏，1-歌曲收藏' AFTER `user_id`;
-- ALTER TABLE `collect` ADD COLUMN `song_id` bigint(20) DEFAULT NULL COMMENT '歌曲ID（type=1时使用）' AFTER `song_list_id`;
-- ALTER TABLE `collect` DROP INDEX `uk_user_song_list`;
-- ALTER TABLE `collect` ADD UNIQUE KEY `uk_user_song_list` (`user_id`, `song_list_id`, `type`);
-- ALTER TABLE `collect` ADD UNIQUE KEY `uk_user_song` (`user_id`, `song_id`, `type`);
-- ALTER TABLE `collect` ADD INDEX `idx_song_id` (`song_id`);
-- ALTER TABLE `collect` ADD INDEX `idx_type` (`type`);
-- ALTER TABLE `collect` MODIFY COLUMN `song_list_id` bigint(20) DEFAULT NULL COMMENT '歌单ID（type=0时使用）';
-- UPDATE `collect` SET `type` = 0 WHERE `type` IS NULL;