package com.example.todolist.common;

import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.converter.HttpMessageNotReadableException;
import org.springframework.validation.BindException;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestControllerAdvice;

/**
 * 全局异常处理 —— 把「抛出去的异常」翻译成「统一响应体 + 正确的 HTTP 状态码」。
 *
 * 为什么不能不要它：
 *   不加的话，异常会走 Spring 默认的错误页，前端收到的是一坨 HTML，
 *   而且状态码永远是 500，前端无法区分「参数填错了」和「服务器炸了」。
 *   更糟的是每个 Controller 都要自己 try-catch，30 个接口就 30 份重复代码。
 *
 * 工作机制：
 *   @RestControllerAdvice 让 Spring 把所有 Controller 抛出的异常先交给这里，
 *   按 @ExceptionHandler 声明的异常类型就近匹配，命中后返回它的返回值。
 *   所以业务代码里只管 throw，不用写任何 try-catch。
 *
 * 错误码对照见 docs/07-接口文档.md 1.3
 */
@Slf4j
@RestControllerAdvice
public class GlobalExceptionHandler {

    /**
     * 参数校验失败 —— HTTP 400 / code 1001
     * 触发场景：@Valid + @NotBlank 校验不通过
     */
    @ExceptionHandler({MethodArgumentNotValidException.class, BindException.class})
    @ResponseStatus(HttpStatus.BAD_REQUEST)// 400
    public Result<Void> handleValidation(BindException e) {
        // 只取第一条错误提示给前端，避免一次弹一堆
        FieldError first = e.getBindingResult().getFieldError();
        String msg = (first == null) ? "参数校验失败" : first.getDefaultMessage();
        log.warn("参数校验失败: {}", msg);
        return Result.fail(1001, msg);
    }

    /**
     * 请求体不是合法 JSON —— HTTP 400 / code 1002
     * 触发场景：前端发了格式错误的 JSON，或日期格式对不上
     */
    @ExceptionHandler(HttpMessageNotReadableException.class)
    @ResponseStatus(HttpStatus.BAD_REQUEST)// 400
    public Result<Void> handleNotReadable(HttpMessageNotReadableException e) {
        log.warn("请求体解析失败: {}", e.getMessage());
        return Result.fail(1002, "请求体格式错误");
    }

    /**
     * 兜底 —— HTTP 500 / code 5000
     * 任何没被上面接住的异常都会落到这里。
     * 注意：日志里打完整堆栈，但响应体里绝不能带堆栈（会泄露内部结构）。
     */
    @ExceptionHandler(Exception.class)
    @ResponseStatus(HttpStatus.INTERNAL_SERVER_ERROR)// 500
    public Result<Void> handleUnknown(Exception e) {
        log.error("未捕获异常", e);
        return Result.fail(5000, "服务器内部错误");
    }
}
