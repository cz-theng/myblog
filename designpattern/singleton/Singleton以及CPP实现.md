#什么是Singleton
设计模式最早是在建筑行业被提出来的，在软件行业也被广泛应用，甚至在大学课堂里面已经延伸出一门课程“设计模式”，关于设计模式（软件范畴内）的著作有大把，有国人的总结，也由国外大咖的探讨。其中以GoF的《Design Patterns: Elements of Reusable Object-Oriented Software》最为著名（GoF：Gang of Four,指本书的四位作者叫“四人组”）。书中探讨了23中设计模式，并将他们归类为3中：创建型（Creational）、结构型（Structural）以及行为型（Behavioral）。而Singleton就是创建型中的一种模式。

在数学与逻辑学中，singleton定义为“有且仅有一个元素的集合”。计算机中的单例模式最初的定义出现于《设计模式》（艾迪生维斯理, 1994）：“保证一个类仅有一个实例，并提供一个访问它的全局访问点。”。从定义中可以看出，单例主要聚焦于两点

* 有且只有一个实例
* 有一个全局的访问点

实现了这样两个特性也就实现了一个单例模型。


## 一、使用场景
如果我们用C++实现了一个Log对象，该对象有个Debug方法。当调用改方法 `log.Debug("My log")` 就可以记录下log。那么这样的接口如何在我整个工程里面都可以使用呢？一种方法是在所有需要用到log的地方将该对象传递过去，但是这样做在接口设计上会非常的不友好。 另一种方法是将该对象做成一个全局变量，在需要的地方声明该对象，并调用其接口，该方法也可以，但是在多线程环境，访问权控制方面需要特殊处理并且全局变量总不那么的高大上。

对于这样的一个场景，在需求上既符合“有且只有一个”也符合“一个全局访问点”的要求，我们即可将其做成单例。

与此类似的还有配置文件、数据落地proxy(dbproxy)、message center等

## 二、两种实现思想
对于单例的实现，不同语言可能会有不同。对于常见的Java和CPP人们总结了两大类的实现。分别命名为“懒汉方法”和“饿汉方法”，其实就是说什么时候创建单例对象，是在第一次使用时还是在程序开始时。	

先来看程序一执行就初始话的实现：

	class ALog
	{
	public:
	    void Debug(char *fmt,...) { va_list args; va_start(args, fmt); printf(fmt, args); va_end(args);}
	    
	public:
	    static ALog *Instance()
	    {
	        return &_instance;
	    }
	private:
	    ALog(){};
	private:
	    static ALog _instance;
	};
    
    ALog ALog::_instance; // Don't forget this in your cpp 

该实现的使用为 `ALog::Instance()->Debug("my log ");` 。通过这个“全局访问点”进行访问，只要包含头文件即可。
注意，这里需要在cpp文件中对静态成员进行定义,并且隐藏了构造函数，从而使得该对象的创建只能有一个入口，从而达到“有且仅有一个”的目的。

在来看第二种，在使用的时候才去初始化：

	class BLog
	{
	public:
	    void Debug(char *fmt,...) { va_list args; va_start(args, fmt); printf(fmt, args); va_end(args);}
	public:
	    static BLog *Instance()
	    {
	        if (nullptr == _instance) {
	            _instance = new BLog();
	        }
	        return _instance;
	    }
	private:
    	BLog(){}
	private:
	    static BLog *_instance;
	    
	};

	BLog *BLog::_instance = nullptr; // Don't forget this in your cpp 
	
这种方式使用和上面一致。只是只有当第一次使用时，才会对BLog::_instance真正的分配内存。在Cocos中就是使用的这种方法的一个变种。比如Director对象:

	// singleton stuff
	static DisplayLinkDirector *s_SharedDirector = nullptr;
	
	Director* Director::getInstance()
	{
	    if (!s_SharedDirector)
	    {
	        s_SharedDirector = new (std::nothrow) DisplayLinkDirector();
	        CCASSERT(s_SharedDirector, "FATAL: Not enough memory");
	        s_SharedDirector->init();
	    }
	
	    return s_SharedDirector;
	}

