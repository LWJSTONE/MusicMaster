package com.musicmaster.controller;

import com.musicmaster.dto.ResponseDTO;
import com.musicmaster.mapper.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.*;

/**
 * 数据统计控制器
 */
@RestController
@RequestMapping("/statistics")
@CrossOrigin
public class StatisticsController {

    @Autowired
    private UserMapper userMapper;

    @Autowired
    private SingerMapper singerMapper;

    @Autowired
    private SongMapper songMapper;

    @Autowired
    private SongListMapper songListMapper;

    @Autowired
    private CommentMapper commentMapper;

    @Autowired
    private CollectMapper collectMapper;

    /**
     * 获取概览统计数据
     */
    @GetMapping("/overview")
    public ResponseDTO getOverview() {
        try {
            Map<String, Object> overview = new HashMap<>();
            
            // 总用户数
            Long userCount = userMapper.selectCount(null);
            overview.put("userCount", userCount);
            
            // 总歌手数
            Long singerCount = singerMapper.selectCount(null);
            overview.put("singerCount", singerCount);
            
            // 总歌曲数
            Long songCount = songMapper.selectCount(null);
            overview.put("songCount", songCount);
            
            // 总歌单数
            Long songListCount = songListMapper.selectCount(null);
            overview.put("songListCount", songListCount);
            
            // 总评论数
            Long commentCount = commentMapper.selectCount(null);
            overview.put("commentCount", commentCount);
            
            // 总收藏数
            Long collectCount = collectMapper.selectCount(null);
            overview.put("collectCount", collectCount);
            
            return ResponseDTO.success(overview);
        } catch (Exception e) {
            return ResponseDTO.error(e.getMessage());
        }
    }

    /**
     * 获取歌曲风格分布
     */
    @GetMapping("/song-styles")
    public ResponseDTO getSongStyles() {
        try {
            // 查询所有歌曲的风格分布
            String sql = "SELECT style, COUNT(*) as count FROM song WHERE deleted = 0 AND style IS NOT NULL AND style != '' GROUP BY style ORDER BY count DESC LIMIT 10";
            
            // 使用原生查询
            List<Map<String, Object>> styleList = new ArrayList<>();
            
            // 简化处理：直接从song表查询
            List<Map<String, Object>> results = songMapper.selectMaps(
                new com.baomidou.mybatisplus.core.conditions.query.QueryWrapper<>()
                    .select("style", "COUNT(*) as count")
                    .isNotNull("style")
                    .ne("style", "")
                    .groupBy("style")
                    .orderByDesc("count")
                    .last("LIMIT 10")
            );
            
            // 计算总数
            long total = results.stream().mapToLong(m -> ((Number) m.get("count")).longValue()).sum();
            
            // 颜色数组
            String[] colors = {"#409EFF", "#67C23A", "#E6A23C", "#F56C6C", "#909399", "#00BCD4", "#9C27B0", "#FF5722", "#795548", "#607D8B"};
            
            for (int i = 0; i < results.size(); i++) {
                Map<String, Object> item = new HashMap<>();
                Map<String, Object> result = results.get(i);
                String style = (String) result.get("style");
                long count = ((Number) result.get("count")).longValue();
                int percentage = total > 0 ? (int) ((count * 100) / total) : 0;
                
                item.put("name", style);
                item.put("value", count);
                item.put("percentage", percentage);
                item.put("color", colors[i % colors.length]);
                styleList.add(item);
            }
            
            return ResponseDTO.success(styleList);
        } catch (Exception e) {
            return ResponseDTO.error(e.getMessage());
        }
    }

    /**
     * 获取最受欢迎歌曲
     */
    @GetMapping("/top-songs")
    public ResponseDTO getTopSongs(@RequestParam(defaultValue = "10") Integer limit) {
        try {
            com.baomidou.mybatisplus.core.conditions.query.QueryWrapper<com.musicmaster.entity.Song> queryWrapper = 
                new com.baomidou.mybatisplus.core.conditions.query.QueryWrapper<>();
            queryWrapper.select("id", "name", "singer_name", "play_count", "pic")
                .orderByDesc("play_count")
                .last("LIMIT " + limit);
            
            List<Map<String, Object>> songs = songMapper.selectMaps(queryWrapper);
            return ResponseDTO.success(songs);
        } catch (Exception e) {
            return ResponseDTO.error(e.getMessage());
        }
    }

