# Libtask实现的协程


在前一篇文章[libtask初体验]()里面交替的执行了两个任务。这里我们通过分析这两个任务的调度过程，来看Libtask是如何实现协程的。

##一、创建起始主任务并启动任务调度
首先创建两个任务：

    void taskmain(int argc,char *argv[])
    {
            taskcreate(task_fun1,NULL,1024);
            taskcreate(task_fun2,NULL,1024);
    }
    
在libtask.a里面的task.c里面隐藏了真正的main函数。
    
    int main(int argc, char **argv)
    {
     ...
    
    	if(mainstacksize == 0)
    		mainstacksize = 256*1024; // 初始化主栈的空间大小
    	taskcreate(taskmainstart, nil, mainstacksize);
    	taskscheduler(); // 之后不应该被执行
    ...
    }
    
这里首先以初始化栈大小创建一个任务，然后开始启动所有任务。这里起始任务为：

    static void taskmainstart(void *v)
    {
    	taskname("taskmain");
    	taskmain(taskargc, taskargv);
    }
    
实际上就是为起始任务命名为“taskmain”然后可以调用“taskmain”,“taskmain”就是上面我们自己应用里面写的内容。这里我们又创建了两个任务，这样整个程序就是由libtask驱使三个任务在执行，也就是有三个协程在这里被调度。

这里先看几个全局变量的定义：

    int	taskcount;  // task 的计数器
    int	tasknswitch; // 统计的切换次数
    int	taskexitval;
    Task	*taskrunning; // 当前运行中的task
    
    Context	taskschedcontext;  // schedule时候的缓存context
    Tasklist	taskrunqueue;  // 一个task的单链表
    
    Task	**alltask;// 管理task的task池
    int		nalltask; // task长度
    
注释有助有后续的理解。
    
##二、创建任务的过程

Libtask的任务创建通过 ：
    
    int taskcreate(void (*fn)(void*), void *arg, uint stack)；
    
传递一个没有返回值的接受`void *`的参数的函数以及参数 `void *arg`，并设置好改任务（协程）的栈的大小stack。

该函数主要创建一个Task，然后将其挂载在runqueue队列上面等待调度。创建任务的过程调用函数`static Task *taskalloc(void (*fn)(void*), void *arg, uint stack)`  该实现，首先用malloc分配一个Task结构大小+stack的空间用于一个任务的内存结构。然后进行结构的初始化操作：

    t = malloc(sizeof *t+stack);  // 分配Task对象大小加上他的栈大小
    if(t == nil){
    	fprint(2, "taskalloc malloc: %r\n");
    	abort();
    }
    memset(t, 0, sizeof *t);
    t->stk = (uchar*)(t+1); // Task对象开头便宜一个字节
    t->stksize = stack;  // 栈大小
    t->id = ++taskidgen; // 一个简单的自增id生成器
    t->startfn = fn;  // handler处理逻辑
    t->startarg = arg; // handler的参数
    
然后用任务的context保存当前的上下文。设置好该context的sp、栈大小后，调用makecontext设置该context被切换时执行的逻辑。从而完成任务的创建。

	makecontext(&t->context.uc, (void(*)())taskstart, 2, y, x); // 构建context
这里任务被调度时候执行的taskstart函数为任务的启动入口。

    //print("taskstart %p\n", t);
    	t->startfn(t->startarg); // 然后调用Task的handler
    //print("taskexits %p\n", t);
    	taskexit(0); // 接着就调用task的exit
    //print("not reacehd\n");
最终调用上面设置的任务的handler，如果任务的逻辑中有taskyield，则会被再次调度，否则最终会调用任务的exit函数“taskexit”结束该任务。任务的退出仅仅是标记其状态，并进行任务的切换：

    taskexitval = val;
    taskrunning->exiting = 1; // 标记为正在退出
    taskswitch();

这里taskswitch会切回到for循环中：

    if(t->exiting){
    	if(!t->system)
    		taskcount--; // Task的计数器
    	i = t->alltaskslot;
    	alltask[i] = alltask[--nalltask]; // 把退出的位置让给最后一个task
    	alltask[i]->alltaskslot = i;
    	free(t); 
    }