这里他没有使用隐藏的成员变量，而是用的一个全局变量，这样有个风险在于，如果用户修改了s_SharedDirector怎么办。

## 三、初始化的顺序
上面的两种方式各有所爱，好像都可以行的通，直到有天看到一篇文章《[C++ In Theory: The Singleton Pattern, Part I](http://www.devarticles.com/c/a/Cplusplus/C-plus-plus-In-Theory-The-Singleton-Pattern-Part-I/)》才发现单例还有个初始化顺序的问题，以前使用上面太简单了，所以没有采坑。	

上面两种方法是都要在CPP里面定义一个静态成员变量的，所不同的是一个是对象一个是空指针。假设现在有另一个静态变量，且该变量的初始化依赖上面的单例，由于静态变量的构造顺序是没有标准的，因此可能出现前者依赖后者，但是后者却还没有构建出来，这样在前者的构造函数中对后者的访问就会导致Crash（SIGSEGV）。但是下面一种方法就不会，因此推荐下面一种方式（不要使用cocos的变种）。但是这个方法有个问题在于，其析构在什么时候？

如果其保存这fd或其他系统资源，如果程序退出时，系统没哟做相应的释放动作（fd、内存一般是释放的），就有可能产生资源泄露，一种补救的方式是增加一个DeInit的方法，在退出时释放相关资源。

## 四、考虑多线程

上面的讨论是在单线程的情况下。那如果是多线程时，很可能在第一个线程对_instance判NULL的时候，切换到第二个线程，此时它也判为NULL，这个时候两个线程都会创建出一个实例对象。这就违背了“有且只有一个对象”的初衷了。最直接的方式就是采用加锁的机制：

	class CLog
	{
	public:
	    void Debug(char *fmt,...) { va_list args; va_start(args, fmt); printf(fmt, args); va_end(args);}
	public:
	    static CLog *Instance()
	    {
	        if (nullptr == _instance) {
	            pthread_mutex_lock(&_mtx);
	            if (nullptr == _instance) {
	                _instance = new CLog();
	            }
	            pthread_mutex_unlock(&_mtx);
	        }
	        return _instance;
	    }
	private:
	    CLog(){}
	private:
	    
	    static pthread_mutex_t _mtx;
	    
	    static CLog *_instance;
	    
	};
	
	CLog *CLog::_instance = nullptr; // Don't forget these two line in your cpp
	pthread_mutex_t CLog::_mtx;


这里在创建对象的地方加锁，注意在加锁钱后都有判nullptr的过程，对于对象没有创建的时候，这里看是多余的，但是当对象创建了之后，如果每次都先加锁再判nullptr，会使得每次访问都要加锁，导致效率低下。

除了加锁还有没有更好的解决方案呢？上面的文献给了个解决方法：Meyers Singleton（出自《More Effective C++: S.Meyers》）采用局部静态变量：

	class DLog
	{
	public:
	    void Debug(char *fmt,...) { va_list args; va_start(args, fmt); printf(fmt, args); va_end(args);}
	public:
	    static DLog &Instance()
	    {
	        static DLog _instance;
	        return _instance;
	    }
	    
	private:
	    DLog & operator= (const DLog &);
	    DLog(){};
	    
	};

这里相交于之前，少了静态变量的定义，并且使用的是局部静态变量的引用，对于使用者而言更好管理内存对象。并且，由于静态变量的构造是由编译器维护其原子性的，所以也不用加锁即可在多线程中使用。

另外为了防止单例在赋值时导致调用编译器合成的默认拷贝构造函数，这里隐藏构造函数的同时还隐藏了拷贝构造函数。当然，这里也可以选择返回指针，只是使用者不能对其进行释放。

## 五、终极模板
那么问题来了。这么多实现，到底选择哪个呢？看了上面文字的描述，就知道肯定选择D方案了。

## 六、注意事项
* 两个单例之间不能互相依赖，否则容易导致类似死锁必然有一个没有创建出来，从而导致crash。
* 多个单例之间互相引用时，需要处理好析构函数，后者的析构函数不能调用已经析构对象的析构函数。

