# Libtask初体验

##一、协程是什么
协程是什么呢？

 >协程也是一种程序组件。相对子例程而言，协程更为一般和灵活，但在实践中使用没有子例程那样广泛。协程源自Simula和Modula-2语言，但也有其他语言支持。协程更适合于用来实现彼此熟悉的程序组件，如合作式多任务，迭代器，无限列表和管道。协程可以通过yield来调用其它协程。通过yield方式转移执行权的协程之间不是调用者与被调用者的关系，而是彼此对称、平等的。

>协程的起始处是第一个入口点，在协程里，返回点之后是接下来的入口点。子例程的生命期遵循后进先出（最后一个被调用的子例程最先返回）；相反，协程的生命期完全由他们的使用的需要决定。

>这里是一个简单的例子证明协程的实用性。假设你有一个生产者－消费者的关系，这里一个协程生产产品并将它们加入队列，另一个协程从队列中取出产品并使用它。因为相对于子例程，协程可以有多个入口和出口点，可以用协程来实现任何的子例程。事实上，正如Knuth所说：“子例程是协程的特例。”

>每当子例程被调用时，执行从被调用子例程的起始处开始；然而，接下来的每次协程被调用时，从协程返回（或yield）的位置接着执行。

> ---引自Wikipedia

概括起来，协程就是一段执行的单独子逻辑（也有人叫轻量级的线程），通过调用yield原语将自己挂起，从而实现调度任务，当再次被调度时从yield语句后面开始执行。

协程有什么好处呢？可以参考[知乎：协程的好处是什么](http://www.zhihu.com/question/20511233)上面从语言的层面（Lua/Python/etc.）进行了探讨。

##二、Libask是什么
Libtask是由[Russ Cox](rsc@swtch.com)开源的一个用C+汇编实现的协程库，它除了实现协程的基本功能（创建任务，调度任务）外还实现了一套协程之间通讯的Channel机制，和现在的Golang里面的Channel是非常相似的，都是源自于[Plan9]( http://swtch.com/usr/local/plan9/man/man3/thread.html)。另外Russ还是Golang的主要实现者之一,可见Libtask和Golang的[goroutine](https://golang.org/doc/effective_go.html#goroutines)有着千丝万缕的关系。以及基于该协程的异步poll IO操作和网络IO。通过使用协程的思路来写网络IO应用，可以避免使用异步IO遇到的各种回调的逻辑混乱的情况。关于协程的好处，有人认为网络服务的发展是这样的

“单进程”-》“多进程”（apache）-》“单进程多线程”（线程池）-》“单线程非阻塞异步IO”(libevnet/redis/nginx)-》“协程”（Golang、Scala）

正确与否暂且不讨论。至少可以看出协程是现代服务器编程的另一种思维方式。 

##三、用协程实现两个任务的交替执行
上面了解了什么是协程，以及一个提供C接口的协程库Libask。下面我们来看用该协程库实现最简单的两个任务的执行（这里以Linux为示例平台）。

首先下载[Libtask库代码](https://code.google.com/p/libtask/),然后进行解压。在代码目录下执行make命令，通过Makefile编译出几个例子和libtask的库文件（libtask.a）

libtask的API接口文件为“task.h”。因此只要取得这个头文件和上面的.a文件放在使用处在编译的时候进行引用和链接即可。

下面来看代码：

    #include <stdio.h>
    #include "task.h"
    
    
    void task_fun1 (void *data)
    {
            int i = 0;
            while (i<100) {
                    printf("task_fun1 run %d times \n",i++);
                    taskyield();
            }
    }
    
    void task_fun2 (void *data)
    {
            int i = 0;
            while (i<100) {
                    printf("task_fun2 run %d times \n",i++);
                    taskyield();
            }
    }
    
    //int main()
    void taskmain(int argc,char *argv[])
    {
            taskcreate(task_fun1,NULL,1024);
            taskcreate(task_fun2,NULL,1024);
    }
    
然后进行编译：

    gcc -o your_file.c your_exe libtask.a
    
这里不要奇怪为啥一个可执行的文件中没有`main`函数。因为在libtask中已经接管了main。其实main本身在系统中也是被其他函数慢慢调用起来的入"_main"。这里在libtask.a中的真正的C的main函数里面会调用这里实现的`void taskmain(int argc,char *argv[])`。因此将其当做main即可。

这里任务的创建使用接口：

    int     taskcreate(void (*f)(void *arg), void *arg, unsigned int stacksize);
    
创建一个执行handler为f，栈空间大小为stacksize的协程任务。

这里协程任务的执行逻辑为一个接受一个`void *`没有返回值的函数，其参数通过arg指定。

这里我们的两个任务进行交替执行，每个任务打印了自己 信息后就进行yield然后等待下一次的调度执行。

当编译后运行可以看到类似下面的输出。表示两个任务交替执行。

    task_fun1 run 0 times 
    task_fun2 run 0 times 
    task_fun1 run 1 times 
    ...
    task_fun1 run 98 times 
    task_fun2 run 98 times 
    task_fun1 run 99 times 
    task_fun2 run 99 times 
    
这里可以看到Libtask实现了我们上面对一个协程的简单定义。