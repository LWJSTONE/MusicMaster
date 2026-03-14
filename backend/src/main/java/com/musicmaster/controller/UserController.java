package com.musicmaster.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.musicmaster.dto.ResponseDTO;
import com.musicmaster.entity.User;
import com.musicmaster.service.UserService;
import org.apache.commons.lang3.StringUtils;
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
import java.util.Map;
import java.util.UUID;

/**
 * 用户管理控制器
 */
@RestController
@RequestMapping("/user")
@CrossOrigin
public class UserController {

    @Autowired
    private UserService userService;

    @Value("${file.upload.image-path:./uploads/image/}")
    private String imagePath;

    /**
     * 用户登录
     */
    @PostMapping("/login")
    public ResponseDTO login(@RequestBody User user) {
        try {
            User loginUser = userService.login(user.getUsername(), user.getPassword());
            loginUser.setPassword(null); // 不返回密码
            return ResponseDTO.success("登录成功", loginUser);
        } catch (Exception e) {
            return ResponseDTO.error(e.getMessage());
        }
    }

    /**
     * 用户注册
     */
    @PostMapping("/register")
    public ResponseDTO register(@RequestBody User user) {
        try {
            // 检查用户名是否存在
            if (userService.existsByUsername(user.getUsername())) {
                return ResponseDTO.paramError("用户名已存在");
            }

            // 设置默认值
            user.setRole(0); // 普通用户
            user.setStatus(1); // 启用状态
            user.setAvatar("https://p1.music.126.net/SUeqj8xv8hJY-_0pAe5mRA==/109951165696893946.jpg");

            boolean result = userService.save(user);
            if (result) {
                return ResponseDTO.success("注册成功");
            } else {
                return ResponseDTO.error("注册失败");
            }
        } catch (Exception e) {
            return ResponseDTO.error(e.getMessage());
        }
    }

    /**
     * 分页查询用户列表
     */
    @GetMapping("/page")
    public ResponseDTO getUserPage(
            @RequestParam(defaultValue = "1") Integer current,
            @RequestParam(defaultValue = "10") Integer size,
            @RequestParam(required = false) String username) {
        try {
            Page<User> page = userService.getUserPage(current, size, username);
            return ResponseDTO.success(page);
        } catch (Exception e) {
            return ResponseDTO.error(e.getMessage());
        }
    }

    /**
     * 根据ID查询用户
     */
    @GetMapping("/{id}")
    public ResponseDTO getUserById(@PathVariable Long id) {
        try {
            User user = userService.getById(id);
            if (user != null) {
                user.setPassword(null); // 不返回密码
                return ResponseDTO.success(user);
            } else {
                return ResponseDTO.error("用户不存在");
            }
        } catch (Exception e) {
            return ResponseDTO.error(e.getMessage());
        }
    }

    /**
     * 更新用户信息
     */
    @PutMapping
    public ResponseDTO updateUser(@RequestBody User user) {
        try {
            boolean result = userService.updateById(user);
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
     * 用户更新自己的个人信息
     */
    @PutMapping("/profile")
    public ResponseDTO updateProfile(@RequestBody User user) {
        try {
            if (user.getId() == null) {
                return ResponseDTO.paramError("用户ID不能为空");
            }
            
            // 验证用户是否存在
            User existingUser = userService.getById(user.getId());
            if (existingUser == null) {
                return ResponseDTO.error("用户不存在");
            }
            
            // 只允许更新部分字段
            User updateUser = new User();
            updateUser.setId(user.getId());
            if (StringUtils.isNotBlank(user.getNickname())) {
                updateUser.setNickname(user.getNickname());
            }
            if (StringUtils.isNotBlank(user.getEmail())) {
                updateUser.setEmail(user.getEmail());
            }
            if (StringUtils.isNotBlank(user.getPhone())) {
                updateUser.setPhone(user.getPhone());
            }
            if (StringUtils.isNotBlank(user.getAvatar())) {
                updateUser.setAvatar(user.getAvatar());
            }
            // 密码单独处理
            if (StringUtils.isNotBlank(user.getPassword())) {
                updateUser.setPassword(user.getPassword());
            }
            
            boolean result = userService.updateById(updateUser);
            if (result) {
                // 返回更新后的用户信息
                User updatedUser = userService.getById(user.getId());
                updatedUser.setPassword(null);
                return ResponseDTO.success("更新成功", updatedUser);
            } else {
                return ResponseDTO.error("更新失败");
            }
        } catch (Exception e) {
            return ResponseDTO.error(e.getMessage());
        }
    }

    /**
     * 上传用户头像
     */
    @PostMapping("/avatar")
    public ResponseDTO uploadAvatar(@RequestParam("file") MultipartFile file, @RequestParam Long userId) {
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
            String newFilename = "avatar_" + userId + "_" + System.currentTimeMillis() + extension;
            Path filePath = Paths.get(imagePath, newFilename);

            // 保存文件
            Files.write(filePath, file.getBytes());

            // 返回访问URL
            String url = "/api/uploads/image/" + newFilename;

            // 更新用户头像
            User user = new User();
            user.setId(userId);
            user.setAvatar(url);
            userService.updateById(user);

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
     * 修改密码
     */
    @PutMapping("/password")
    public ResponseDTO updatePassword(
            @RequestParam Long userId,
            @RequestParam String oldPassword,
            @RequestParam String newPassword) {
        try {
            // 验证旧密码
            User user = userService.getById(userId);
            if (user == null) {
                return ResponseDTO.error("用户不存在");
            }
            
            // 验证旧密码是否正确
            User loginUser = userService.login(user.getUsername(), oldPassword);
            if (loginUser == null) {
                return ResponseDTO.paramError("旧密码错误");
            }
            
            // 更新密码
            User updateUser = new User();
            updateUser.setId(userId);
            updateUser.setPassword(newPassword);
            
            boolean result = userService.updateById(updateUser);
            if (result) {
                return ResponseDTO.success("密码修改成功");
            } else {
                return ResponseDTO.error("密码修改失败");
            }
        } catch (Exception e) {
            return ResponseDTO.error("旧密码错误");
        }
    }

    /**
     * 更新用户状态
     */
    @PutMapping("/status")
    public ResponseDTO updateStatus(@RequestParam Long userId, @RequestParam Integer status) {
        try {
            boolean result = userService.updateStatus(userId, status);
            if (result) {
                return ResponseDTO.success("状态更新成功");
            } else {
                return ResponseDTO.error("状态更新失败");
            }
        } catch (Exception e) {
            return ResponseDTO.error(e.getMessage());
        }
    }

    /**
     * 删除用户
     */
    @DeleteMapping("/{id}")
    public ResponseDTO deleteUser(@PathVariable Long id) {
        try {
            boolean result = userService.removeById(id);
            if (result) {
                return ResponseDTO.success("删除成功");
            } else {
                return ResponseDTO.error("删除失败");
            }
        } catch (Exception e) {
            return ResponseDTO.error(e.getMessage());
        }
    }
}