    /**
     * 获取最受欢迎歌手
     */
    @GetMapping("/top-singers")
    public ResponseDTO getTopSingers(@RequestParam(defaultValue = "10") Integer limit) {
        try {
            // 按歌手的歌曲播放量总和排序
            String sql = "SELECT s.id, s.name, s.pic, COUNT(song.id) as song_count, " +
                        "COALESCE(SUM(song.play_count), 0) as total_play_count " +
                        "FROM singer s " +
                        "LEFT JOIN song ON s.id = song.singer_id AND song.deleted = 0 " +
                        "WHERE s.deleted = 0 " +
                        "GROUP BY s.id, s.name, s.pic " +
                        "ORDER BY total_play_count DESC " +
                        "LIMIT " + limit;
            
            List<Map<String, Object>> singers = singerMapper.selectMaps(
                new com.baomidou.mybatisplus.core.conditions.query.QueryWrapper<>()
                    .apply(sql)
            );
            
            // 使用简化的查询方式
            List<Map<String, Object>> result = new ArrayList<>();
            List<com.musicmaster.entity.Singer> allSingers = singerMapper.selectList(
                new com.baomidou.mybatisplus.core.conditions.query.QueryWrapper<com.musicmaster.entity.Singer>()
                    .eq("deleted", 0)
            );
            
            for (com.musicmaster.entity.Singer singer : allSingers) {
                Map<String, Object> item = new HashMap<>();
                item.put("id", singer.getId());
                item.put("name", singer.getName());
                item.put("pic", singer.getPic());
                
                // 统计该歌手的歌曲数
                Long songCount = songMapper.selectCount(
                    new com.baomidou.mybatisplus.core.conditions.query.QueryWrapper<com.musicmaster.entity.Song>()
                        .eq("singer_id", singer.getId())
                        .eq("deleted", 0)
                );
                item.put("songCount", songCount);
                
                // 统计该歌手的总播放量
                Map<String, Object> playCountResult = songMapper.selectMaps(
                    new com.baomidou.mybatisplus.core.conditions.query.QueryWrapper<com.musicmaster.entity.Song>()
                        .select("COALESCE(SUM(play_count), 0) as totalPlayCount")
                        .eq("singer_id", singer.getId())
                        .eq("deleted", 0)
                ).stream().findFirst().orElse(new HashMap<>());
                
                item.put("playCount", playCountResult.getOrDefault("totalPlayCount", 0));
                result.add(item);
            }
            
            // 按播放量排序
            result.sort((a, b) -> {
                Long playA = ((Number) a.get("playCount")).longValue();
                Long playB = ((Number) b.get("playCount")).longValue();
                return playB.compareTo(playA);
            });
            
            // 限制返回数量
            if (result.size() > limit) {
                result = result.subList(0, limit);
            }
            
            return ResponseDTO.success(result);
        } catch (Exception e) {
            return ResponseDTO.error(e.getMessage());
        }
    }

    /**
     * 获取最受欢迎歌单
     */
    @GetMapping("/top-songlists")
    public ResponseDTO getTopSongLists(@RequestParam(defaultValue = "10") Integer limit) {
        try {
            List<Map<String, Object>> songLists = songListMapper.selectMaps(
                new com.baomidou.mybatisplus.core.conditions.query.QueryWrapper<>()
                    .select("id", "title", "pic", "collect_count", "play_count", "song_count", "creator_name")
                    .eq("deleted", 0)
                    .orderByDesc("play_count")
                    .last("LIMIT " + limit)
            );
            return ResponseDTO.success(songLists);
        } catch (Exception e) {
            return ResponseDTO.error(e.getMessage());
        }
    }

    /**
     * 获取用户增长趋势（按月）
     */
    @GetMapping("/user-trend")
    public ResponseDTO getUserTrend(@RequestParam(defaultValue = "12") Integer months) {
        try {
            // 获取最近N个月的用户注册数据
            List<Map<String, Object>> trend = new ArrayList<>();
            
            // 简化处理：返回实际用户总数和每月新增
            String sql = "SELECT DATE_FORMAT(create_time, '%Y-%m') as month, COUNT(*) as count " +
                        "FROM user WHERE deleted = 0 " +
                        "AND create_time >= DATE_SUB(NOW(), INTERVAL " + months + " MONTH) " +
                        "GROUP BY DATE_FORMAT(create_time, '%Y-%m') " +
                        "ORDER BY month ASC";
            
            List<Map<String, Object>> results = userMapper.selectMaps(
                new com.baomidou.mybatisplus.core.conditions.query.QueryWrapper<>()
                    .apply(sql)
            );
            
            return ResponseDTO.success(results);
        } catch (Exception e) {
            return ResponseDTO.error(e.getMessage());
        }
    }

