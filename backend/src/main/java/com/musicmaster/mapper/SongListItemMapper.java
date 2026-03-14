package com.musicmaster.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.musicmaster.entity.SongListItem;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.List;
import java.util.Map;

/**
 * 歌单歌曲关联Mapper
 */
@Mapper
public interface SongListItemMapper extends BaseMapper<SongListItem> {

    /**
     * 获取歌单中的歌曲列表
     */
    @Select("SELECT s.* FROM song s " +
            "INNER JOIN song_list_item sli ON s.id = sli.song_id " +
            "WHERE sli.song_list_id = #{songListId} AND sli.deleted = 0 AND s.deleted = 0 " +
            "ORDER BY sli.create_time DESC")
    List<Map<String, Object>> getSongsBySongListId(@Param("songListId") Long songListId);

    /**
     * 获取歌单中歌曲数量
     */
    @Select("SELECT COUNT(*) FROM song_list_item WHERE song_list_id = #{songListId} AND deleted = 0")
    Integer countBySongListId(@Param("songListId") Long songListId);
}
