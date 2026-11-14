package com.example.todolist.common;

import lombok.Data;

/**
 * 统一响应体 —— 所有接口对外返回的同一个外壳。
 *
 * 契约见 docs/07-接口文档.md 1.2：
 *   { "code": 200, "msg": "ok", "data": {} }
 *
 * 为什么要有它：
 *   如果每个 Controller 各返回各的（有的返回实体、有的返回 Map、有的返回字符串），
 *   前端就得为每个接口写一套解析逻辑，出错时也无从统一处理。
 *   套一个固定外壳后，前端一个响应拦截器就能处理全部接口。
 *
 * 为什么 code 要和 HTTP 状态码保持一致：
 *   前端 axios 对非 2xx 会自动进 catch，所以 401 就是真 401，
 *   拦截器里统一「清 token → 跳登录页」，不用在每个 then 里判断 code。
 */
@Data
public class Result<T> {

    /** 业务码，与 HTTP 状态码保持一致 */
    private int code;

    /** 成功固定为 "ok"，失败是给用户看的中文提示 */
    private String msg;

    /** 业务数据，无内容时为 null */
    private T data;

    private Result(int code, String msg, T data) {
        this.code = code;
        this.msg = msg;
        this.data = data;
    }

    /** 成功，带数据 */
    public static <T> Result<T> ok(T data) {
        return new Result<>(200, "ok", data);
    }

    /** 成功，无数据 */
    public static <T> Result<T> ok() {
        return new Result<>(200, "ok", null);
    }

    /** 失败，code 与 HTTP 状态码一致 */
    public static <T> Result<T> fail(int code, String msg) {
        return new Result<>(code, msg, null);
    }
}
