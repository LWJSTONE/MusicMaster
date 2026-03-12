package com.musicmaster.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.musicmaster.entity.Comment;
import com.musicmaster.mapper.CommentMapper;
import com.musicmaster.service.CommentService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * 评论服务实现类
 */
@Service
public class CommentServiceImpl extends ServiceImpl<CommentMapper, Comment> implements CommentService {

    @Override
    public Page<Comment> getCommentPage(Integer current, Integer size, Long songId, Long songListId, Long userId) {
        Page<Comment> page = new Page<>(current, size);
        QueryWrapper<Comment> queryWrapper = new QueryWrapper<>();

        if (songId != null) {
            queryWrapper.eq("song_id", songId);
        }
        if (songListId != null) {
            queryWrapper.eq("song_list_id", songListId);
        }
        if (userId != null) {
            queryWrapper.eq("user_id", userId);
        }

        queryWrapper.orderByDesc("create_time");
        return page(page, queryWrapper);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean incrementUp(Long commentId) {
        Comment comment = getById(commentId);
        if (comment != null) {
            Integer up = comment.getUp() == null ? 0 : comment.getUp();
            comment.setUp(up + 1);
            return updateById(comment);
        }
        return false;
    }
}
