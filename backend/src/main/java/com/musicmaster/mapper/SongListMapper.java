package com.musicmaster.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.musicmaster.entity.SongList;
import org.apache.ibatis.annotations.Mapper;

/**
 * 歌单数据访问接口
 */
@Mapper
public interface SongListMapper extends BaseMapper<SongList> {
}