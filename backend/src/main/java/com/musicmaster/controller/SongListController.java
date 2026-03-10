package com.musicmaster.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.musicmaster.dto.ResponseDTO;
import com.musicmaster.entity.SongList;
import com.musicmaster.service.SongListService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

/**
 * 歌单管理控制器
 */
@RestController
@RequestMapping("/song-list")
@CrossOrigin
public class SongListController {

    @Autowired
    private SongListService songListService;

    /**
     * 添加歌单
     */
    @PostMapping
    public ResponseDTO addSongList(@RequestBody SongList songList) {
        try {
            boolean result = songListService.save(songList);
            if (result) {
                return ResponseDTO.success("添加成功");
            } else {
                return ResponseDTO.error("添加失败");
            }
        } catch (Exception e) {
            return ResponseDTO.error(e.getMessage());
        }
    }

    /**
     * 更新歌单信息
     */
    @PutMapping
    public ResponseDTO updateSongList(@RequestBody SongList songList) {
        try {
            boolean result = songListService.updateById(songList);
            if (result) {
                return ResponseDTO.success("更新成功");
            } else {
                return ResponseDTO.error("更新失败");
            }
        } catch (Exception e) {
            return ResponseDTO.error(e.getMessage());
        }
    }

    /**
     * 删除歌单
     */
    @DeleteMapping("/{id}")
    public ResponseDTO deleteSongList(@PathVariable Long id) {
        try {
            boolean result = songListService.removeById(id);
            if (result) {
                return ResponseDTO.success("删除成功");
            } else {
                return ResponseDTO.error("删除失败");
            }
        } catch (Exception e) {
            return ResponseDTO.error(e.getMessage());
        }
    }

    /**
     * 分页查询歌单列表
     */
    @GetMapping("/page")
    public ResponseDTO getSongListPage(
            @RequestParam(defaultValue = "1") Integer current,
            @RequestParam(defaultValue = "10") Integer size,
            @RequestParam(required = false) String title) {
        try {
            Page<SongList> page = songListService.getSongListPage(current, size, title);
            return ResponseDTO.success(page);
        } catch (Exception e) {
            return ResponseDTO.error(e.getMessage());
        }
    }

    /**
     * 根据ID查询歌单
     */
    @GetMapping("/{id}")
    public ResponseDTO getSongListById(@PathVariable Long id) {
        try {
            SongList songList = songListService.getById(id);
            if (songList != null) {
                // 增加播放量
                songListService.incrementPlayCount(id);
                return ResponseDTO.success(songList);
            } else {
                return ResponseDTO.error("歌单不存在");
            }
        } catch (Exception e) {
            return ResponseDTO.error(e.getMessage());
        }
    }

    /**
     * 更新歌单图片
     */
    @PostMapping("/pic")
    public ResponseDTO updateSongListPic(
            @RequestParam Long songListId,
            @RequestParam MultipartFile file) {
        try {
            // 这里简化处理，实际应该上传文件并返回URL
            String picUrl = "https://example.com/song-list/" + songListId + ".jpg";
            boolean result = songListService.updatePic(songListId, picUrl);
            if (result) {
                return ResponseDTO.success("图片更新成功", picUrl);
            } else {
                return ResponseDTO.error("图片更新失败");
            }
        } catch (Exception e) {
            return ResponseDTO.error(e.getMessage());
        }
    }

    /**
     * 查询所有歌单
     */
    @GetMapping("/all")
    public ResponseDTO getAllSongLists() {
        try {
            return ResponseDTO.success(songListService.list());
        } catch (Exception e) {
            return ResponseDTO.error(e.getMessage());
        }
    }
}