#接受新时代的UIStackView
距离iOS9发布已经接近一年了，我们即将引来新的iOS 10,为何在这个时候来介绍iOS9中新引入的一个布局组件呢？犹如当年的AutoLayout刚推出来一样，一来文档少、而来操作繁琐，最重要的要兼容之前的系统，用新技术撸一边等于是多做工。如今在LinkdedIn已经要求从iOS8开始的时代（QQ/微信/微博/淘宝均要求>=iOS7），可以预见未来iOS9也即将成为最低要求，其带来的一些高效率工具（比如这里要介绍的UIStackView）也必将成为主流。

如果有Android相关开发经验，或者从Android开发转到iOS开发，会发现Android4就引入的可以解决多屏幕适配Linerlayout在iOS中找不到对应的工具，而在iOS9中，Apple就为我们添加了这样的一个工具，它就是UIStackView。首先不要被名字所迷惑，以为是和UICollectionView、UITableView一样一般作为最外层的容器View，虽然他也确实就是个容器View。其实用一句话就可以概况它的本质：“自动对一组横向或竖向view集布局的容器view”。如果熟悉HTML的话，可以类比"<div />" 不带block熟悉的就是横向布局，带block组合的就是竖向布局。

UIStackView内部是为其托管的子View添加Autolayout来实现其自动布局的，所以要能更熟练的使用UIStackView，最好能对AutoLayout有一定的理解，当然，如果对AutoLayout还不太熟悉，也没有关系，UIStackView的目的就是为使用者封装这些复制的约束关系而存在的，只要看下面文章，相信也能将UIStackView这一高效率组件运用到自己的工程中。

和UICollectionView、UITableView不一样的是，UIStackView没有继承与UIScrollview而是直接继承与UIView，所以对于超出屏幕的内容，还需要自己用UIScrollView进行交互布局。虽然UIStackView是继承与UIView，但是却没有继承UIView的渲染功能，所以UIStackView是没有UI的，也就是不显示本身的。所以类似“backgroundColor”的界面属性就无效了，同时重写 `layerClass`, `drawRect:`甚至`drawLayer:inContext:`都是无效的。UIStackView是一个纯粹的容器View。
## 1. 最简单的一横和一竖

## 2. 修改属性定制StackView

## 3. 嵌套布局

## 4. 不用datasource的动态布局

## 5. 总结
在当前的产品中，可能会考虑到兼容以前的版本，不会考虑用UIStackView在重新一遍以前的逻辑，毕竟上面举例的场景，其实不用UIStackView，也是有很成熟的
方法进行布局，而且基本都被大家运用在产品中，经过了生产环境的验证。但是了解了UIStackView，在日后做Demo的时候，可以为布局节省很多精力，并且也可以
为未来iOS9成为最低配时积累经验，在未来的产品中用更高效的工具进行布局，节省耗在布局上的时间。所以还是推荐大家在iOS10即将出生之际学习下这个新时代的
布局工具。

UIStackView其实很好理解，就是一横一竖的关系，但是通过调节其属性（UIStackViewDistribution和UIStackViewAlignment）可以透明的运用AutoLayout带来强大的自动布局功能。通过自己多联系尝试不同属性的组合，积累经验，这样才能在需要的时候，快速的用UIStackView处理以前需要很多步骤
（比如各种Autolayout约束、用UICollectionView或者UITableView）才能搞定的布局。

另外UIStackView是对AutoLayout的一个封装，其本身是和AutoLayout不冲突的(实际上就是新增了几条约束)，所以熟练使用AutoLayout，并和UIStackView配合，能够实现大量复杂的布局效果。


## 参考
1. [iOS 9: Getting Started with UIStackView](http://code.tutsplus.com/tutorials/ios-9-getting-started-with-uistackview--cms-24193)
2. [UIStackView Class Reference](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UIStackView_Class_Reference/index.html#//apple_ref/c/tdef/UIStackViewAlignment)
3. [Auto Layout Guide -- Stack Views](https://developer.apple.com/library/ios/documentation/UserExperience/Conceptual/AutolayoutPG/LayoutUsingStackViews.html#//apple_ref/doc/uid/TP40010853-CH11-SW1)
4. [iOS 9界面适配利器：详解Xcode 7的新特性UIStackView](http://www.csdn.net/article/2015-08-04/2825372/1)
