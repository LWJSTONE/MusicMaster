package com.musicmaster.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.musicmaster.dto.ResponseDTO;
import com.musicmaster.entity.Collect;
import com.musicmaster.service.CollectService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

/**
 * 收藏管理控制器
 */
@RestController
@RequestMapping("/collect")
@CrossOrigin
public class CollectController {

    @Autowired
    private CollectService collectService;

    /**
     * 添加歌单收藏
     */
    @PostMapping("/songlist")
    public ResponseDTO addSongListCollect(@RequestBody Map<String, Long> params) {
        try {
            Long userId = params.get("userId");
            Long songListId = params.get("songListId");
            
            if (userId == null || songListId == null) {
                return ResponseDTO.paramError("参数不完整");
            }

            if (collectService.isCollectedSongList(userId, songListId)) {
                return ResponseDTO.paramError("已收藏该歌单");
            }

            boolean result = collectService.addSongListCollect(userId, songListId);
            if (result) {
                return ResponseDTO.success("收藏成功");
            } else {
                return ResponseDTO.error("收藏失败");
            }
        } catch (Exception e) {
            return ResponseDTO.error(e.getMessage());
        }
    }

    /**
     * 添加歌曲收藏
     */
    @PostMapping("/song")
    public ResponseDTO addSongCollect(@RequestBody Map<String, Long> params) {
        try {
            Long userId = params.get("userId");
            Long songId = params.get("songId");
            
            if (userId == null || songId == null) {
                return ResponseDTO.paramError("参数不完整");
            }

            if (collectService.isCollectedSong(userId, songId)) {
                return ResponseDTO.paramError("已收藏该歌曲");
            }

            boolean result = collectService.addSongCollect(userId, songId);
            if (result) {
                return ResponseDTO.success("收藏成功");
            } else {
                return ResponseDTO.error("收藏失败");
            }
        } catch (Exception e) {
            return ResponseDTO.error(e.getMessage());
        }
    }

    /**
     * 取消歌单收藏
     */
    @DeleteMapping("/songlist")
    public ResponseDTO deleteSongListCollect(
            @RequestParam Long userId,
            @RequestParam Long songListId) {
        try {
            boolean result = collectService.removeSongListCollect(userId, songListId);
            if (result) {
                return ResponseDTO.success("取消收藏成功");
            } else {
                return ResponseDTO.error("取消收藏失败");
            }
        } catch (Exception e) {
            return ResponseDTO.error(e.getMessage());
        }
    }

    /**
     * 取消歌曲收藏
     */
    @DeleteMapping("/song")
    public ResponseDTO deleteSongCollect(
            @RequestParam Long userId,
            @RequestParam Long songId) {
        try {
            boolean result = collectService.removeSongCollect(userId, songId);
            if (result) {
                return ResponseDTO.success("取消收藏成功");
            } else {
                return ResponseDTO.error("取消收藏失败");
            }
        } catch (Exception e) {
            return ResponseDTO.error(e.getMessage());
        }
    }

    /**
     * 兼容旧接口：添加收藏（歌单）
     */
    @PostMapping
    public ResponseDTO addCollect(@RequestBody Collect collect) {
        try {
            // 默认为歌单收藏
            if (collect.getType() == null) {
                collect.setType(0);
            }
            
            if (collect.getType() == 0) {
                // 歌单收藏
                if (collectService.isCollectedSongList(collect.getUserId(), collect.getSongListId())) {
                    return ResponseDTO.paramError("已收藏该歌单");
                }
                boolean result = collectService.addSongListCollect(collect.getUserId(), collect.getSongListId());
                if (result) {
                    return ResponseDTO.success("收藏成功");
                }
            } else if (collect.getType() == 1) {
                // 歌曲收藏
                if (collectService.isCollectedSong(collect.getUserId(), collect.getSongId())) {
                    return ResponseDTO.paramError("已收藏该歌曲");
                }
                boolean result = collectService.addSongCollect(collect.getUserId(), collect.getSongId());
                if (result) {
                    return ResponseDTO.success("收藏成功");
                }
            }
            return ResponseDTO.error("收藏失败");
        } catch (Exception e) {
            return ResponseDTO.error(e.getMessage());
        }
    }

    /**
     * 兼容旧接口：取消收藏（歌单）
     */
    @DeleteMapping
    public ResponseDTO deleteCollect(
            @RequestParam Long userId,
            @RequestParam Long songListId) {
        try {
            boolean result = collectService.removeSongListCollect(userId, songListId);
            if (result) {
                return ResponseDTO.success("取消收藏成功");
            } else {
                return ResponseDTO.error("取消收藏失败");
            }
        } catch (Exception e) {
            return ResponseDTO.error(e.getMessage());
        }
    }

    /**
     * 分页查询收藏列表
     */
    @GetMapping("/page")
    public ResponseDTO getCollectPage(
            @RequestParam(defaultValue = "1") Integer current,
            @RequestParam(defaultValue = "10") Integer size,
            @RequestParam(required = false) Long userId,
            @RequestParam(required = false) Long songListId,
            @RequestParam(required = false) Long songId,
            @RequestParam(required = false) Integer type) {
        try {
            Page<Collect> page = collectService.getCollectPage(current, size, userId, songListId, songId, type);
            return ResponseDTO.success(page);
        } catch (Exception e) {
            return ResponseDTO.error(e.getMessage());
        }
    }

    /**
     * 检查歌单是否已收藏
     */
    @GetMapping("/check/songlist")
    public ResponseDTO checkSongListCollect(
            @RequestParam Long userId,
            @RequestParam Long songListId) {
        try {
            boolean isCollected = collectService.isCollectedSongList(userId, songListId);
            return ResponseDTO.success(isCollected);
        } catch (Exception e) {
            return ResponseDTO.error(e.getMessage());
        }
    }

    /**
     * 检查歌曲是否已收藏
     */
    @GetMapping("/check/song")
    public ResponseDTO checkSongCollect(
            @RequestParam Long userId,
            @RequestParam Long songId) {
        try {
            boolean isCollected = collectService.isCollectedSong(userId, songId);
            return ResponseDTO.success(isCollected);
        } catch (Exception e) {
            return ResponseDTO.error(e.getMessage());
        }
    }

    /**
     * 兼容旧接口：检查是否已收藏
     */
    @GetMapping("/check")
    public ResponseDTO checkCollect(
            @RequestParam Long userId,
            @RequestParam Long songListId) {
        try {
            boolean isCollected = collectService.isCollectedSongList(userId, songListId);
            return ResponseDTO.success(isCollected);
        } catch (Exception e) {
            return ResponseDTO.error(e.getMessage());
        }
    }
}
