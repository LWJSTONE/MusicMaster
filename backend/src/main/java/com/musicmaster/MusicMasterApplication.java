package com.musicmaster;

import org.mybatis.spring.annotation.MapperScan;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

/**
 * MusicMaster 应用程序主类
 * @author MusicMaster Team
 */
@SpringBootApplication
@MapperScan("com.musicmaster.mapper")
public class MusicMasterApplication {

    public static void main(String[] args) {
        SpringApplication.run(MusicMasterApplication.class, args);
        System.out.println("========================================");
        System.out.println("MusicMaster 音乐管理系统启动成功！");
        System.out.println("访问地址：http://localhost:8080/api");
        System.out.println("========================================");
    }
}