package com.musicmaster.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.musicmaster.entity.Song;
import com.musicmaster.entity.SongListItem;
import com.musicmaster.entity.SongList;
import com.musicmaster.mapper.SongListItemMapper;
import com.musicmaster.mapper.SongMapper;
import com.musicmaster.mapper.SongListMapper;
import com.musicmaster.service.SongListItemService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

/**
 * 歌单歌曲关联服务实现类
 */
@Service
public class SongListItemServiceImpl extends ServiceImpl<SongListItemMapper, SongListItem> implements SongListItemService {

    @Autowired
    private SongMapper songMapper;

    @Autowired
    private SongListMapper songListMapper;

    @Override
    public List<Song> getSongsBySongListId(Long songListId) {
        List<Map<String, Object>> songMaps = baseMapper.getSongsBySongListId(songListId);
        List<Song> songs = new ArrayList<>();
        
        for (Map<String, Object> map : songMaps) {
            Song song = new Song();
            song.setId(((Number) map.get("id")).longValue());
            song.setName((String) map.get("name"));
            song.setSingerId(map.get("singer_id") != null ? ((Number) map.get("singer_id")).longValue() : null);
            song.setSingerName((String) map.get("singer_name"));
            song.setAlbum((String) map.get("album"));
            song.setStyle((String) map.get("style"));
            song.setLanguage((String) map.get("language"));
            song.setUrl((String) map.get("url"));
            song.setPic((String) map.get("pic"));
            song.setDuration(map.get("duration") != null ? ((Number) map.get("duration")).intValue() : null);
            song.setPlayCount(map.get("play_count") != null ? ((Number) map.get("play_count")).intValue() : 0);
            song.setCommentCount(map.get("comment_count") != null ? ((Number) map.get("comment_count")).intValue() : 0);
            song.setCollectCount(map.get("collect_count") != null ? ((Number) map.get("collect_count")).intValue() : 0);
            songs.add(song);
        }
        
        return songs;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean addSongToSongList(Long songListId, Long songId) {
        // 检查歌曲是否已在歌单中
        if (isSongInSongList(songListId, songId)) {
            return false;
        }

        SongListItem item = new SongListItem();
        item.setSongListId(songListId);
        item.setSongId(songId);
        
        boolean result = save(item);
        if (result) {
            updateSongCount(songListId);
        }
        return result;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean removeSongFromSongList(Long songListId, Long songId) {
        QueryWrapper<SongListItem> queryWrapper = new QueryWrapper<>();
        queryWrapper.eq("song_list_id", songListId);
        queryWrapper.eq("song_id", songId);
        
        boolean result = remove(queryWrapper);
        if (result) {
            updateSongCount(songListId);
        }
        return result;
    }

    @Override
    public boolean isSongInSongList(Long songListId, Long songId) {
        QueryWrapper<SongListItem> queryWrapper = new QueryWrapper<>();
        queryWrapper.eq("song_list_id", songListId);
        queryWrapper.eq("song_id", songId);
        return count(queryWrapper) > 0;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void updateSongCount(Long songListId) {
        Integer count = baseMapper.countBySongListId(songListId);
        SongList songList = new SongList();
        songList.setId(songListId);
        songList.setSongCount(count != null ? count : 0);
        songListMapper.updateById(songList);
    }
}
