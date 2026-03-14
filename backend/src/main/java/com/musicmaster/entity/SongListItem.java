package com.musicmaster.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import lombok.EqualsAndHashCode;
import java.time.LocalDateTime;

/**
 * 歌单歌曲关联实体类
 */
@Data
@EqualsAndHashCode(callSuper = false)
@TableName("song_list_item")
public class SongListItem {

    @TableId(value = "id", type = IdType.AUTO)
    private Long id;

    /**
     * 歌单ID
     */
    private Long songListId;

    /**
     * 歌曲ID
     */
    private Long songId;

    /**
     * 添加时间
     */
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createTime;

    /**
     * 删除标记：0-未删除，1-已删除
     */
    @TableLogic
    private Integer deleted;
}
