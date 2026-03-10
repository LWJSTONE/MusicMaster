package com.musicmaster.service;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.IService;
import com.musicmaster.entity.User;

/**
 * 用户服务接口
 */
public interface UserService extends IService<User> {

    /**
     * 分页查询用户列表
     * @param current 当前页
     * @param size 每页条数
     * @param username 用户名（可选）
     * @return 分页结果
     */
    Page<User> getUserPage(Integer current, Integer size, String username);

    /**
     * 用户登录
     * @param username 用户名
     * @param password 密码
     * @return 登录用户信息
     */
    User login(String username, String password);

    /**
     * 检查用户名是否存在
     * @param username 用户名
     * @return 存在返回true
     */
    boolean existsByUsername(String username);

    /**
     * 更新用户状态
     * @param userId 用户ID
     * @param status 状态
     * @return 是否成功
     */
    boolean updateStatus(Long userId, Integer status);
}