package com.musicmaster.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import lombok.EqualsAndHashCode;
import java.time.LocalDateTime;

/**
 * 歌曲实体类
 */
@Data
@EqualsAndHashCode(callSuper = false)
@TableName("song")
public class Song {

    @TableId(value = "id", type = IdType.AUTO)
    private Long id;

    /**
     * 歌曲名称
     */
    private String name;

    /**
     * 歌手ID
     */
    private Long singerId;

    /**
     * 歌手名称（冗余字段，方便查询）
     */
    private String singerName;

    /**
     * 专辑名称
     */
    private String album;

    /**
     * 歌曲风格（流行、摇滚、民谣等）
     */
    private String style;

    /**
     * 歌曲语言（国语、英语、日语等）
     */
    private String language;

    /**
     * 歌曲URL
     */
    private String url;

    /**
     * 歌曲封面图片URL
     */
    private String pic;

    /**
     * 歌曲时长（秒）
     */
    private Integer duration;

    /**
     * 播放量
     */
    private Integer playCount;

    /**
     * 评论数
     */
    private Integer commentCount;

    /**
     * 收藏数
     */
    private Integer collectCount;

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