package com.musicmaster.dto;

import lombok.Data;

/**
 * 统一响应结果类
 */
@Data
public class ResponseDTO {

    /**
     * 状态码
     */
    private Integer code;

    /**
     * 消息
     */
    private String message;

    /**
     * 数据
     */
    private Object data;

    /**
     * 成功响应
     */
    public static ResponseDTO success() {
        ResponseDTO response = new ResponseDTO();
        response.setCode(200);
        response.setMessage("操作成功");
        return response;
    }

    /**
     * 成功响应（带数据）
     */
    public static ResponseDTO success(Object data) {
        ResponseDTO response = new ResponseDTO();
        response.setCode(200);
        response.setMessage("操作成功");
        response.setData(data);
        return response;
    }

    /**
     * 成功响应（自定义消息）
     */
    public static ResponseDTO success(String message, Object data) {
        ResponseDTO response = new ResponseDTO();
        response.setCode(200);
        response.setMessage(message);
        response.setData(data);
        return response;
    }

    /**
     * 失败响应
     */
    public static ResponseDTO error(String message) {
        ResponseDTO response = new ResponseDTO();
        response.setCode(500);
        response.setMessage(message);
        return response;
    }

    /**
     * 失败响应（自定义状态码）
     */
    public static ResponseDTO error(Integer code, String message) {
        ResponseDTO response = new ResponseDTO();
        response.setCode(code);
        response.setMessage(message);
        return response;
    }

    /**
     * 参数错误响应
     */
    public static ResponseDTO paramError(String message) {
        ResponseDTO response = new ResponseDTO();
        response.setCode(400);
        response.setMessage(message);
        return response;
    }

    /**
     * 未授权响应
     */
    public static ResponseDTO unauthorized() {
        ResponseDTO response = new ResponseDTO();
        response.setCode(401);
        response.setMessage("未授权，请重新登录");
        return response;
    }

    /**
     * 禁止访问响应
     */
    public static ResponseDTO forbidden() {
        ResponseDTO response = new ResponseDTO();
        response.setCode(403);
        response.setMessage("禁止访问");
        return response;
    }
}