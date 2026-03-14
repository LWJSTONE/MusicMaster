package com.musicmaster.controller;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.musicmaster.dto.ResponseDTO;
import com.musicmaster.entity.Song;
import com.musicmaster.entity.SongList;
import com.musicmaster.entity.SongListItem;
import com.musicmaster.service.SongListItemService;
import com.musicmaster.service.SongListService;
import com.musicmaster.service.SongService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

/**
 * 歌单管理控制器
 */
@RestController
@RequestMapping("/song-list")
@CrossOrigin
public class SongListController {

    @Autowired
    private SongListService songListService;

    @Autowired
    private SongListItemService songListItemService;

    @Autowired
    private SongService songService;

    @Value("${file.upload.image-path:./uploads/image/}")
    private String imagePath;

    /**
     * 添加歌单
     */
    @PostMapping
    public ResponseDTO addSongList(@RequestBody SongList songList) {
        try {
            // 设置默认值
            if (songList.getCollectCount() == null) {
                songList.setCollectCount(0);
            }
            if (songList.getPlayCount() == null) {
                songList.setPlayCount(0);
            }
            if (songList.getSongCount() == null) {
                songList.setSongCount(0);
            }
            
            boolean result = songListService.save(songList);
            if (result) {
                return ResponseDTO.success("添加成功", songList);
            } else {
                return ResponseDTO.error("添加失败");
            }
        } catch (Exception e) {
            return ResponseDTO.error(e.getMessage());
        }
    }

