package com.example.todolist;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

/**
 * 启动类 —— 整个应用的唯一入口。
 *
 * 为什么必须有它：
 *   Spring Boot 项目没有 web.xml、没有外部 Tomcat 配置文件。
 *   main 方法里的 SpringApplication.run 负责：
 *     1) 创建 Spring 容器
 *     2) 扫描本包及子包下的 @Component / @RestController 等注解
 *     3) 发现 classpath 上有 spring-boot-starter-web，就拉起内嵌 Tomcat
 *
 * 关于数据源（S5 起）：
 *   pom 里有 mybatis-spring-boot-starter + mysql-connector-j，Boot 一看到 JDBC 相关
 *   依赖就会自动配置 DataSource，配置来源是 application-dev.yml 里的 spring.datasource.*
 *   （由 application.yml 的 spring.profiles.active: dev 激活）。
 *   S4 阶段曾用 exclude = DataSourceAutoConfiguration.class 临时关掉它；
 *   S5 接上数据库后，这一行已经删除。
 */
@SpringBootApplication
public class TodoListApplication {

    public static void main(String[] args) {
        SpringApplication.run(TodoListApplication.class, args);
    }
}
