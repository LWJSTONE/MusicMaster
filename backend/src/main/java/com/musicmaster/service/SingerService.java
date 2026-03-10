package com.musicmaster.service;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.IService;
import com.musicmaster.entity.Singer;

/**
 * 歌手服务接口
 */
public interface SingerService extends IService<Singer> {

    /**
     * 分页查询歌手列表
     * @param current 当前页
     * @param size 每页条数
     * @param name 歌手名称（可选）
     * @return 分页结果
     */
    Page<Singer> getSingerPage(Integer current, Integer size, String name);

    /**
     * 更新歌手图片
     * @param singerId 歌手ID
     * @param pic 图片URL
     * @return 是否成功
     */
    boolean updatePic(Long singerId, String pic);
}