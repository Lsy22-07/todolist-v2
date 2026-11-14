package com.example.todolist.controller;

import com.example.todolist.common.Result;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.LinkedHashMap;
import java.util.Map;

/**
 * 健康检查接口 —— 骨架阶段的唯一接口，用来证明「框架是通的」。
 *
 * 为什么一个正经项目也要有它：
 *   部署后要能一眼看出「进程活着且能处理 HTTP 请求」，
 *   否则只能靠翻日志猜服务起没起。生产环境通常还会加上数据库、Redis 的连通性检查。
 *
 * @RestController = @Controller + @ResponseBody
 *   前者把类标记为「处理 HTTP 请求的组件」，
 *   后者把方法返回值直接序列化成 JSON 写进响应体（而不是去找视图模板）。
 *
 * @RequestMapping("/api") 是这层的公共前缀，类里每个方法的路径都拼在它后面。
 */
@RestController
@RequestMapping("/api")
public class HealthController {

    private static final DateTimeFormatter TIME_FMT = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm");

    /**
     * GET /api/health
     * 返回统一响应体，证明「路由 + JSON 序列化 + 统一响应」三件事都通了。
     */
    @GetMapping("/health")
    public Result<Map<String, Object>> health() {
        Map<String, Object> data = new LinkedHashMap<>();
        data.put("status", "UP");
        data.put("app", "todolist");
        data.put("time", LocalDateTime.now().format(TIME_FMT));
        return Result.ok(data);
    }
}
