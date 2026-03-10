package com.musicmaster.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.musicmaster.entity.Song;
import org.apache.ibatis.annotations.Mapper;

/**
 * 歌曲数据访问接口
 */
@Mapper
public interface SongMapper extends BaseMapper<Song> {
}