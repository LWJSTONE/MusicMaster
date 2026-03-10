package com.musicmaster.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.musicmaster.entity.Song;
import com.musicmaster.mapper.SongMapper;
import com.musicmaster.service.SongService;
import org.apache.commons.lang3.StringUtils;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * 歌曲服务实现类
 */
@Service
public class SongServiceImpl extends ServiceImpl<SongMapper, Song> implements SongService {

    @Override
    public Page<Song> getSongPage(Integer current, Integer size, String name, Long singerId) {
        Page<Song> page = new Page<>(current, size);
        QueryWrapper<Song> queryWrapper = new QueryWrapper<>();

        if (StringUtils.isNotBlank(name)) {
            queryWrapper.like("name", name);
        }
        if (singerId != null) {
            queryWrapper.eq("singer_id", singerId);
        }

        queryWrapper.orderByDesc("create_time");
        return page(page, queryWrapper);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean incrementPlayCount(Long songId) {
        Song song = getById(songId);
        if (song != null) {
            Integer playCount = song.getPlayCount() == null ? 0 : song.getPlayCount();
            song.setPlayCount(playCount + 1);
            return updateById(song);
        }
        return false;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean updatePic(Long songId, String pic) {
        Song song = new Song();
        song.setId(songId);
        song.setPic(pic);
        return updateById(song);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean updateUrl(Long songId, String url) {
        Song song = new Song();
        song.setId(songId);
        song.setUrl(url);
        return updateById(song);
    }
}