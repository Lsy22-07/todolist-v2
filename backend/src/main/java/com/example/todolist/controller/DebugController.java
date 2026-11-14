package com.example.todolist.controller;

import com.example.todolist.common.Result;
import lombok.Data;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import javax.validation.Valid;
import javax.validation.constraints.NotBlank;

/**
 * 临时验证接口：只用来确认全局异常与参数校验两条通道真的通了。
 * S5 注册接口上线后删除。
 */
@RestController
@RequestMapping("/api/_debug")
public class DebugController {

    @GetMapping("/boom")
    public Result<Void> boom() {
        throw new RuntimeException("故意炸一个");
    }

    @PostMapping("/echo")
    public Result<String> echo(@Valid @RequestBody EchoReq req) {
        return Result.ok(req.getName());
    }

    @Data
    public static class EchoReq {

        @NotBlank(message = "name 不能为空")
        private String name;
    }
}
