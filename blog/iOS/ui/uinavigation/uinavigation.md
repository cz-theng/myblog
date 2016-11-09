#定制ViewControoler的头

先来看UIViewController的定义

    @interface UIViewController (UINavigationControllerItem)

    @property(nonatomic,readonly,strong) UINavigationItem *navigationItem; // Created on-demand so that a view controller may customize its navigation appearance.
    @property(nullable, nonatomic,readonly,strong) UINavigationController *navigationController; // If this view controller has been pushed onto a navigation controller, return it.

    @end
这里有个奇怪的点：

> UIViewController居然是UINavigationControllerItem的子类。。。

如果不熟悉UIKit，一般的认知应该是UINavigationController是继承的UIViewController。而UINavigationControllerItem只是UINavigationController的一个组成部分而已。而事实却不是这样，UINavigationController也不是继承自UIViewController。再来看这两个成员：

* UINavigationItem *navigationItem：只读，所以不能自己创建一个UINavigationItem给他，但是他里面的成员却是可以进行修改的
* UINavigationController *navigationController：只读，而且只在被UINavigationController push之后返回其父UINavigationController而已。所以对于自定义没啥用处

## 类的关系
UIBarButtonItem 继承自UIBarItem 
UINavigationItem 继承自NSObject 

