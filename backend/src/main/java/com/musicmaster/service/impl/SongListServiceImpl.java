package com.musicmaster.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.musicmaster.entity.SongList;
import com.musicmaster.mapper.SongListMapper;
import com.musicmaster.service.SongListService;
import org.apache.commons.lang3.StringUtils;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * 歌单服务实现类
 */
@Service
public class SongListServiceImpl extends ServiceImpl<SongListMapper, SongList> implements SongListService {

    @Override
    public Page<SongList> getSongListPage(Integer current, Integer size, String title) {
        Page<SongList> page = new Page<>(current, size);
        QueryWrapper<SongList> queryWrapper = new QueryWrapper<>();

        if (StringUtils.isNotBlank(title)) {
            queryWrapper.like("title", title);
        }

        queryWrapper.orderByDesc("create_time");
        return page(page, queryWrapper);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean incrementPlayCount(Long songListId) {
        SongList songList = getById(songListId);
        if (songList != null) {
            Integer playCount = songList.getPlayCount() == null ? 0 : songList.getPlayCount();
            songList.setPlayCount(playCount + 1);
            return updateById(songList);
        }
        return false;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean updatePic(Long songListId, String pic) {
        SongList songList = new SongList();
        songList.setId(songListId);
        songList.setPic(pic);
        return updateById(songList);
    }
}