package com.musicmaster.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.musicmaster.dto.ResponseDTO;
import com.musicmaster.entity.Collect;
import com.musicmaster.service.CollectService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

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
     * 添加收藏
     */
    @PostMapping
    public ResponseDTO addCollect(@RequestBody Collect collect) {
        try {
            // 检查是否已收藏
            if (collectService.isCollected(collect.getUserId(), collect.getSongListId())) {
                return ResponseDTO.paramError("已收藏该歌单");
            }

            boolean result = collectService.save(collect);
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
     * 取消收藏
     */
    @DeleteMapping
    public ResponseDTO deleteCollect(
            @RequestParam Long userId,
            @RequestParam Long songListId) {
        try {
            // 使用查询条件删除
            boolean result = collectService.lambdaUpdate()
                    .eq(Collect::getUserId, userId)
                    .eq(Collect::getSongListId, songListId)
                    .remove();
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
            @RequestParam(required = false) Long songListId) {
        try {
            Page<Collect> page = collectService.getCollectPage(current, size, userId, songListId);
            return ResponseDTO.success(page);
        } catch (Exception e) {
            return ResponseDTO.error(e.getMessage());
        }
    }

    /**
     * 检查是否已收藏
     */
    @GetMapping("/check")
    public ResponseDTO checkCollect(
            @RequestParam Long userId,
            @RequestParam Long songListId) {
        try {
            boolean isCollected = collectService.isCollected(userId, songListId);
            return ResponseDTO.success(isCollected);
        } catch (Exception e) {
            return ResponseDTO.error(e.getMessage());
        }
    }
}