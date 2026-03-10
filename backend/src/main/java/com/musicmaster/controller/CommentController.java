package com.musicmaster.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.musicmaster.dto.ResponseDTO;
import com.musicmaster.entity.Comment;
import com.musicmaster.service.CommentService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

/**
 * 评论管理控制器
 */
@RestController
@RequestMapping("/comment")
@CrossOrigin
public class CommentController {

    @Autowired
    private CommentService commentService;

    /**
     * 添加评论
     */
    @PostMapping
    public ResponseDTO addComment(@RequestBody Comment comment) {
        try {
            boolean result = commentService.save(comment);
            if (result) {
                return ResponseDTO.success("评论成功");
            } else {
                return ResponseDTO.error("评论失败");
            }
        } catch (Exception e) {
            return ResponseDTO.error(e.getMessage());
        }
    }

    /**
     * 更新评论
     */
    @PutMapping
    public ResponseDTO updateComment(@RequestBody Comment comment) {
        try {
            boolean result = commentService.updateById(comment);
            if (result) {
                return ResponseDTO.success("更新成功");
            } else {
                return ResponseDTO.error("更新失败");
            }
        } catch (Exception e) {
            return ResponseDTO.error(e.getMessage());
        }
    }

    /**
     * 删除评论
     */
    @DeleteMapping("/{id}")
    public ResponseDTO deleteComment(@PathVariable Long id) {
        try {
            boolean result = commentService.removeById(id);
            if (result) {
                return ResponseDTO.success("删除成功");
            } else {
                return ResponseDTO.error("删除失败");
            }
        } catch (Exception e) {
            return ResponseDTO.error(e.getMessage());
        }
    }

    /**
     * 分页查询评论列表
     */
    @GetMapping("/page")
    public ResponseDTO getCommentPage(
            @RequestParam(defaultValue = "1") Integer current,
            @RequestParam(defaultValue = "10") Integer size,
            @RequestParam(required = false) Long songId,
            @RequestParam(required = false) Long songListId) {
        try {
            Page<Comment> page = commentService.getCommentPage(current, size, songId, songListId);
            return ResponseDTO.success(page);
        } catch (Exception e) {
            return ResponseDTO.error(e.getMessage());
        }
    }

    /**
     * 点赞评论
     */
    @PostMapping("/up/{id}")
    public ResponseDTO incrementUp(@PathVariable Long id) {
        try {
            boolean result = commentService.incrementUp(id);
            if (result) {
                return ResponseDTO.success("点赞成功");
            } else {
                return ResponseDTO.error("点赞失败");
            }
        } catch (Exception e) {
            return ResponseDTO.error(e.getMessage());
        }
    }

    /**
     * 根据ID查询评论
     */
    @GetMapping("/{id}")
    public ResponseDTO getCommentById(@PathVariable Long id) {
        try {
            Comment comment = commentService.getById(id);
            if (comment != null) {
                return ResponseDTO.success(comment);
            } else {
                return ResponseDTO.error("评论不存在");
            }
        } catch (Exception e) {
            return ResponseDTO.error(e.getMessage());
        }
    }
}