package com.musicmaster.controller;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.musicmaster.dto.ResponseDTO;
import com.musicmaster.entity.*;
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
            List<Map<String, Object>> styleList = new ArrayList<>();
            
            QueryWrapper<Song> songQueryWrapper = new QueryWrapper<>();
            songQueryWrapper.select("style", "COUNT(*) as count")
                .isNotNull("style")
                .ne("style", "")
                .groupBy("style")
                .orderByDesc("count")
                .last("LIMIT 10");
            
            List<Map<String, Object>> results = songMapper.selectMaps(songQueryWrapper);
            
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
            QueryWrapper<Song> queryWrapper = new QueryWrapper<>();
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
            List<Map<String, Object>> result = new ArrayList<>();
            
            QueryWrapper<Singer> singerQueryWrapper = new QueryWrapper<>();
            singerQueryWrapper.eq("deleted", 0);
            List<Singer> allSingers = singerMapper.selectList(singerQueryWrapper);
            
            for (Singer singer : allSingers) {
                Map<String, Object> item = new HashMap<>();
                item.put("id", singer.getId());
                item.put("name", singer.getName());
                item.put("pic", singer.getPic());
                
                // 统计该歌手的歌曲数
                QueryWrapper<Song> songCountWrapper = new QueryWrapper<>();
                songCountWrapper.eq("singer_id", singer.getId())
                    .eq("deleted", 0);
                Long songCount = songMapper.selectCount(songCountWrapper);
                item.put("songCount", songCount);
                
                // 统计该歌手的总播放量
                QueryWrapper<Song> playCountWrapper = new QueryWrapper<>();
                playCountWrapper.select("COALESCE(SUM(play_count), 0) as totalPlayCount")
                    .eq("singer_id", singer.getId())
                    .eq("deleted", 0);
                Map<String, Object> playCountResult = songMapper.selectMaps(playCountWrapper)
                    .stream().findFirst().orElse(new HashMap<>());
                
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
            QueryWrapper<SongList> queryWrapper = new QueryWrapper<>();
            queryWrapper.select("id", "title", "pic", "collect_count", "play_count", "song_count", "creator_name")
                .eq("deleted", 0)
                .orderByDesc("play_count")
                .last("LIMIT " + limit);
            
            List<Map<String, Object>> songLists = songListMapper.selectMaps(queryWrapper);
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
            QueryWrapper<User> queryWrapper = new QueryWrapper<>();
            queryWrapper.apply("DATE_FORMAT(create_time, '%Y-%m') as month, COUNT(*) as count")
                .eq("deleted", 0)
                .apply("create_time >= DATE_SUB(NOW(), INTERVAL " + months + " MONTH)")
                .groupBy("DATE_FORMAT(create_time, '%Y-%m')")
                .orderByAsc("month");
            
            List<Map<String, Object>> results = userMapper.selectMaps(queryWrapper);
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
            
            QueryWrapper<User> userQueryWrapper = new QueryWrapper<>();
            userQueryWrapper.select("id", "username", "nickname", "avatar")
                .eq("deleted", 0)
                .eq("status", 1);
            
            List<Map<String, Object>> users = userMapper.selectMaps(userQueryWrapper);
            
            for (Map<String, Object> user : users) {
                Long userId = ((Number) user.get("id")).longValue();
                
                Map<String, Object> item = new HashMap<>();
                item.put("userId", userId);
                item.put("username", user.get("username"));
                item.put("nickname", user.get("nickname"));
                item.put("avatar", user.get("avatar"));
                
                // 收藏数
                QueryWrapper<Collect> collectWrapper = new QueryWrapper<>();
                collectWrapper.eq("user_id", userId)
                    .eq("deleted", 0);
                Long collectCount = collectMapper.selectCount(collectWrapper);
                item.put("collectCount", collectCount);
                
                // 评论数
                QueryWrapper<Comment> commentWrapper = new QueryWrapper<>();
                commentWrapper.eq("user_id", userId)
                    .eq("deleted", 0);
                Long commentCount = commentMapper.selectCount(commentWrapper);
                item.put("commentCount", commentCount);
                
                // 上传歌曲数
                QueryWrapper<Song> songWrapper = new QueryWrapper<>();
                songWrapper.eq("uploader_id", userId)
                    .eq("deleted", 0);
                Long uploadCount = songMapper.selectCount(songWrapper);
                item.put("uploadCount", uploadCount);
                
                // 创建歌单数
                QueryWrapper<SongList> songListWrapper = new QueryWrapper<>();
                songListWrapper.eq("creator_id", userId)
                    .eq("deleted", 0);
                Long songListCount = songListMapper.selectCount(songListWrapper);
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
            QueryWrapper<Song> queryWrapper = new QueryWrapper<>();
            queryWrapper.select("id", "name", "singer_name", "uploader_name", "pic", "create_time")
                .eq("deleted", 0)
                .isNotNull("uploader_id")
                .orderByDesc("create_time")
                .last("LIMIT " + limit);
            
            List<Map<String, Object>> songs = songMapper.selectMaps(queryWrapper);
            return ResponseDTO.success(songs);
        } catch (Exception e) {
            return ResponseDTO.error(e.getMessage());
        }
    }
}
