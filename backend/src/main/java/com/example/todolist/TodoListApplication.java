package com.example.todolist;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.jdbc.DataSourceAutoConfiguration;

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
 * 为什么带 exclude：
 *   pom 里有 mybatis-spring-boot-starter + mysql-connector-j，Boot 一看 classpath
 *   上有 JDBC 就要求配置 spring.datasource.url，没配就启动失败。
 *   当前阶段（S4）还没接数据库，所以临时关掉数据源自动配置。
 *   【接数据库时删掉 exclude 这一项，并在 application.yml 补 datasource 配置】
 */
@SpringBootApplication(exclude = DataSourceAutoConfiguration.class)
public class TodoListApplication {

    public static void main(String[] args) {
        SpringApplication.run(TodoListApplication.class, args);
    }
}
