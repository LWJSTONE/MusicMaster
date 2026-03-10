package com.musicmaster.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.musicmaster.entity.Singer;
import com.musicmaster.mapper.SingerMapper;
import com.musicmaster.service.SingerService;
import org.apache.commons.lang3.StringUtils;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * 歌手服务实现类
 */
@Service
public class SingerServiceImpl extends ServiceImpl<SingerMapper, Singer> implements SingerService {

    @Override
    public Page<Singer> getSingerPage(Integer current, Integer size, String name) {
        Page<Singer> page = new Page<>(current, size);
        QueryWrapper<Singer> queryWrapper = new QueryWrapper<>();

        if (StringUtils.isNotBlank(name)) {
            queryWrapper.like("name", name);
        }

        queryWrapper.orderByDesc("create_time");
        return page(page, queryWrapper);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean updatePic(Long singerId, String pic) {
        Singer singer = new Singer();
        singer.setId(singerId);
        singer.setPic(pic);
        return updateById(singer);
    }
}