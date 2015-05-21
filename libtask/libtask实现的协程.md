# Libtask实现的协程


在前一篇文章[libtask初体验]()里面交替的执行了两个任务。这里我们通过分析这两个任务的调度过程，来看Libtask是如何实现协程的。

首先创建两个任务：

    void taskmain(int argc,char *argv[])
    {
            taskcreate(task_fun1,NULL,1024);
            taskcreate(task_fun2,NULL,1024);
    }
    
