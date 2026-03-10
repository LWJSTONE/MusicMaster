package com.musicmaster.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.musicmaster.entity.User;
import com.musicmaster.mapper.UserMapper;
import com.musicmaster.service.UserService;
import org.apache.commons.lang3.StringUtils;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * 用户服务实现类
 */
@Service
public class UserServiceImpl extends ServiceImpl<UserMapper, User> implements UserService {

    private final BCryptPasswordEncoder passwordEncoder = new BCryptPasswordEncoder();

    @Override
    public Page<User> getUserPage(Integer current, Integer size, String username) {
        Page<User> page = new Page<>(current, size);
        QueryWrapper<User> queryWrapper = new QueryWrapper<>();

        if (StringUtils.isNotBlank(username)) {
            queryWrapper.like("username", username).or().like("nickname", username);
        }

        // 不返回密码
        queryWrapper.select("id", "username", "nickname", "email", "phone", "avatar", "role", "status", "create_time", "update_time");
        return page(page, queryWrapper);
    }

    @Override
    public User login(String username, String password) {
        QueryWrapper<User> queryWrapper = new QueryWrapper<>();
        queryWrapper.eq("username", username);
        User user = getOne(queryWrapper);

        if (user != null && passwordEncoder.matches(password, user.getPassword())) {
            if (user.getStatus() == 0) {
                throw new RuntimeException("账号已被禁用");
            }
            return user;
        }
        throw new RuntimeException("用户名或密码错误");
    }

    @Override
    public boolean existsByUsername(String username) {
        QueryWrapper<User> queryWrapper = new QueryWrapper<>();
        queryWrapper.eq("username", username);
        return count(queryWrapper) > 0;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean updateStatus(Long userId, Integer status) {
        User user = new User();
        user.setId(userId);
        user.setStatus(status);
        return updateById(user);
    }

    /**
     * 保存用户时自动加密密码
     */
    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean save(User entity) {
        if (StringUtils.isNotBlank(entity.getPassword())) {
            entity.setPassword(passwordEncoder.encode(entity.getPassword()));
        }
        return super.save(entity);
    }

    /**
     * 更新用户时加密新密码
     */
    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean updateById(User entity) {
        if (StringUtils.isNotBlank(entity.getPassword())) {
            entity.setPassword(passwordEncoder.encode(entity.getPassword()));
        }
        return super.updateById(entity);
    }
}