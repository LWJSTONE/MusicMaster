package com.musicmaster.service;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.IService;
import com.musicmaster.entity.Collect;

/**
 * 收藏服务接口
 */
public interface CollectService extends IService<Collect> {

    /**
     * 分页查询收藏列表
     * @param current 当前页
     * @param size 每页条数
     * @param userId 用户ID（可选）
     * @param songListId 歌单ID（可选）
     * @param songId 歌曲ID（可选）
     * @param type 收藏类型（可选）
     * @return 分页结果
     */
    Page<Collect> getCollectPage(Integer current, Integer size, Long userId, Long songListId, Long songId, Integer type);

    /**
     * 检查是否已收藏歌单
     * @param userId 用户ID
     * @param songListId 歌单ID
     * @return 是否已收藏
     */
    boolean isCollectedSongList(Long userId, Long songListId);

    /**
     * 检查是否已收藏歌曲
     * @param userId 用户ID
     * @param songId 歌曲ID
     * @return 是否已收藏
     */
    boolean isCollectedSong(Long userId, Long songId);

    /**
     * 添加歌单收藏
     * @param userId 用户ID
     * @param songListId 歌单ID
     * @return 是否成功
     */
    boolean addSongListCollect(Long userId, Long songListId);

    /**
     * 添加歌曲收藏
     * @param userId 用户ID
     * @param songId 歌曲ID
     * @return 是否成功
     */
    boolean addSongCollect(Long userId, Long songId);

    /**
     * 取消歌单收藏
     * @param userId 用户ID
     * @param songListId 歌单ID
     * @return 是否成功
     */
    boolean removeSongListCollect(Long userId, Long songListId);

    /**
     * 取消歌曲收藏
     * @param userId 用户ID
     * @param songId 歌曲ID
     * @return 是否成功
     */
    boolean removeSongCollect(Long userId, Long songId);
}