    /**
     * 获取活跃用户排行
     */
    @GetMapping("/active-users")
    public ResponseDTO getActiveUsers(@RequestParam(defaultValue = "10") Integer limit) {
        try {
            // 根据用户的收藏数和评论数统计活跃度
            List<Map<String, Object>> activeUsers = new ArrayList<>();
            
            List<Map<String, Object>> users = userMapper.selectMaps(
                new com.baomidou.mybatisplus.core.conditions.query.QueryWrapper<>()
                    .select("id", "username", "nickname", "avatar")
                    .eq("deleted", 0)
                    .eq("status", 1)
            );
            
            for (Map<String, Object> user : users) {
                Long userId = ((Number) user.get("id")).longValue();
                
                Map<String, Object> item = new HashMap<>();
                item.put("userId", userId);
                item.put("username", user.get("username"));
                item.put("nickname", user.get("nickname"));
                item.put("avatar", user.get("avatar"));
                
                // 收藏数
                Long collectCount = collectMapper.selectCount(
                    new com.baomidou.mybatisplus.core.conditions.query.QueryWrapper<com.musicmaster.entity.Collect>()
                        .eq("user_id", userId)
                        .eq("deleted", 0)
                );
                item.put("collectCount", collectCount);
                
                // 评论数
                Long commentCount = commentMapper.selectCount(
                    new com.baomidou.mybatisplus.core.conditions.query.QueryWrapper<com.musicmaster.entity.Comment>()
                        .eq("user_id", userId)
                        .eq("deleted", 0)
                );
                item.put("commentCount", commentCount);
                
                // 上传歌曲数
                Long uploadCount = songMapper.selectCount(
                    new com.baomidou.mybatisplus.core.conditions.query.QueryWrapper<com.musicmaster.entity.Song>()
                        .eq("uploader_id", userId)
                        .eq("deleted", 0)
                );
                item.put("uploadCount", uploadCount);
                
                // 创建歌单数
                Long songListCount = songListMapper.selectCount(
                    new com.baomidou.mybatisplus.core.conditions.query.QueryWrapper<com.musicmaster.entity.SongList>()
                        .eq("creator_id", userId)
                        .eq("deleted", 0)
                );
                item.put("songListCount", songListCount);
                
                activeUsers.add(item);
            }
            
            // 按活跃度排序（收藏数 + 评论数 + 上传数 + 歌单数）
            activeUsers.sort((a, b) -> {
                int scoreA = ((Number) a.get("collectCount")).intValue() + 
                            ((Number) a.get("commentCount")).intValue() +
                            ((Number) a.get("uploadCount")).intValue() * 5 +
                            ((Number) a.get("songListCount")).intValue() * 3;
                int scoreB = ((Number) b.get("collectCount")).intValue() + 
                            ((Number) b.get("commentCount")).intValue() +
                            ((Number) b.get("uploadCount")).intValue() * 5 +
                            ((Number) b.get("songListCount")).intValue() * 3;
                return scoreB - scoreA;
            });
            
            // 限制返回数量
            if (activeUsers.size() > limit) {
                activeUsers = activeUsers.subList(0, limit);
            }
            
            return ResponseDTO.success(activeUsers);
        } catch (Exception e) {
            return ResponseDTO.error(e.getMessage());
        }
    }

    /**
     * 获取最近上传的歌曲
     */
    @GetMapping("/recent-uploads")
    public ResponseDTO getRecentUploads(@RequestParam(defaultValue = "10") Integer limit) {
        try {
            List<Map<String, Object>> songs = songMapper.selectMaps(
                new com.baomidou.mybatisplus.core.conditions.query.QueryWrapper<>()
                    .select("id", "name", "singer_name", "uploader_name", "pic", "create_time")
                    .eq("deleted", 0)
                    .isNotNull("uploader_id")
                    .orderByDesc("create_time")
                    .last("LIMIT " + limit)
            );
            return ResponseDTO.success(songs);
        } catch (Exception e) {
            return ResponseDTO.error(e.getMessage());
        }
    }
}
