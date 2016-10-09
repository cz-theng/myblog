#HTTP Tracing简易教程
*作者：Jaana Burcu Dogan  日期：2016.10.04 来源：[Golang官方Blog](https://blog.golang.org/http-tracing)*

##简介
在Go1.7中，我们引入了“HTTP tracing”功能，通过它可以收集到一个HTTP客户端在发送请求时整个过程中每个步骤的相关信息。使用这个功能需要用到GO1.7的标准库中“net/http/httptrace”包。通过它收集的信息可以用来调试潜在bug、服务器监控、制作自适应系统等。

## HTTP 事件
"httptrace"包提供了一系列的hook工具可以用来收集一个HTTP请求回环中的各种事件，包括有：

* 连接建立
* 连接复用
* DNS解析
* 发送请求
* 接受响应

## 跟踪事件
通过将一个包含了各种hook函数的`*httptrace.ClientTrace` 对象赋给一个HTTP请求的`context.Context` 就可以实现“HTTP tracing”了。不同的`http.RoundTripper `实现都会将内部的事件通过`*httptrace.ClientTrace`中注册的相关事件的hook函数进行通知。

一次跟踪的单位仅仅是一个HTTP请求的context上下文，因此用户需要在开始一个HTTP请求之前将`*httptrace.ClientTrace`赋值给相关请求的context成员。

	req, _ := http.NewRequest("GET", "http://example.com", nil)
    trace := &httptrace.ClientTrace{
        DNSDone: func(dnsInfo httptrace.DNSDoneInfo) {
            fmt.Printf("DNS Info: %+v\n", dnsInfo)
        },
        GotConn: func(connInfo httptrace.GotConnInfo) {
            fmt.Printf("Got Conn: %+v\n", connInfo)
        },
    }
    req = req.WithContext(httptrace.WithClientTrace(req.Context(), trace))
    if _, err := http.DefaultTransport.RoundTrip(req); err != nil {
        log.Fatal(err)
    }
    
在一次HTTP请求的回环中，`http.DefaultTransport`将会在相关事件触发时依次调用对应的hook函数。因此上面的例子代码在DNS解析完成后就会打印DNS的信息，接着在建立完连接后，打印对应的连接信息。

## 通过http.Client跟踪

“HTTP tracing”机制的设计宗旨就是跟踪单个`http.Transport.RoundTrip`生命周期中触发的各种事件。然而现实生活中，客户端的一次请求往往需要多个HTTP通信回环才能完成。比如：当发生URL重定向时，客户端随着被重定向将会发送多次HTTP请求，此时之前注册过的hook函数随着客户端每次被重定向而发送的请求被执行多次。用户可能并不关心中间的过程，而是只关心这一次完整的事务的结果也就是在`http.Client`的颗粒度上。下面的例子通过用` http.RoundTripper`的包装来找到最开始的真实请求，从而可以过滤掉中间结果。

	package main
	
	import (
	    "fmt"
	    "log"
	    "net/http"
	    "net/http/httptrace"
	)
	
	// transport is an http.RoundTripper that keeps track of the in-flight
	// request and implements hooks to report HTTP tracing events.
	type transport struct {
	    current *http.Request
	}
	
	// RoundTrip wraps http.DefaultTransport.RoundTrip to keep track
	// of the current request.
	func (t *transport) RoundTrip(req *http.Request) (*http.Response, error) {
	    t.current = req
	    return http.DefaultTransport.RoundTrip(req)
	}
	
	// GotConn prints whether the connection has been used previously
	// for the current request.
	func (t *transport) GotConn(info httptrace.GotConnInfo) {
	    fmt.Printf("Connection reused for %v? %v\n", t.current.URL, info.Reused)
	}
	
	func main() {
	    t := &transport{}
	
	    req, _ := http.NewRequest("GET", "https://google.com", nil)
	    trace := &httptrace.ClientTrace{
	        GotConn: t.GotConn,
	    }
	    req = req.WithContext(httptrace.WithClientTrace(req.Context(), trace))
	
	    client := &http.Client{Transport: t}
	    if _, err := client.Do(req); err != nil {
	        log.Fatal(err)
	    }
	}

上面的程序将会从" google.com" 重定向到 “ www.google.com” 并产生如下的输出：

	Connection reused for https://google.com? false
	Connection reused for https://www.google.com/? false

GO1.7的标准库中的net/http产生的传输信息跟踪支持HTTP/1和HTTP/2协议的请求。

如果你自定义了` http.RoundTripper`的实现，你可以通过检查`*httptest.ClientTrace`的请求context，并在相关事件发生时调用对应的hook函数，就可以支持httptrace了。

##总结
“HTTP tracing”的加入对于那些调试HTTP请求协议并为网络状况编写调试工具的用户来说是个福音。通过加入这个新的工具，我们希望看到更多类似"[httpstat](https://github.com/davecheney/httpstat)"的HTTP调试、性能测试以及可视化的工具从社区中逐渐诞生。