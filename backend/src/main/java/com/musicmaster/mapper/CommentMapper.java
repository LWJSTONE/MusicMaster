package com.musicmaster.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.musicmaster.entity.Comment;
import org.apache.ibatis.annotations.Mapper;

/**
 * 评论数据访问接口
 */
@Mapper
public interface CommentMapper extends BaseMapper<Comment> {
}