    /**
     * 用户创建歌单
     */
    @PostMapping("/create")
    public ResponseDTO createSongList(@RequestBody SongList songList) {
        try {
            if (songList.getCreatorId() == null) {
                return ResponseDTO.paramError("创建者ID不能为空");
            }
            
            // 设置默认值
            if (songList.getCollectCount() == null) {
                songList.setCollectCount(0);
            }
            if (songList.getPlayCount() == null) {
                songList.setPlayCount(0);
            }
            if (songList.getSongCount() == null) {
                songList.setSongCount(0);
            }
            if (songList.getPic() == null || songList.getPic().isEmpty()) {
                songList.setPic("https://p1.music.126.net/SUeqj8xv8hJY-_0pAe5mRA==/109951165696893946.jpg");
            }
            
            boolean result = songListService.save(songList);
            if (result) {
                return ResponseDTO.success("创建成功", songList);
            } else {
                return ResponseDTO.error("创建失败");
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
     * 用户更新自己的歌单
     */
    @PutMapping("/user/{id}")
    public ResponseDTO updateUserSongList(
            @PathVariable Long id,
            @RequestBody SongList songList,
            @RequestParam Long userId) {
        try {
            // 验证歌单是否属于该用户
            SongList existingSongList = songListService.getById(id);
            if (existingSongList == null) {
                return ResponseDTO.error("歌单不存在");
            }
            if (!existingSongList.getCreatorId().equals(userId)) {
                return ResponseDTO.forbidden();
            }
            
            songList.setId(id);
            // 保留原有的创建者信息
            songList.setCreatorId(existingSongList.getCreatorId());
            songList.setCreatorName(existingSongList.getCreatorName());
            
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
     * 用户删除自己的歌单
     */
    @DeleteMapping("/user/{id}")
    public ResponseDTO deleteUserSongList(@PathVariable Long id, @RequestParam Long userId) {
        try {
            // 验证歌单是否属于该用户
            SongList existingSongList = songListService.getById(id);
            if (existingSongList == null) {
                return ResponseDTO.error("歌单不存在");
            }
            if (!existingSongList.getCreatorId().equals(userId)) {
                return ResponseDTO.forbidden();
            }
            
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
     * 查询用户创建的歌单
     */
    @GetMapping("/user/{userId}")
    public ResponseDTO getUserSongLists(@PathVariable Long userId) {
        try {
            QueryWrapper<SongList> queryWrapper = new QueryWrapper<>();
            queryWrapper.eq("creator_id", userId);
            queryWrapper.orderByDesc("create_time");
            List<SongList> songLists = songListService.list(queryWrapper);
            return ResponseDTO.success(songLists);
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
     * 获取歌单中的歌曲
     */
    @GetMapping("/{id}/songs")
    public ResponseDTO getSongListSongs(@PathVariable Long id) {
        try {
            List<Song> songs = songListItemService.getSongsBySongListId(id);
            return ResponseDTO.success(songs);
        } catch (Exception e) {
            return ResponseDTO.error(e.getMessage());
        }
    }

    /**
     * 添加歌曲到歌单
     */
    @PostMapping("/{songListId}/songs/{songId}")
    public ResponseDTO addSongToSongList(
            @PathVariable Long songListId,
            @PathVariable Long songId) {
        try {
            // 验证歌曲是否存在
            Song song = songService.getById(songId);
            if (song == null) {
                return ResponseDTO.error("歌曲不存在");
            }
            
            // 检查歌曲是否已在歌单中
            if (songListItemService.isSongInSongList(songListId, songId)) {
                return ResponseDTO.paramError("歌曲已在歌单中");
            }
            
            boolean result = songListItemService.addSongToSongList(songListId, songId);
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
     * 从歌单移除歌曲
     */
    @DeleteMapping("/{songListId}/songs/{songId}")
    public ResponseDTO removeSongFromSongList(
            @PathVariable Long songListId,
            @PathVariable Long songId) {
        try {
            boolean result = songListItemService.removeSongFromSongList(songListId, songId);
            if (result) {
                return ResponseDTO.success("移除成功");
            } else {
                return ResponseDTO.error("移除失败");
            }
        } catch (Exception e) {
            return ResponseDTO.error(e.getMessage());
        }
    }

    /**
     * 上传歌单封面图片
     */
    @PostMapping("/pic")
    public ResponseDTO uploadPic(@RequestParam("file") MultipartFile file) {
        try {
            if (file.isEmpty()) {
                return ResponseDTO.paramError("请选择要上传的图片");
            }

            String originalFilename = file.getOriginalFilename();
            if (originalFilename == null) {
                return ResponseDTO.paramError("文件名无效");
            }

            // 检查文件扩展名
            String lowerName = originalFilename.toLowerCase();
            if (!lowerName.endsWith(".jpg") && !lowerName.endsWith(".jpeg")
                && !lowerName.endsWith(".png") && !lowerName.endsWith(".gif")
                && !lowerName.endsWith(".webp")) {
                return ResponseDTO.paramError("不支持的图片格式，仅支持 JPG、PNG、GIF、WebP 格式");
            }

            // 创建上传目录
            File uploadDir = new File(imagePath);
            if (!uploadDir.exists()) {
                uploadDir.mkdirs();
            }

            // 生成唯一文件名
            String extension = originalFilename.substring(originalFilename.lastIndexOf("."));
            String newFilename = System.currentTimeMillis() + "_" + UUID.randomUUID().toString().substring(0, 8) + extension;
            Path filePath = Paths.get(imagePath, newFilename);

            // 保存文件
            Files.write(filePath, file.getBytes());

            // 返回访问URL
            String url = "/api/uploads/image/" + newFilename;

            Map<String, Object> result = new HashMap<>();
            result.put("filename", newFilename);
            result.put("url", url);
            result.put("originalName", originalFilename);
            result.put("size", file.getSize());

            return ResponseDTO.success("上传成功", result);
        } catch (IOException e) {
            e.printStackTrace();
            return ResponseDTO.error("图片上传失败: " + e.getMessage());
        }
    }

    /**
     * 更新歌单图片
     */
    @PostMapping("/{id}/pic")
    public ResponseDTO updateSongListPic(
            @PathVariable Long id,
            @RequestParam("file") MultipartFile file) {
        try {
            ResponseDTO uploadResult = uploadPic(file);
            if (uploadResult.getCode() != 200) {
                return uploadResult;
            }

            @SuppressWarnings("unchecked")
            Map<String, Object> data = (Map<String, Object>) uploadResult.getData();
            String url = (String) data.get("url");

            boolean result = songListService.updatePic(id, url);
            if (result) {
                return ResponseDTO.success("图片更新成功", url);
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
