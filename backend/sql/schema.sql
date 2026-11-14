-- ============================================================
-- TodoList 数据库结构 v1
-- MySQL 8.0 / InnoDB / utf8mb4
--
-- 执行方式：
--   mysql -u root -p < backend/sql/schema.sql
--
-- 设计约定（全表统一）：
--   1. 主键统一 id BIGINT UNSIGNED AUTO_INCREMENT
--   2. 所有"用户产生的数据"都带 user_id，数据隔离在 SQL 层就带上条件
--   3. 时间统一 DATETIME，不用 TIMESTAMP（范围只到 2038）
--   4. 不用外键约束，关联关系由应用层保证（见文件末尾说明）
--   5. 金额/数量类不用 BIGINT 以外的类型；布尔值统一 TINYINT(1)
-- ============================================================

CREATE DATABASE IF NOT EXISTS `todolist_dev`
    DEFAULT CHARACTER SET utf8mb4
    COLLATE utf8mb4_general_ci;

USE `todolist_dev`;

-- 表已存在则先删（开发期可反复重建；生产环境不要这样）
DROP TABLE IF EXISTS `operation_log`;
DROP TABLE IF EXISTS `attachment`;
DROP TABLE IF EXISTS `todo_tag`;
DROP TABLE IF EXISTS `tag`;
DROP TABLE IF EXISTS `todo`;
DROP TABLE IF EXISTS `category`;
DROP TABLE IF EXISTS `user_setting`;
DROP TABLE IF EXISTS `user`;


-- ------------------------------------------------------------
-- 1. user 用户
-- ------------------------------------------------------------
CREATE TABLE `user` (
    `id`         BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `username`   VARCHAR(50)     NOT NULL                COMMENT '登录名，全局唯一',
    `password`   VARCHAR(100)    NOT NULL                COMMENT 'BCrypt 密文，固定 60 位，留余量',
    `nickname`   VARCHAR(50)              DEFAULT NULL   COMMENT '昵称，为空时前端显示 username',
    `avatar_url` VARCHAR(255)             DEFAULT NULL   COMMENT '头像访问地址',
    `created_at` DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_username` (`username`)
) ENGINE = InnoDB COMMENT ='用户';


-- ------------------------------------------------------------
-- 2. user_setting 用户设置（与 user 一对一）
--    单独建表的理由：user 表只放"身份"，偏好类是"可变配置"，混在一起
--    每次查用户都要多带几列无用的配置。
-- ------------------------------------------------------------
CREATE TABLE `user_setting` (
    `user_id`              BIGINT UNSIGNED NOT NULL       COMMENT '用户 id，同时作主键实现一对一',
    `remind_enabled`       TINYINT(1)      NOT NULL DEFAULT 1  COMMENT '是否开启到期提醒',
    `remind_ahead_minutes` INT             NOT NULL DEFAULT 0  COMMENT '提前多少分钟提醒，0=准点',
    `week_start`           TINYINT         NOT NULL DEFAULT 1  COMMENT '周起始日 1=周一 7=周日',
    `created_at`           DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at`           DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`user_id`)
) ENGINE = InnoDB COMMENT ='用户设置';


-- ------------------------------------------------------------
-- 3. category 分类（一对多：一个用户多个分类，一个任务一个分类）
--    注意 UNIQUE (user_id, name)：只保证"同一用户内不重名"，
--    不同人可以都有"工作"这个分类。
-- ------------------------------------------------------------
CREATE TABLE `category` (
    `id`         BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `user_id`    BIGINT UNSIGNED NOT NULL              COMMENT '归属用户',
    `name`       VARCHAR(30)     NOT NULL              COMMENT '分类名',
    `color`      VARCHAR(7)      NOT NULL DEFAULT '#409EFF' COMMENT '颜色 #RRGGBB',
    `sort_order` INT             NOT NULL DEFAULT 0    COMMENT '排序，越小越靠前',
    `created_at` DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_user_name` (`user_id`, `name`)
) ENGINE = InnoDB COMMENT ='分类';


-- ------------------------------------------------------------
-- 4. tag 标签（多对多，靠 todo_tag 中间表）
-- ------------------------------------------------------------
CREATE TABLE `tag` (
    `id`         BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `user_id`    BIGINT UNSIGNED NOT NULL              COMMENT '归属用户',
    `name`       VARCHAR(20)     NOT NULL              COMMENT '标签名',
    `color`      VARCHAR(7)      NOT NULL DEFAULT '#909399' COMMENT '颜色 #RRGGBB',
    `created_at` DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_user_name` (`user_id`, `name`)
) ENGINE = InnoDB COMMENT ='标签';


