package com.musicmaster.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import lombok.EqualsAndHashCode;
import java.time.LocalDateTime;

/**
 * 收藏实体类（用户收藏歌单/歌曲）
 */
@Data
@EqualsAndHashCode(callSuper = false)
@TableName("collect")
public class Collect {

    @TableId(value = "id", type = IdType.AUTO)
    private Long id;

    /**
     * 用户ID
     */
    private Long userId;

    /**
     * 收藏类型：0-歌单收藏，1-歌曲收藏
     */
    private Integer type;

    /**
     * 歌单ID（type=0时使用）
     */
    private Long songListId;

    /**
     * 歌曲ID（type=1时使用）
     */
    private Long songId;

    /**
     * 收藏时间
     */
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createTime;

    /**
     * 删除标记：0-未删除，1-已删除
     */
    @TableLogic
    private Integer deleted;
}
