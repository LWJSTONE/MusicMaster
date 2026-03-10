package com.musicmaster.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.musicmaster.dto.ResponseDTO;
import com.musicmaster.entity.Song;
import com.musicmaster.service.SongService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

/**
 * 歌曲管理控制器
 */
@RestController
@RequestMapping("/song")
@CrossOrigin
public class SongController {

    @Autowired
    private SongService songService;

    /**
     * 添加歌曲
     */
    @PostMapping
    public ResponseDTO addSong(@RequestBody Song song) {
        try {
            boolean result = songService.save(song);
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
     * 更新歌曲信息
     */
    @PutMapping
    public ResponseDTO updateSong(@RequestBody Song song) {
        try {
            boolean result = songService.updateById(song);
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
     * 删除歌曲
     */
    @DeleteMapping("/{id}")
    public ResponseDTO deleteSong(@PathVariable Long id) {
        try {
            boolean result = songService.removeById(id);
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
     * 分页查询歌曲列表
     */
    @GetMapping("/page")
    public ResponseDTO getSongPage(
            @RequestParam(defaultValue = "1") Integer current,
            @RequestParam(defaultValue = "10") Integer size,
            @RequestParam(required = false) String name,
            @RequestParam(required = false) Long singerId) {
        try {
            Page<Song> page = songService.getSongPage(current, size, name, singerId);
            return ResponseDTO.success(page);
        } catch (Exception e) {
            return ResponseDTO.error(e.getMessage());
        }
    }

    /**
     * 根据ID查询歌曲
     */
    @GetMapping("/{id}")
    public ResponseDTO getSongById(@PathVariable Long id) {
        try {
            Song song = songService.getById(id);
            if (song != null) {
                // 增加播放量
                songService.incrementPlayCount(id);
                return ResponseDTO.success(song);
            } else {
                return ResponseDTO.error("歌曲不存在");
            }
        } catch (Exception e) {
            return ResponseDTO.error(e.getMessage());
        }
    }

    /**
     * 更新歌曲图片
     */
    @PostMapping("/pic")
    public ResponseDTO updateSongPic(
            @RequestParam Long songId,
            @RequestParam MultipartFile file) {
        try {
            // 这里简化处理，实际应该上传文件并返回URL
            String picUrl = "https://example.com/song/" + songId + ".jpg";
            boolean result = songService.updatePic(songId, picUrl);
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
     * 更新歌曲URL
     */
    @PostMapping("/url")
    public ResponseDTO updateSongUrl(
            @RequestParam Long songId,
            @RequestParam MultipartFile file) {
        try {
            // 这里简化处理，实际应该上传文件并返回URL
            String url = "https://example.com/music/" + songId + ".mp3";
            boolean result = songService.updateUrl(songId, url);
            if (result) {
                return ResponseDTO.success("音乐更新成功", url);
            } else {
                return ResponseDTO.error("音乐更新失败");
            }
        } catch (Exception e) {
            return ResponseDTO.error(e.getMessage());
        }
    }

    /**
     * 查询所有歌曲
     */
    @GetMapping("/all")
    public ResponseDTO getAllSongs() {
        try {
            return ResponseDTO.success(songService.list());
        } catch (Exception e) {
            return ResponseDTO.error(e.getMessage());
        }
    }
}