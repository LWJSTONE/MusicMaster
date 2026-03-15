package com.musicmaster.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.musicmaster.entity.Collect;
import com.musicmaster.mapper.CollectMapper;
import com.musicmaster.service.CollectService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * 收藏服务实现类
 */
@Service
public class CollectServiceImpl extends ServiceImpl<CollectMapper, Collect> implements CollectService {

    @Override
    public Page<Collect> getCollectPage(Integer current, Integer size, Long userId, Long songListId, Long songId, Integer type) {
        Page<Collect> page = new Page<>(current, size);
        QueryWrapper<Collect> queryWrapper = new QueryWrapper<>();

        if (userId != null) {
            queryWrapper.eq("user_id", userId);
        }
        if (songListId != null) {
            queryWrapper.eq("song_list_id", songListId);
        }
        if (songId != null) {
            queryWrapper.eq("song_id", songId);
        }
        if (type != null) {
            queryWrapper.eq("type", type);
        }

        queryWrapper.orderByDesc("create_time");
        return page(page, queryWrapper);
    }

    @Override
    public boolean isCollectedSongList(Long userId, Long songListId) {
        QueryWrapper<Collect> queryWrapper = new QueryWrapper<>();
        queryWrapper.eq("user_id", userId)
                    .eq("song_list_id", songListId)
                    .eq("type", 0);
        return count(queryWrapper) > 0;
    }

    @Override
    public boolean isCollectedSong(Long userId, Long songId) {
        QueryWrapper<Collect> queryWrapper = new QueryWrapper<>();
        queryWrapper.eq("user_id", userId)
                    .eq("song_id", songId)
                    .eq("type", 1);
        return count(queryWrapper) > 0;
    }

    @Override
    @Transactional
    public boolean addSongListCollect(Long userId, Long songListId) {
        if (isCollectedSongList(userId, songListId)) {
            return false;
        }
        Collect collect = new Collect();
        collect.setUserId(userId);
        collect.setSongListId(songListId);
        collect.setType(0);
        return save(collect);
    }

    @Override
    @Transactional
    public boolean addSongCollect(Long userId, Long songId) {
        if (isCollectedSong(userId, songId)) {
            return false;
        }
        Collect collect = new Collect();
        collect.setUserId(userId);
        collect.setSongId(songId);
        collect.setType(1);
        return save(collect);
    }

    @Override
    @Transactional
    public boolean removeSongListCollect(Long userId, Long songListId) {
        QueryWrapper<Collect> queryWrapper = new QueryWrapper<>();
        queryWrapper.eq("user_id", userId)
                    .eq("song_list_id", songListId)
                    .eq("type", 0);
        return remove(queryWrapper);
    }

    @Override
    @Transactional
    public boolean removeSongCollect(Long userId, Long songId) {
        QueryWrapper<Collect> queryWrapper = new QueryWrapper<>();
        queryWrapper.eq("user_id", userId)
                    .eq("song_id", songId)
                    .eq("type", 1);
        return remove(queryWrapper);
    }
}
