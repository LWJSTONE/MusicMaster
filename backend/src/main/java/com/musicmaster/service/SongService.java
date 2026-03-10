package com.musicmaster.service;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.IService;
import com.musicmaster.entity.Song;

/**
 * 歌曲服务接口
 */
public interface SongService extends IService<Song> {

    /**
     * 分页查询歌曲列表
     * @param current 当前页
     * @param size 每页条数
     * @param name 歌曲名称（可选）
     * @param singerId 歌手ID（可选）
     * @return 分页结果
     */
    Page<Song> getSongPage(Integer current, Integer size, String name, Long singerId);

    /**
     * 更新歌曲播放量
     * @param songId 歌曲ID
     * @return 是否成功
     */
    boolean incrementPlayCount(Long songId);

    /**
     * 更新歌曲图片
     * @param songId 歌曲ID
     * @param pic 图片URL
     * @return 是否成功
     */
    boolean updatePic(Long songId, String pic);

    /**
     * 更新歌曲URL
     * @param songId 歌曲ID
     * @param url 歌曲URL
     * @return 是否成功
     */
    boolean updateUrl(Long songId, String url);
}