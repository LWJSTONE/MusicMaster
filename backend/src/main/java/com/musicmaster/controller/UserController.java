package com.musicmaster.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.musicmaster.dto.ResponseDTO;
import com.musicmaster.entity.User;
import com.musicmaster.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

/**
 * 用户管理控制器
 */
@RestController
@RequestMapping("/user")
@CrossOrigin
public class UserController {

    @Autowired
    private UserService userService;

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