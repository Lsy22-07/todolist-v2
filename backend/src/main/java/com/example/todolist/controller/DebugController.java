package com.example.todolist.controller;

import com.example.todolist.common.Result;
import lombok.Data;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import javax.sql.DataSource;
import javax.validation.Valid;
import javax.validation.constraints.NotBlank;
import java.sql.Connection;
import java.sql.DatabaseMetaData;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.LinkedHashMap;
import java.util.Map;

/**
 * 临时验证接口：只用来确认三条通道真的通了。
 *   1. /boom  全局异常
 *   2. /echo  参数校验
 *   3. /db    数据源（真正开一次连接，触发 Hikari 连接池初始化）
 * S5 注册接口上线后删除。
 */
@RestController
@RequestMapping("/api/_debug")
public class DebugController {

    private final DataSource dataSource;

    public DebugController(DataSource dataSource) {
        this.dataSource = dataSource;
    }

    @GetMapping("/boom")
    public Result<Void> boom() {
        throw new RuntimeException("故意炸一个");
    }

    @PostMapping("/echo")
    public Result<String> echo(@Valid @RequestBody EchoReq req) {
        return Result.ok(req.getName());
    }

    /**
     * 真正从连接池借一条连接出来，问数据库三件事。
     * 能返回，说明：配置解析 → 驱动加载 → TCP → 认证 → 选库，整条链路都通了。
     */
    @GetMapping("/db")
    public Result<Map<String, Object>> db() throws SQLException {
        try (Connection conn = dataSource.getConnection()) {
            DatabaseMetaData meta = conn.getMetaData();
            Map<String, Object> info = new LinkedHashMap<>();
            info.put("product", meta.getDatabaseProductName());
            info.put("version", meta.getDatabaseProductVersion());
            info.put("catalog", conn.getCatalog());
            try (Statement st = conn.createStatement();
                 ResultSet rs = st.executeQuery(
                         "select count(*) from information_schema.tables where table_schema = 'todolist_dev'")) {
                rs.next();
                info.put("tableCount", rs.getInt(1));
            }
            return Result.ok(info);
        }
    }

    @Data
    public static class EchoReq {

        @NotBlank(message = "name 不能为空")
        private String name;
    }
}
