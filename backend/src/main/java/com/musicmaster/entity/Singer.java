package com.musicmaster.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import lombok.EqualsAndHashCode;
import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * 歌手实体类
 */
@Data
@EqualsAndHashCode(callSuper = false)
@TableName("singer")
public class Singer {

    @TableId(value = "id", type = IdType.AUTO)
    private Long id;

    /**
     * 歌手姓名
     */
    private String name;

    /**
     * 性别：0-女，1-男，2-组合
     */
    private Integer sex;

    /**
     * 出生日期
     */
    private LocalDate birth;

    /**
     * 地区
     */
    private String location;

    /**
     * 简介
     */
    private String introduction;

    /**
     * 歌手头像URL
     */
    private String pic;

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