-- ------------------------------------------------------------
-- 5. todo 任务（全库最核心的表）
--    一张表同时承载：普通任务、子任务、重复规则模板、重复任务实例、回收站
--    —— 靠几个标记字段区分，不拆表。拆表会让"列表查询"变成多表 UNION。
-- ------------------------------------------------------------
CREATE TABLE `todo` (
    `id`          BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `user_id`     BIGINT UNSIGNED NOT NULL                  COMMENT '归属用户，数据隔离靠它',
    `category_id` BIGINT UNSIGNED          DEFAULT NULL     COMMENT '分类，可为空（未归类）',
    `parent_id`   BIGINT UNSIGNED          DEFAULT NULL     COMMENT '父任务 id，子任务只做一层',

    `title`       VARCHAR(200)    NOT NULL                  COMMENT '标题',
    `description` VARCHAR(1000)            DEFAULT NULL     COMMENT '描述',
    `priority`    TINYINT         NOT NULL DEFAULT 2        COMMENT '优先级 1高 2中 3低，升序排前排',
    `due_time`    DATETIME                 DEFAULT NULL     COMMENT '截止时间，精确到分',

    `completed`    TINYINT(1)     NOT NULL DEFAULT 0        COMMENT '是否完成',
    `completed_at` DATETIME                DEFAULT NULL     COMMENT '完成时间。没它会做不了"7 日趋势"统计',

    -- 重复规则：模板行 is_template=1；每天由 @Scheduled 生成实例行
    `is_template`     TINYINT(1)     NOT NULL DEFAULT 0    COMMENT '1=重复规则模板（不显示在列表）',
    `template_id`     BIGINT UNSIGNED         DEFAULT NULL COMMENT '实例来自哪个模板',
    `recurrence_type` VARCHAR(10)             DEFAULT NULL COMMENT 'DAILY/WEEKLY/MONTHLY，仅模板用',
    `recurrence_day`  VARCHAR(20)             DEFAULT NULL COMMENT 'WEEKLY 存 1-7；MONTHLY 存 1-31',
    `last_generated`  DATE                    DEFAULT NULL COMMENT '模板已生成到哪一天，防重复生成',

    `deleted_at`  DATETIME                 DEFAULT NULL     COMMENT '回收站：非空即已删，NULL 表示正常',

    `created_at`  DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at`  DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    PRIMARY KEY (`id`),
    KEY `idx_user_list` (`user_id`, `completed`, `deleted_at`)   COMMENT '列表主查询',
    KEY `idx_user_due`  (`user_id`, `due_time`)                  COMMENT '排序/过期判断',
    KEY `idx_template`  (`template_id`),
    KEY `idx_parent`    (`parent_id`),
    -- 兜底防重：同一模板同一天只能有一条实例。
    -- MySQL 唯一索引里 NULL 不参与比较，所以普通任务（template_id 为 NULL）不受影响。
    UNIQUE KEY `uk_template_due` (`template_id`, `due_time`)
) ENGINE = InnoDB COMMENT ='任务';


-- ------------------------------------------------------------
-- 6. todo_tag 任务-标签中间表
--    联合主键 (todo_id, tag_id) 天然防重：同一个标签贴两次插不进去。
--    这比"加个 id 主键再建唯一索引"省一列、省一个索引。
-- ------------------------------------------------------------
CREATE TABLE `todo_tag` (
    `todo_id` BIGINT UNSIGNED NOT NULL,
    `tag_id`  BIGINT UNSIGNED NOT NULL,
    PRIMARY KEY (`todo_id`, `tag_id`),
    KEY `idx_tag` (`tag_id`) COMMENT '反向查"这个标签下有哪些任务"'
) ENGINE = InnoDB COMMENT ='任务-标签关联';


-- ------------------------------------------------------------
-- 7. operation_log 操作日志（AOP 切面写入）
--    注意 params 用 TEXT 而不是 VARCHAR：JSON 很容易超 2000 字符。
-- ------------------------------------------------------------
CREATE TABLE `operation_log` (
    `id`             BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `user_id`        BIGINT UNSIGNED          DEFAULT NULL COMMENT '谁操作的，未登录为空',
    `module`         VARCHAR(30)     NOT NULL              COMMENT '业务模块 todo/category/tag/user',
    `operation`      VARCHAR(30)     NOT NULL              COMMENT '动作 新增/修改/删除/登录',
    `method`         VARCHAR(150)             DEFAULT NULL COMMENT 'Java 方法签名',
    `request_uri`    VARCHAR(200)             DEFAULT NULL COMMENT '请求路径',
    `request_method` VARCHAR(10)              DEFAULT NULL COMMENT 'GET/POST/PUT/DELETE',
    `params`         TEXT                     DEFAULT NULL COMMENT '入参 JSON（敏感字段已脱敏）',
    `cost_ms`        INT                      DEFAULT NULL COMMENT '耗时毫秒',
    `ip`             VARCHAR(50)              DEFAULT NULL,
    `success`        TINYINT(1)      NOT NULL DEFAULT 1    COMMENT '成功/失败',
    `error_msg`      VARCHAR(500)             DEFAULT NULL COMMENT '失败原因',
    `created_at`     DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `idx_user_time` (`user_id`, `created_at`)
) ENGINE = InnoDB COMMENT ='操作日志';


-- ------------------------------------------------------------
-- 8. attachment 附件（文件上传到本地磁盘）
--    磁盘只存文件，数据库存"元数据"。
--    stored_name 用 UUID，避免两个人都传 1.jpg 互相覆盖。
-- ------------------------------------------------------------
CREATE TABLE `attachment` (
    `id`            BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `user_id`       BIGINT UNSIGNED NOT NULL              COMMENT '上传者',
    `original_name` VARCHAR(255)    NOT NULL              COMMENT '原始文件名，展示用',
    `stored_name`   VARCHAR(255)    NOT NULL              COMMENT '磁盘文件名（UUID）',
    `path`          VARCHAR(500)    NOT NULL              COMMENT '相对存储路径',
    `size_bytes`    BIGINT          NOT NULL DEFAULT 0    COMMENT '文件大小',
    `content_type`  VARCHAR(100)             DEFAULT NULL COMMENT 'MIME 类型',
    `created_at`    DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `idx_user` (`user_id`)
) ENGINE = InnoDB COMMENT ='附件';


-- ============================================================
-- 为什么不用外键（FOREIGN KEY）
--   1. 阿里开发规范明确禁止：外键影响插入性能，且级联行为不可控
--   2. 高并发下外键检查会让写入串行化
--   3. 以后要分库分表，外键跨库根本不可能
--   关联一致性由 Service 层保证（删除分类前先把它下面的任务 category_id 置空）
--
-- 为什么时间用 DATETIME 不用 TIMESTAMP
--   TIMESTAMP 只能存到 2038-01-19，且会随服务器时区自动转换，排查问题很痛苦
-- ============================================================
