#NATS之gnatcd初体验
现在Message Queue有多种选择，比如Java的Kafaka/ActiveMQ、Erlang的RabbitMQ、Golang的NSQ以及这里要说的gnatcd。
##1. NATS与gnatcd
> NATS is Open Source. Performant. Simple. Scalable.A central nervous system for modern, reliable and scalable cloud and distributed systems.
 												--http://nats.io/
 												
按照其官网的说法，NATS是一个开源的、高性能的、简洁的、灵活的 适用于现代的可靠灵活的云和分布式系统的中枢系统。 说的很玄乎，实际上就是一个分布式
的消息队列系统，支持PubSub/ReqRsp 模型。其最初由Apcera领导开发，并实现了Ruby版本的服务器和客户端，其主要作者[Derek Collison](https://github.com/derekcollison)自称做了20多年的MQ，并经历过TIBOC、Rendezvous、EMC公司，这里有[他自己的reddit回答](https://www.reddit.com/r/golang/comments/1oqqx7/gnatsd_from_apcera_a_high_performance_nats_server/)。

根据[github](https://github.com/nats-io)里面[ruby-nats](https://github.com/nats-io/ruby-nats)的日志显示在11年Derek实现了Ruby版本
的NATS服务器以及对应的客户端。然后在12年末，Derek又用Golang将服务器重写了一遍，并最终发现其效果更好，于是现在慢慢将Ruby版本的服务器淘汰了，现在
官网也只维护一个Golang版本的服务器，也就是我们这里的gnatcd。

> NATS provides a lightweight server that is written in the Go programming language. Apcera actively maintains and supports the NATS server source code, binary distributions, and Docker image.
											-- http://nats.io/documentation/
											
gnatcd根据NATS说法，会由Apcera维护，并提供源码、二进制文件以及Docker镜像文件。

##2. NATS组成以及支持的内容
NATS主要由Golang写的服务器“gnatsd”和一系列的客户端SDK组成，客户端有官方维护`Golang`、`Node.js`、`Ruby`、`Java`、`C`、`C#`以及`Nginx C`版本，除此之外还有社区贡献的`Spring`、`Lua`、`PHP`、`Python`、`Scala`、`Haskell`版本，基本覆盖了主流语言。

客户端和服务器之间通过一套本文协议进行通讯（想想Redis也是文本协议），因此可以和Redis一样可以通过Telnet进行调试，也因此只要按照文档中的描述，来
实现一套客户端（想想Redis那么多的客户端）。

具体的协议罗列在官方[手册](http://nats.io/documentation/internals/nats-protocol/)中,主要分成：

操作命令| 由谁发送 | 描述
---|---|---
INFO|Server|当TCP握手完成后，由服务器发给客户端
CONNECT|Client|	由客户端发送给服务器，带上连接的必要信息
PUB|Client|客户端发送一个发布消息给服务器
SUB|Client|客户端向服务器订阅一条消息
UNSUB|Client|客户端向服务器取消之前的订阅
MSG|Server|服务器发送订阅的内容给客户端
PING|Both|PING keep-alive 消息
PONG|Both|PONG keep-alive 响应
+OK|Server|在verbose模式下，确认正确的协议格式
-ERR|Server|表示协议错误，将端口连接

NATS实现了三种模式

* Publish Subscribe
* Request Reply
* Queueing

也就是MessageQueue常见的“发布订阅模式”、“请求响应模式”以及“消息队列模式”。

##3. gnatcd安装与使用
了解了NATS后，我们来看怎么进行简单的使用。gnatcd是用Golang写的，因此可以很方便的用`go get github.com/nats-io/gnatsd`进行安装。如果没有Golang环境，也可以在[下载界面](http://nats.io/download/)下载MacOS/Linux二进制文件，甚至Docker镜像。客户端SDK也可以在这里找到下载。

在用"go get”安装的时候，需要注意的是，gnatcd依赖“golang.org/x/crypto/bcrypt”，但是这个地址已经被移动到Github上了，所以上面的地址"get"不
到源码，所以需要在你的$GOPATH/golang.org/x目录下git拖一下crypto的新代码:https://github.com/golang/crypto.git

	mkdir -p $GOPATH/golang.org/x
	cd $GOPATH/golang.org/x
	git clone https://github.com/golang/crypto.git
	
然后到get到的gnastd目录下，执行build或者install进行编译：

	cd $GOPATH/github.com/nats-io/gnatsd 
	go build 
	go install
然后根据build/install的方始，执行gnatsd命令，会看到
	
	$./gnatsd
	[20783] 2016/04/23 23:14:22.850373 [INF] Starting nats-server version 0.8.0.beta
	[20783] 2016/04/23 23:14:22.850469 [INF] Listening for client connections on 0.0.0.0:4222
	[20783] 2016/04/23 23:14:22.850585 [INF] Server is ready

这样服务器就正常运行了。

下面在开两个终端，我们用Golang的客户端nats（https://github.com/nats-io/nats.git）来做个pub-sub的例子。首先`go get github.com/nats-io/nats` 进行安装。

然后分别建立两个目录：
	
	mkdir pub sub 
	
接着分别将https://github.com/nats-io/examples/nats-pub.go复制到pub目录，https://github.com/nats-io/examples/nats-sub.go复制到sub目录。然后修改这两个文件，将最开始的：

	// +build ignore
	
删除后，分别在两个目录下执行 

	go build
	
现在客户端就建立好了，这个时候先在sub目录下订阅一条消息：

	./sub  -s nats://localhost:4222 -t abc
	Listening on [abc]
	
然后再在pub下面进行发布：

	$./pub  -s nats://localhost:4222 abc msg_abc
	Published [abc] : 'msg_abc'
	
此时，回望sub那边：

	2016/04/24 14:27:53 [#1] Received on [abc]: 'msg_abc'

这样也就完成了一次消息的发布和订阅了。	

##4. bechmark

NATS作为一个既老（2012年就有Ruby版本）又新（2013年的Golang版本）的MessageQueue，和其他同类产品（Kafaka/ActiveMQ/NSQ/RabbitMQ）又有什么优势呢？来看两个benchmar，第一个是官方的[benchmark](http://nats.io/documentation/tutorials/nats-benchmarking/)

另一个是[bravenewgeek](http://bravenewgeek.com/tag/gnatsd/)做的一个Golang MQ对比,结果如下：

![bravenewgeek](http://images.libcz.com:8000/images/blog/golang/nats/images/bravenewgeek_benchmark.png)

另外他还做了一个和其他产品之间的[对比](http://bravenewgeek.com/dissecting-message-queues/),结果如下：

![bravenewgeek2](http://images.libcz.com:8000/images/blog/golang/nats/images/bravenewgeek_benchmark2.png)

总的来说gnats的性能还是毋庸置疑的，主要可能还是要看他的使用场景。