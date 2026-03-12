package com.musicmaster.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

/**
 * Web配置类 - 配置静态资源映射
 */
@Configuration
public class WebConfig implements WebMvcConfigurer {

    @Value("${file.upload.music-path:./uploads/music/}")
    private String musicPath;

    @Value("${file.upload.image-path:./uploads/image/}")
    private String imagePath;

    @Override
    public void addResourceHandlers(ResourceHandlerRegistry registry) {
        // 映射音乐文件目录
        registry.addResourceHandler("/uploads/music/**")
                .addResourceLocations("file:" + musicPath);

        // 映射图片文件目录
        registry.addResourceHandler("/uploads/image/**")
                .addResourceLocations("file:" + imagePath);

        // 映射整个uploads目录（备用）
        registry.addResourceHandler("/uploads/**")
                .addResourceLocations("file:./uploads/");
    }
}
