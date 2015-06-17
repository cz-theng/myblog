#另一张TabBar大众脸的App
前面我们通过Navigation创建了一种可以切换界面外壳的App，其实拿起iPhone，我们发现除了这种类型还有另一种类型外壳的App.如下图：

![alarm](./alarm.png) ![appstore](./appstore.png)

我们发现这类App都是在最下面有一排Tab，每个Tab的Item表示一个分类的界面，通过点击这些Tab可以切换到对应的界面中。再回想下QQ/微信、
淘宝/天猫、微博等每天都要用的App。

发现了什么？？？这些App都是这样的一个基本外壳。是不是把这个学会了，就是做牛逼哄哄的App了？

## 一、TabBar是神马
在Developer上的文章[《View Controller Catalog for iOS》](https://developer.apple.com/library/ios/documentation/WindowsViews/Conceptual/ViewControllerCatalog/Chapters/TabBarControllers.html#//apple_ref/doc/uid/TP40011313-CH3-SW1) 中对TabBar的定义为：
>  It is composed of views that the tab bar controller manages directly and views that are managed by content view controllers you provide. Each content view controller manages a distinct view hierarchy, and the tab bar controller coordinates the navigation between the view hierarchies.

说白了就是一个管理其他用于承载实际内容的ViewController的容器ViewController,并且可以通过TabBar进行UI上的导航，也就是上面我们举例App的操作效果。

我们来看下其组成结构图：

![tabbar_struct](./tabbar_struct.png)

主要就是由下面的一个TabBar的list和承载显示内容的TabBarControllerView组成，每个TabBar还可以设置一个小的标题title和一个图标。
并且每个图标上面还可以显示一个红点（想想微信里面有新消息的时候）来表示一些提示信息。因此我们可以猜想，其实现就是用一个数组来保存每个
界面的ViewController，然后绘制一个可触发的Tab，当点击的时候切换到对应的ViewController中。 这样我们再看官方的分解图就容易理解了:

![tabbar_struct1](./tabbar_struct1.png)


## 二、通过Tab切换界面

这里我手写一个界面：

![appdelegate](./appdelegate.png)


这里创建一个 `UITabBarController`对象`rootVC`作为window的rootviewcontroller。如果就这样的话（打开这里的return 的注释），那么我们可以看到运行结果中就是在下面有个tab站位区间的界面。

![empty_tab](./empty_tab.png)

这时我们再创建几个容器ViewController，并为其创建一个一个带有背景颜色的View，从而方便鉴别。最后将这些容器ViewController赋给上面我们说的数组中：

	rootVC.viewControllers = [tabVC01,tabVC02,tabVC03,tabVC04,tabVC05,tabVC06,]
	
可以看到我们的运行效果：

![tabbar_run](./tabbar_run.png)

## 三、设置单个界面

在上面的代码中，我们除了设置了每个容器ViewController的view属性，从而展示界面效果，同时还为其设置了tabBarItem属性，该属性就是上面Tab占位区域中的元素。其主要由一个小图标的Icon和一个提示文字组成。对应类：UITabBarItem 。我们看下其构造函数：

	init(title: String?, image: UIImage?, tag: Int)
    @availability(iOS, introduced=7.0)
    init(title: String?, image: UIImage?, selectedImage: UIImage?)
    init(tabBarSystemItem systemItem: UITabBarSystemItem, tag: Int)

构造函数里面传入一个title和一个UIImage对象对应上面说的图标Icon和提示文字。在iOS7.0之后还可以设置一个选中状态时的图标。上面的演示中，直接利用XCode的特性，用named属性初始化一个UIImage对象：

	let barAddItemImg = UIImage(named: "barbuttonicon_add")
	
然后用这个UIImage对象和一个title构造一个UITabBarItem:

	tabVC01.tabBarItem = UITabBarItem(title: "One", image: barAddItemImg, tag: 1)
	
在构造完每个子界面的容器ViewController的UITabBarItem后，就可以将其装入UITabBarController中了：
	
	rootVC.viewControllers = [tabVC01,tabVC02,tabVC03,tabVC04,tabVC05,tabVC06,]

诚如上面的推测，这里直接将要控制的ViewController构成一个数组放置在rootVC中。
	
这里，强势的iOS又有一个潜在的规则，Tab上的元素最多不能超过5个（含），多于5个的部分，会将第5个之后的元素全部替换成一个More的UITabBarItem并且其Icon也生成好了。当点击这个“More”的时候，会出现一个TableView的列表将剩余的容器ViewController依次列出来：

![more](./more.png)

这里iOS还自动生成了一个Edit的菜单，点击后用户可以修改TabBarItem的顺序，当然，这一切都是不用我们手动写代码，而是UITabBarController自身带有的功能。

这里我们看到“More”的Title和图标以及点进去后的“Edit”都是自动生成的，那是否可以对这些值进行自定义呢？UITabBarController抛出一个属性让我们可以访问到这个“More”ViewController，也就是：“moreNavigationController” 。从命名中我们就可以看出其是一个NavigationController，那就好办了，翻翻我们前面的一篇文章就知道怎么用这个ViewController。这里我们重新为其生成一个tabBarItem就可以替换在UITabBarController的Tab占位区域中的“More”的Tab了。通过获得moreNavigationController的栈顶的ViewController，遍可以设置其内容中的Title和“Edit”按钮，分别对应到`moreNavigationController.topViewController!.navigationItem.title`和`moreNavigationController.topViewController!.navigationItem.rightBarButtonItem?` ，看下代码：

	rootVC.moreNavigationController.tabBarItem = UITabBarItem(title: "更多", image: barAddItemImg, tag: 7)
	
	rootVC.moreNavigationController.tabBarItem.title = "更多"
	rootVC.moreNavigationController.topViewController!.navigationItem.title = "更多"
	rootVC.moreNavigationController.topViewController!.navigationItem.rightBarButtonItem?.title = "编辑"
	
这里就实现了提示的自定义：

![more_cus](./more_cus.png)

## 四、中间发生了神马
