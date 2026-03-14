package com.musicmaster.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.musicmaster.entity.Song;
import com.musicmaster.entity.SongListItem;

import java.util.List;

/**
 * 歌单歌曲关联服务接口
 */
public interface SongListItemService extends IService<SongListItem> {

    /**
     * 获取歌单中的歌曲列表
     * @param songListId 歌单ID
     * @return 歌曲列表
     */
    List<Song> getSongsBySongListId(Long songListId);

    /**
     * 添加歌曲到歌单
     * @param songListId 歌单ID
     * @param songId 歌曲ID
     * @return 是否成功
     */
    boolean addSongToSongList(Long songListId, Long songId);

    /**
     * 从歌单移除歌曲
     * @param songListId 歌单ID
     * @param songId 歌曲ID
     * @return 是否成功
     */
    boolean removeSongFromSongList(Long songListId, Long songId);

    /**
     * 检查歌曲是否在歌单中
     * @param songListId 歌单ID
     * @param songId 歌曲ID
     * @return 是否存在
     */
    boolean isSongInSongList(Long songListId, Long songId);

    /**
     * 更新歌单歌曲数量
     * @param songListId 歌单ID
     */
    void updateSongCount(Long songListId);
}
