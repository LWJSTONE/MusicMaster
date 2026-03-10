package com.musicmaster.service;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.IService;
import com.musicmaster.entity.SongList;

/**
 * 歌单服务接口
 */
public interface SongListService extends IService<SongList> {

    /**
     * 分页查询歌单列表
     * @param current 当前页
     * @param size 每页条数
     * @param title 歌单标题（可选）
     * @return 分页结果
     */
    Page<SongList> getSongListPage(Integer current, Integer size, String title);

    /**
     * 更新歌单播放量
     * @param songListId 歌单ID
     * @return 是否成功
     */
    boolean incrementPlayCount(Long songListId);

    /**
     * 更新歌单图片
     * @param songListId 歌单ID
     * @param pic 图片URL
     * @return 是否成功
     */
    boolean updatePic(Long songListId, String pic);
}