对任务对象进行销毁，并对任务计数器减一。

在创建好Task对象并做了初始化之后，libtask还要管理改对象。其使用了数组存储Task的指针，从而对Task做线性管理。数组的默认大小为64，当超过时每次以64为单位递增。每个元素指向一个Task对象，同时Task对象的alltaskslot成员也指向了存储所有Task的数组。最后调用taskready修改task的状态并将其挂载在runqueue队列上等待调度。
    
    taskcount++; // task计数器加一
    if(nalltask%64 == 0){ // nalltask表示的是alltask的size
    	// 这里为什么判断对2^^6 对齐要重新分配 ，为的是每64个重新分配下内存
    	alltask = realloc(alltask, (nalltask+64)*sizeof(alltask[0]));
    }
    t->alltaskslot = nalltask; // 在alltask中的偏移
    alltask[nalltask++] = t; // alltask只是一个指针数组，从而持有并管理所有的task
    taskready(t); // 将task 挂到单链表runqueue上面
taskready中首先对Task的ready成员置位。然后调用addtask将task挂载到taskready单链表上。

##三、任务的调度过程  

任务调度时，首先开启一个循环，作为驱动：

    static void taskscheduler(void)
    {
    	for(;;){
    		// 主循环 最终通过exit来退出，因此不会执行到main的return
        	if(taskcount == 0)  // taskcount为task的数目
    			exit(taskexitval);
    	}
    }  
在每个tick中去检查任务数目，当其为0的时候调用exit退出，因此可以忽略main函数scheduler之后的内容。如果任务数不为0，就从“taskrunqueue”队列中取得一个头部的的任务，然后调用`contextswitch`进行任务的切换。

    t = taskrunqueue.head; // 从队列的头开始取得task
    deltask(&taskrunqueue, t); // 从runqueue链表上摘下该task
    t->ready = 0; // 修改其状态，为非准备状态（运行状态？）
    taskrunning = t;
    tasknswitch++; // 切换的统计次数
    contextswitch(&taskschedcontext, &t->context); // swapcontext交换上下文，此时进入到handler的执行流程

当执行中的任务调用`taskyield()`的时候，再切换回上面的for的上下文，进行下一次的调度。

与进程不一的是，协程的调度并不是由系统进行调度的，而是自己控制的主动调度。当需要调度时，协程逻辑调用yield让出执行位置。这里我们看下yield定义：
    
    int taskyield(void)
    {
    	int n;    	
    	n = tasknswitch;
    	taskready(taskrunning); // 修改当前run Task的状态
    	taskstate("yield");  // 修改当前状态
    	taskswitch(); // 切换Task    
    	// 再次被调度的时候才会回到这个位置
    	return tasknswitch - n - 1;
    }
    
当在任务的执行过程中调用taskyield()的时候，会先调用taskready将当前正在执行的任务：taskrunning置为ready状态，然后调用taskswitch进行上下文的切换：

    contextswitch(&taskrunning->context, &taskschedcontext);
    
交换当前正在执行的上下文和taskschedcontext做交换。这里“taskschedcontext”是什么呢？咨询看过上面任务创建的同学可以看到，这个就是缓存变量，是上面taskscheduler里面执行contextswitch时候，就是用这个来和新创建的任务进行交换。那么这里再做交换，实际上就是负负得正。回调了上面taskscheduler的上下文中，进入到for循环里面，让后在进行上面的从taskrunqueue列表中取任务执行的过程。

注意，这里的taskready又把这个开始从taskrunqueue队列中卸下来的Task重新追加到其尾部。因此我们得出，libtask的任务调度时线性的依次排队的方式，没有加入其它权重信息。

## 四、小结
从上面的的分析我们可以大致看出，Libtask实际上就是抽象出一个Task对象，并对其进行了管理，然后通过context的接口：getcontext、makecontext、setcontext以及swapcontext来实现上下文的切换从而完成任务的调度。
