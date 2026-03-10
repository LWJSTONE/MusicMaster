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
    public Page<Collect> getCollectPage(Integer current, Integer size, Long userId, Long songListId) {
        Page<Collect> page = new Page<>(current, size);
        QueryWrapper<Collect> queryWrapper = new QueryWrapper<>();

        if (userId != null) {
            queryWrapper.eq("user_id", userId);
        }
        if (songListId != null) {
            queryWrapper.eq("song_list_id", songListId);
        }

        queryWrapper.orderByDesc("create_time");
        return page(page, queryWrapper);
    }

    @Override
    public boolean isCollected(Long userId, Long songListId) {
        QueryWrapper<Collect> queryWrapper = new QueryWrapper<>();
        queryWrapper.eq("user_id", userId)
                    .eq("song_list_id", songListId);
        return count(queryWrapper) > 0;
    }
}