#golang操作Redis（redigo基础篇）
现在的redis大红大紫，而且很多应用场景都适合使用Reids来做缓存或者直接做存储，典型的如mysql前端缓存、手游里面的排行榜等。那么我们怎样用golang来操作redis呢？

熟悉redis的同学，肯定第一反应就是按照redis的协议，实现一个客户端与redis服务进行通信即可。不熟悉redis的同学，可能会说用cgo封装下官方的c客户端，妥妥的。是的，这两种方法都可以。既然redis这么火，那么这些工作有没有人做呢？答案是肯定的。在redis的官方网站的客户端列表里就有众多golang的客户端。这个时候，可能你又要犯难了，我该用哪一个呢？

熟悉reids的同学都知道，官网加星星的客户端都是好客户端，就像棒子天上的星星一样神奇。可是坑爹的时，golang不同于python有两个都是加星星的，这孰真孰假呢？

具体我也了解，不过大概浏览了下源码，二者都是用golang实现了redis得协议，不过radix的源码感觉不是那么清晰，相对来说redigo的源码可以和命令对上，比较清晰，且redigo说其支持所有的redis命令。然后又网上搜了几篇[文章1](http://1.guotie.sinaapp.com/?p=549)/[文章2](http://www.cnblogs.com/getong/archive/2013/04/01/2993139.html)，最终还是选择了redigo来尝试。

##1建立连接

	conn , err := redis.DialTimeout("tcp", ":6379", 0, 1*time.Second, 1*time.Second)
	
参数的意义分别是网络类型“tcp”、地址和端口、连接超时、读超时和写超时时间。有了连接后。我们就可以进行其他操作了。先看下db的大小

	size ,err := conn.Do("DBSIZE")
	fmt.Printf("size is %d \n",size)
	
	//输出：
	size is 8
	
在使用完后，通过调用 `conn.Close()` 关闭连接。
	
##2基本命令执行
对于最基本的命令使用，我们统一调用：

	Do(commandName string, args ...interface{}) (reply interface{}, err error)
	
这个接口，整个过程就和我们使用redis命令一样。

我们知道在redis的协议中，都是按照字符流的，那么Do函数是如何进行序列化的呢？下面是其转换规则:

	Go Type                 Conversion
	
	[]byte                  Sent as is
	string                  Sent as is
	int, int64              strconv.FormatInt(v)
	float64                 strconv.FormatFloat(v, 'g', -1, 64)
	bool                    true -> "1", false -> "0"
	nil                     ""
	all other types         fmt.Print(v)

其实就是byte数组和字符串不变，整形和浮点数转换成对应的字符串，bool用1或者0表示，nil为空字符串。


下面再看下执行后得到的结果返回值的类型：

	Redis type              Go type
	
	error                   redis.Error
	integer                 int64
	simple string           string
	bulk string             []byte or nil if value not present.
	array                   []interface{} or nil if value not present.

如上表，redis中得类型会对应的转换成左边go中得类型，无需多解释。我们来看几个例子：

	conn , err := redis.DialTimeout("tcp", ":6379", 0, 1*time.Second, 1*time.Second)
	if err != nil {
		panic(err)
	}
	size ,err:= conn.Do("DBSIZE")
	fmt.Printf("size is %d \n",size)

	_,err = conn.Do("SET","user:user0",123)
	_,err = conn.Do("SET","user:user1",456)
	_,err = conn.Do("APPEND","user:user0",87)

	user0,err := redis.Int(conn.Do("GET","user:user0"))
	user1,err := redis.Int(conn.Do("GET","user:user1"))

	fmt.Printf("user0 is %d , user1 is %d \n",user0,user1)

	conn.Close()
	
从redis传回来得普通对象（整形、字符串、浮点数）。redis提供了类型转换函数供转换：

	func Bool(reply interface{}, err error) (bool, error)
	func Bytes(reply interface{}, err error) ([]byte, error)
	func Float64(reply interface{}, err error) (float64, error)
	func Int(reply interface{}, err error) (int, error)
	func Int64(reply interface{}, err error) (int64, error)
	func String(reply interface{}, err error) (string, error)
	func Strings(reply interface{}, err error) ([]string, error)
	func Uint64(reply interface{}, err error) (uint64, error)
	
这里只是举了set和get命令。其他的例子可以参见redigo的[conn_test.go](https://github.com/garyburd/redigo/blob/master/redis/conn_test.go)