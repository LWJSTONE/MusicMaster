package com.musicmaster.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.musicmaster.entity.Collect;
import org.apache.ibatis.annotations.Mapper;

/**
 * 收藏数据访问接口
 */
@Mapper
public interface CollectMapper extends BaseMapper<Collect> {
}