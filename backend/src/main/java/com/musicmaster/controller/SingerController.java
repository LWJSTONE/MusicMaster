package com.musicmaster.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.musicmaster.dto.ResponseDTO;
import com.musicmaster.entity.Singer;
import com.musicmaster.service.SingerService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

/**
 * 歌手管理控制器
 */
@RestController
@RequestMapping("/singer")
@CrossOrigin
public class SingerController {

    @Autowired
    private SingerService singerService;

    /**
     * 添加歌手
     */
    @PostMapping
    public ResponseDTO addSinger(@RequestBody Singer singer) {
        try {
            boolean result = singerService.save(singer);
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
     * 更新歌手信息
     */
    @PutMapping
    public ResponseDTO updateSinger(@RequestBody Singer singer) {
        try {
            boolean result = singerService.updateById(singer);
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
     * 删除歌手
     */
    @DeleteMapping("/{id}")
    public ResponseDTO deleteSinger(@PathVariable Long id) {
        try {
            boolean result = singerService.removeById(id);
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
     * 分页查询歌手列表
     */
    @GetMapping("/page")
    public ResponseDTO getSingerPage(
            @RequestParam(defaultValue = "1") Integer current,
            @RequestParam(defaultValue = "10") Integer size,
            @RequestParam(required = false) String name) {
        try {
            Page<Singer> page = singerService.getSingerPage(current, size, name);
            return ResponseDTO.success(page);
        } catch (Exception e) {
            return ResponseDTO.error(e.getMessage());
        }
    }

    /**
     * 根据ID查询歌手
     */
    @GetMapping("/{id}")
    public ResponseDTO getSingerById(@PathVariable Long id) {
        try {
            Singer singer = singerService.getById(id);
            if (singer != null) {
                return ResponseDTO.success(singer);
            } else {
                return ResponseDTO.error("歌手不存在");
            }
        } catch (Exception e) {
            return ResponseDTO.error(e.getMessage());
        }
    }

    /**
     * 更新歌手图片
     */
    @PostMapping("/pic")
    public ResponseDTO updateSingerPic(
            @RequestParam Long singerId,
            @RequestParam MultipartFile file) {
        try {
            // 这里简化处理，实际应该上传文件并返回URL
            String picUrl = "https://example.com/singer/" + singerId + ".jpg";
            boolean result = singerService.updatePic(singerId, picUrl);
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
     * 查询所有歌手
     */
    @GetMapping("/all")
    public ResponseDTO getAllSingers() {
        try {
            return ResponseDTO.success(singerService.list());
        } catch (Exception e) {
            return ResponseDTO.error(e.getMessage());
        }
    }
}