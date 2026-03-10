package com.musicmaster.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import lombok.EqualsAndHashCode;
import java.time.LocalDateTime;

/**
 * 歌单实体类
 */
@Data
@EqualsAndHashCode(callSuper = false)
@TableName("song_list")
public class SongList {

    @TableId(value = "id", type = IdType.AUTO)
    private Long id;

    /**
     * 歌单标题
     */
    private String title;

    /**
     * 歌单封面图片URL
     */
    private String pic;

    /**
     * 歌单简介
     */
    private String introduction;

    /**
     * 风格
     */
    private String style;

    /**
     * 创建者ID
     */
    private Long creatorId;

    /**
     * 创建者用户名（冗余字段）
     */
    private String creatorName;

    /**
     * 收藏数
     */
    private Integer collectCount;

    /**
     * 播放量
     */
    private Integer playCount;

    /**
     * 歌曲数量
     */
    private Integer songCount;

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