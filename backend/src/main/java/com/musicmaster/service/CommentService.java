package com.musicmaster.service;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.IService;
import com.musicmaster.entity.Comment;

/**
 * 评论服务接口
 */
public interface CommentService extends IService<Comment> {

    /**
     * 分页查询评论列表
     * @param current 当前页
     * @param size 每页条数
     * @param songId 歌曲ID（可选）
     * @param songListId 歌单ID（可选）
     * @return 分页结果
     */
    Page<Comment> getCommentPage(Integer current, Integer size, Long songId, Long songListId);

    /**
     * 点赞评论
     * @param commentId 评论ID
     * @return 是否成功
     */
    boolean incrementUp(Long commentId);
}