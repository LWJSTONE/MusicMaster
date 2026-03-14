package com.musicmaster.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.io.ClassPathResource;
import org.springframework.core.io.Resource;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;
import org.springframework.web.servlet.resource.PathResourceResolver;

import java.io.IOException;

/**
 * Web配置类 - 配置静态资源映射
 * 支持前端Vue SPA应用和文件上传
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

        // 前端静态资源映射（支持Vue Router的history模式）
        registry.addResourceHandler("/**")
                .addResourceLocations("classpath:/static/")
                .resourceChain(true)
                .addResolver(new PathResourceResolver() {
                    @Override
                    protected Resource getResource(String resourcePath, Resource location) throws IOException {
                        Resource requestedResource = location.createRelative(resourcePath);
                        
                        // 如果请求的资源存在，直接返回
                        if (requestedResource.exists() && requestedResource.isReadable()) {
                            return requestedResource;
                        }
                        
                        // 对于API请求，返回null让控制器处理
                        if (resourcePath.startsWith("api/")) {
                            return null;
                        }
                        
                        // 对于前端路由，返回index.html（SPA支持）
                        Resource indexResource = new ClassPathResource("/static/index.html");
                        if (indexResource.exists() && indexResource.isReadable()) {
                            return indexResource;
                        }
                        
                        return null;
                    }
                });
    }
}
