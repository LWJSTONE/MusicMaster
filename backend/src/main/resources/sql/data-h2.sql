-- =====================================
-- MusicMaster 音乐管理系统 H2数据库初始数据
-- =====================================

-- 插入管理员用户（密码：123456，使用BCrypt加密）
INSERT INTO t_user (username, password, nickname, email, phone, avatar, role, status) VALUES
('admin', '$2a$10$EqKHNa0s0Y/bnvQDnhOvq.J7XVTvH0y3OjBvVZPhYw0LMKvMqK9eG', '系统管理员', 'admin@musicmaster.com', '13800138000', 'https://p1.music.126.net/SUeqj8xv8hJY-_0pAe5mRA==/109951165696893946.jpg', 1, 1);

-- 插入示例歌手数据
INSERT INTO singer (name, sex, birth, location, introduction, pic) VALUES
('周杰伦', 1, '1979-01-18', '中国台湾', '华语流行乐男歌手、音乐人、演员、导演、编剧', 'https://p1.music.126.net/Hy7lRYcFdnxlvQgp0xZoyA==/109951169707043500.jpg'),
('林俊杰', 1, '1981-03-27', '新加坡', '华语流行乐男歌手、词曲创作人、音乐制作人', 'https://p1.music.126.net/K1emj3WH4nLrZfEO3aybpg==/109951165783224421.jpg'),
('邓紫棋', 0, '1991-08-16', '中国香港', '华语流行乐女歌手、词曲创作人', 'https://p1.music.126.net/DBI7dLL4elDSD-qSR-9Faw==/109951168223191882.jpg'),
('薛之谦', 1, '1983-07-17', '中国上海', '华语流行乐男歌手、影视演员、音乐制作人', 'https://p1.music.126.net/LCW3G5x9h-QJ5tB6W5m9CA==/109951169761005803.jpg'),
('Taylor Swift', 0, '1989-12-13', '美国', '美国创作型歌手、音乐制作人', 'https://p1.music.126.net/t8WDM1iCLcDxhL3fv6XW-g==/109951169727528776.jpg');

-- 插入示例歌曲数据
INSERT INTO song (name, singer_id, singer_name, album, style, language, duration, play_count) VALUES
('稻香', 1, '周杰伦', '魔杰座', '流行', '国语', 223, 10000),
('晴天', 1, '周杰伦', '叶惠美', '流行', '国语', 269, 15000),
('修炼爱情', 2, '林俊杰', '因你而在', '流行', '国语', 289, 8000),
('江南', 2, '林俊杰', '江南', '流行', '国语', 254, 12000),
('光年之外', 3, '邓紫棋', '光年之外', '流行', '国语', 235, 9000),
('演员', 4, '薛之谦', '绅士', '流行', '国语', 289, 11000);

-- 插入示例歌单数据
INSERT INTO song_list (title, pic, introduction, style, creator_id, creator_name, song_count) VALUES
('经典华语金曲', 'https://p1.music.126.net/DrRII6rL7r9f2g6GRNbBaQ==/18686100125337124.jpg', '精选华语流行金曲，带你重温经典', '流行', 1, 'admin', 3),
('深夜情歌', 'https://p1.music.126.net/34jVOWRFM4r0SkNDydC9uQ==/109951169508707566.jpg', '深夜独享，温柔入眠', '抒情', 1, 'admin', 2);

-- 插入歌单歌曲关联数据
INSERT INTO song_list_item (song_list_id, song_id) VALUES
(1, 1),
(1, 2),
(1, 3),
(2, 4),
(2, 5);
