package com.musicmaster.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.musicmaster.entity.Singer;
import org.apache.ibatis.annotations.Mapper;

/**
 * 歌手数据访问接口
 */
@Mapper
public interface SingerMapper extends BaseMapper<Singer> {
}