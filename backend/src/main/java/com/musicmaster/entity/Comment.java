package com.musicmaster.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import lombok.EqualsAndHashCode;
import java.time.LocalDateTime;

/**
 * 评论实体类
 */
@Data
@EqualsAndHashCode(callSuper = false)
@TableName("comment")
public class Comment {

    @TableId(value = "id", type = IdType.AUTO)
    private Long id;

    /**
     * 用户ID
     */
    private Long userId;

    /**
     * 用户名（冗余字段）
     */
    private String username;

    /**
     * 用户头像
     */
    private String avatar;

    /**
     * 歌曲ID
     */
    private Long songId;

    /**
     * 歌单ID
     */
    private Long songListId;

    /**
     * 评论类型：0-歌曲评论，1-歌单评论
     */
    private Integer type;

    /**
     * 评论内容
     */
    private String content;

    /**
     * 点赞数
     */
    private Integer up;

    /**
     * 创建时间
     */
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createTime;

    /**
     * 更新时间
     */
    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updateTime;

    /**
     * 删除标记：0-未删除，1-已删除
     */
    @TableLogic
    private Integer deleted;
}