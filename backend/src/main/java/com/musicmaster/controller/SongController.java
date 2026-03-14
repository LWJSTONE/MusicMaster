package com.musicmaster.controller;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.musicmaster.dto.ResponseDTO;
import com.musicmaster.entity.Song;
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
 * 歌曲管理控制器
 */
@RestController
@RequestMapping("/song")
@CrossOrigin
public class SongController {

    @Autowired
    private SongService songService;

    @Value("${file.upload.music-path:./uploads/music/}")
    private String musicPath;

    @Value("${file.upload.image-path:./uploads/image/}")
    private String imagePath;

    /**
     * 添加歌曲
     */
    @PostMapping
    public ResponseDTO addSong(@RequestBody Song song) {
        try {
            // 设置默认值
            if (song.getPlayCount() == null) {
                song.setPlayCount(0);
            }
            if (song.getCommentCount() == null) {
                song.setCommentCount(0);
            }
            if (song.getCollectCount() == null) {
                song.setCollectCount(0);
            }
            
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
     * 用户上传歌曲
     */
    @PostMapping("/upload-song")
    public ResponseDTO uploadSong(@RequestBody Song song) {
        try {
            if (song.getUploaderId() == null) {
                return ResponseDTO.paramError("上传者ID不能为空");
            }
            
            // 设置默认值
            if (song.getPlayCount() == null) {
                song.setPlayCount(0);
            }
            if (song.getCommentCount() == null) {
                song.setCommentCount(0);
            }
            if (song.getCollectCount() == null) {
                song.setCollectCount(0);
            }
            
            boolean result = songService.save(song);
            if (result) {
                return ResponseDTO.success("上传成功", song);
            } else {
                return ResponseDTO.error("上传失败");
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
     * 用户更新自己上传的歌曲
     */
    @PutMapping("/user/{id}")
    public ResponseDTO updateUserSong(
            @PathVariable Long id,
            @RequestBody Song song,
            @RequestParam Long userId) {
        try {
            // 验证歌曲是否是该用户上传的
            Song existingSong = songService.getById(id);
            if (existingSong == null) {
                return ResponseDTO.error("歌曲不存在");
            }
            if (existingSong.getUploaderId() == null || !existingSong.getUploaderId().equals(userId)) {
                return ResponseDTO.forbidden();
            }
            
            song.setId(id);
            // 保留原有的上传者信息
            song.setUploaderId(existingSong.getUploaderId());
            song.setUploaderName(existingSong.getUploaderName());
            
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
     * 用户删除自己上传的歌曲
     */
    @DeleteMapping("/user/{id}")
    public ResponseDTO deleteUserSong(@PathVariable Long id, @RequestParam Long userId) {
        try {
            // 验证歌曲是否是该用户上传的
            Song existingSong = songService.getById(id);
            if (existingSong == null) {
                return ResponseDTO.error("歌曲不存在");
            }
            if (existingSong.getUploaderId() == null || !existingSong.getUploaderId().equals(userId)) {
                return ResponseDTO.forbidden();
            }
            
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
     * 查询用户上传的歌曲
     */
    @GetMapping("/user/{userId}")
    public ResponseDTO getUserSongs(@PathVariable Long userId) {
        try {
            QueryWrapper<Song> queryWrapper = new QueryWrapper<>();
            queryWrapper.eq("uploader_id", userId);
            queryWrapper.orderByDesc("create_time");
            List<Song> songs = songService.list(queryWrapper);
            return ResponseDTO.success(songs);
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
     * 上传音乐文件
     */
    @PostMapping("/upload")
    public ResponseDTO uploadMusic(@RequestParam("file") MultipartFile file) {
        try {
            if (file.isEmpty()) {
                return ResponseDTO.paramError("请选择要上传的文件");
            }

            String originalFilename = file.getOriginalFilename();
            if (originalFilename == null) {
                return ResponseDTO.paramError("文件名无效");
            }

            // 检查文件扩展名
            String lowerName = originalFilename.toLowerCase();
            if (!lowerName.endsWith(".mp3") && !lowerName.endsWith(".wav")
                && !lowerName.endsWith(".ogg") && !lowerName.endsWith(".m4a")) {
                return ResponseDTO.paramError("不支持的文件格式，仅支持 MP3、WAV、OGG、M4A 格式");
            }

            // 创建上传目录
            File uploadDir = new File(musicPath);
            if (!uploadDir.exists()) {
                uploadDir.mkdirs();
            }

            // 生成唯一文件名
            String extension = originalFilename.substring(originalFilename.lastIndexOf("."));
            String newFilename = System.currentTimeMillis() + "_" + UUID.randomUUID().toString().substring(0, 8) + extension;
            Path filePath = Paths.get(musicPath, newFilename);

            // 保存文件
            Files.write(filePath, file.getBytes());

            // 返回访问URL - 使用 /api/uploads/music/ 作为前缀，确保通过后端context-path访问
            String url = "/api/uploads/music/" + newFilename;

            Map<String, Object> result = new HashMap<>();
            result.put("filename", newFilename);
            result.put("url", url);
            result.put("originalName", originalFilename);
            result.put("size", file.getSize());

            return ResponseDTO.success("上传成功", result);
        } catch (IOException e) {
            e.printStackTrace();
            return ResponseDTO.error("文件上传失败: " + e.getMessage());
        }
    }

    /**
     * 上传歌曲封面图片
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

            // 返回访问URL - 使用 /api/uploads/image/ 作为前缀
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
     * 更新歌曲URL（带songId参数）
     */
    @PostMapping("/url")
    public ResponseDTO updateSongUrl(
            @RequestParam Long songId,
            @RequestParam("file") MultipartFile file) {
        try {
            ResponseDTO uploadResult = uploadMusic(file);
            if (uploadResult.getCode() != 200) {
                return uploadResult;
            }

            @SuppressWarnings("unchecked")
            Map<String, Object> data = (Map<String, Object>) uploadResult.getData();
            String url = (String) data.get("url");

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
