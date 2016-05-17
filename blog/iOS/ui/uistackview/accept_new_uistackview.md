#接受新时代的UIStackView
距离iOS9发布已经接近一年了，我们即将引来新的iOS 10,为何在这个时候来介绍iOS9中新引入的一个布局组件呢？犹如当年的AutoLayout刚推出来一样，一来文档少、二来操作繁琐，最重要的要是兼容之前的系统，用新技术撸一边等于是多做工。如今在LinkdedIn已经要求从iOS8开始的时代（QQ/微信/微博/淘宝均要求>=iOS7），可以预见iOS10发布后不久的将来iOS9也将成为最低要求，其带来的一些高效率工具（比如这里要介绍的UIStackView）也必将成为主流。

如果有Android相关开发经验，或者从Android开发转到iOS开发，会发现Android4就引入的可以解决多屏幕适配Linerlayout/RelativeLayout在iOS中找不到对应的工具，而在iOS9中，Apple就为我们添加了这样的一个工具，它就是UIStackView。首先不要被名字所迷惑，以为是和UICollectionView、UITableView一样一般作为最外层的容器View，虽然他也确实就是个容器View。其实用一句话就可以概况它的本质：“自动对一组横向或竖向view集布局的容器view”。如果熟悉HTML的话，可以类比"<div />" 不带block熟悉的就是横向布局，带block组合的就是竖向布局。

UIStackView内部是为其托管的子View添加Autolayout来实现其自动布局的，所以要想更熟练的使用UIStackView，最好能对AutoLayout有一定的理解，当然，如果对AutoLayout还不太熟悉，也没有关系，UIStackView的目的就是为使用者封装这些复制的约束关系而存在的，只要看下面文章，相信也能将UIStackView这一高效率组件运用到自己的工程中。

和UICollectionView、UITableView不一样的是，UIStackView没有继承与UIScrollview而是直接继承与UIView，所以对于超出屏幕的内容，还需要自己用UIScrollView进行交互布局。虽然UIStackView是继承与UIView，但是却没有继承UIView的渲染功能，所以UIStackView是没有UI的，也就是不显示本身的。所以类似“backgroundColor”的界面属性就无效了，同时重写 `layerClass`, `drawRect:`甚至`drawLayer:inContext:`都是无效的。UIStackView是一个纯粹的容器View。

## 1. 最简单的一横和一竖
说了这么多，到底要怎么使用呢？先来看个例子，文中Demo都可以在[Github](https://github.com/cz-it/myblog/tree/master/exapmles.proj/xcode.proj/ui/stackview)找到：

![signal_demo](http://images.libcz.com:8000/images/blog/iOS/xcode/custom_template/images/signal_demo.png) ![signal_demo_plan](http://images.libcz.com:8000/images/blog/iOS/xcode/custom_template/images/signal_demo_plan.png)

在上面的例子中，包含两个StackView布局（两个浅蓝色框）:一个上面的横向的，一个下面竖向的。

横向的方框中有三个子图片，竖向的方框中有四个子元素。这样的布局要如何实现呢？其实很简单，先来看在IB中的操作，就像平常一样先拖三个圆圈图片排成一排，然后按住“Command”键，选中三个图片，然后点击Xcode的

	“Editor” -> "Embed In" -> "Stack View"

会发现，三个图片的位置被改动了，紧贴在一起，并且在IB中，看到三个图片被一个新的“Stack View”包含了：

![ib_signal_layer](http://images.libcz.com:8000/images/blog/iOS/xcode/custom_template/images/ib_signal_layer.png)

其实到这里就完成了一半需求了：有个容器View来管理一排子view。 现在在把目光放到IB的属性界面，来完成另一半
需求:

![ib_signal_attr](http://images.libcz.com:8000/images/blog/iOS/xcode/custom_template/images/ib_signal_attr.png)

设置这样的属性，Aligent为“Fill”，Distribution为“Equal Spacing”，Space为“8”。表示： 所有的子视图竖直
方向填充满StackView，也就是子view可能被拉伸到和StackView等高，每个子View之间等距间隔8 point。有了这样两个约束也就能固定子View的布局了，从而实现对子View的AutoLayout。

当然除了对已有元素通过“Embed In”加入StackView，也可以从IB右下角拖一个StackView到面板中，比如这里拖动一个竖直方向的“StackView”到面板中，然后再从图片里面拖几个横着的图片到这里的竖直的StackView中，同时设置space为“8”，就可以完成上面的布局了。当然，这里需要对StackView自己做一些AutoLayout的设置，从而确定容器的布局（也就是位置和大小），然后StackView才能结合属性确定其内部子View的布局。

当然除了使用IB也可以通过代码来创建StackView：

	UIImageView *star1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dynamic_start"]];
	star1.contentMode = UIViewContentModeScaleToFill;
	UIImageView *star2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dynamic_start"]];
	star2.contentMode = UIViewContentModeScaleToFill;
	UIImageView *star3 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dynamic_start"]];
	star2.contentMode = UIViewContentModeScaleToFill;
	UIStackView *starStackView = [[UIStackView alloc] initWithArrangedSubviews:@[star1, star2, star3]];
	starStackView.axis = UILayoutConstraintAxisHorizontal;
	starStackView.alignment =  UIStackViewAlignmentFill
	starStackView.distribution = UIStackViewDistributionEqualSpacing
	starStackView.spacing = 8.0
	
上面的代码也实现了一排横向布局，其中axis控制了水平方向还是竖直方向，alignment、distribution以及spacing对应IB里面的属性设置。

## 2. 修改属性定制StackView
在上面的IB属性栏中，可以看到，StackView的属性其实少的可怜，图中就四个可以设置（其实也确实就这四个加上个子view的数组）。这里的"Axis"比较好理解，就是控制是一横还是一竖，容器的方向。同样的"Spacing"也比较好理解，就是垒在一起的子view之间的距离。但是这个"Alignment"和"Distribution"又是什么呢？我们来通过例子中的"Attr" Tab中的按钮选项来看：

![attr_demo_1](http://images.libcz.com:8000/images/blog/iOS/xcode/custom_template/images/attr_demo_1.png) ![attr_demo_2](http://images.libcz.com:8000/images/blog/iOS/xcode/custom_template/images/attr_demo_2.png)

这里第一排按钮是Alignment，第二排按钮是Distribution。可以运行Demo并体会不同。

这里Alignment主要控制垂直于StackView方向上的对其属性，二Distribution则是控制在StackView延展方向的填充属性：

![attr](http://images.libcz.com:8000/images/blog/iOS/xcode/custom_template/images/attr.png)

下面看看总共都有哪些Alignment和Distribution。

### Alignment
Alignment| 意义| 效果
---|---|---
UIStackViewAlignmentFill|在StackView垂直方向上拉伸所有子view，使得填充完StackView| ![align_fill](http://images.libcz.com:8000/images/blog/iOS/xcode/custom_template/images/alignment/align_fill.png)
UIStackViewAlignmentLeading|在StackView垂直方向上按照子view的leading edge对齐|![align_leading](http://images.libcz.com:8000/images/blog/iOS/xcode/custom_template/images/alignment/align_leading.png)
UIStackViewAlignmentTop|等效UIStackViewAlignmentLeading,用于竖向Stackview|![align_top](http://images.libcz.com:8000/images/blog/iOS/xcode/custom_template/images/alignment/align_top.png)
UIStackViewAlignmentFirstBaseline| 在StackView垂直方向上按照子view 的first baseline对其，仅适用于水平方向StackView |![align_first_baseline](http://images.libcz.com:8000/images/blog/iOS/xcode/custom_template/images/alignment/align_first_baseline.png)
UIStackViewAlignmentCenter| 在StackView垂直方向上按照子View的中心线对其|![align_center](http://images.libcz.com:8000/images/blog/iOS/xcode/custom_template/images/alignment/align_center.png)
UIStackViewAlignmentTrailing| 在StackView垂直方向上按照子View的trailing edge对齐|![align_trailing](http://images.libcz.com:8000/images/blog/iOS/xcode/custom_template/images/alignment/align_trailing.png)
UIStackViewAlignmentBottom|等效UIStackViewAlignmentTrailing,用于竖向Stackview|![align_bottom](http://images.libcz.com:8000/images/blog/iOS/xcode/custom_template/images/alignment/align_bottom.png)
UIStackViewAlignmentLastBaseline|在StackView垂直方向上按照子view 的last baseline对齐，仅适用于水平方向StackView|![align_last_baseline](http://images.libcz.com:8000/images/blog/iOS/xcode/custom_template/images/alignment/align_last_baseline.png)

### Distribution

Distribution| 意义 |效果
---|---|---
UIStackViewDistributionFill |在StackView延伸方向上缩放子View使得子View能填充完StackView，子View的缩放顺序依赖于其hugging优先级，如果相等的话，则按照index顺序|![dist_fill](http://images.libcz.com:8000/images/blog/iOS/xcode/custom_template//images/distribution/dist_fill.png)
UIStackViewDistributionFillEqually|在StackView延伸方向上将每个子View都拉伸成一样长|![dist_fill_equally](http://images.libcz.com:8000/images/blog/iOS/xcode/custom_template//images/distribution/dist_fill_equally.png)
UIStackViewDistributionFillProportionally|在StackView延伸方向上将根据子View的内容进行缩放|![dist_fill_proportionally](http://images.libcz.com:8000/images/blog/iOS/xcode/custom_template//images/distribution/dist_fill_proportionally.png)
UIStackViewDistributionEqualSpacing|在StackView延伸方向上将子View中间隔相等的空白进行缩放，如果子View不够大，则用空白填充开始部分，如果子View过大，则根据hugging顺序缩放，如果相等的话，则按照index顺序|![dist_equal_spacing](http://images.libcz.com:8000/images/blog/iOS/xcode/custom_template/images/distribution/dist_equal_spacing.png)
UIStackViewDistributionEqualCentering|在StackView延伸方向上将子View的中线线，等距进行缩放，如果子View不够大，则用空白填充开始部分，如果子View过大，则根据hugging顺序缩放，如果相等的话，则按照index顺序|![dist_equal_centering](http://images.libcz.com:8000/images/blog/iOS/xcode/custom_template/images/distribution/dist_equal_centering.png) 

虽然上面罗列出来各个属性的作用，但是可能还是不够具体，这个还需要结合Demo或者自己在实际代码中进行设置来体验

## 3. 嵌套布局

上面的一横一竖的例子，在使用的时候，其实不用StackView也是非常容易用AutoLayout布局的，那么怎么样来提现StackView的优势呢？如果把一横一竖进行各种组合，这样就能像网页设计中的"<div />"一样进行丰富的布局了，假设一个这样的布局：

![nested_design](http://images.libcz.com:8000/images/blog/iOS/xcode/custom_template/images/nested_design.png)

可以将其分解成各种横竖的组合，从而得到如下的一个效果图

![nested_demo](http://images.libcz.com:8000/images/blog/iOS/xcode/custom_template/images/nested_demo.png) ![nested_effect](http://images.libcz.com:8000/images/blog/iOS/xcode/custom_template/images/nested_effect.png)

在IB中可以很容易的拖拽实现StackView的嵌套，这里仅仅对最外层的StackView做了大小和位置设置，其他子View均是由StackView来自动控制的。

右上角是一个竖向的StackView（假设名字为A）并设置Aligment为"Leading/Top",Distrubition为"Equal Centering"。然后以A为整体，在和图片一起放到一个横向的StackView（假设名字为B）中，并设置Aligment为"Top",Distrubition为"Fill Equal"。最后将这个B和下面的大图和文字TextView放到一个竖向的StackView中，并设置Aligment为"Leading/Top",Distrubition为"Fill Equal"。这样就通过嵌套StackView完成了一个复杂布局了，和要多每个子view都要设置AutoLayout相比是不是很简单。

## 4. 不用datasource的动态布局
在使用UITableView或者UICollectionView等容器View的时候，通常都会有个datasource来动态的填充其中的容纳的内容，但是同样作为容器View的StackView却没有这样的datasoure，他就只用一个数组和“add/remove”方法来管理其容纳的子view。

最开始的 `- (instancetype)initWithArrangedSubviews:(NSArray<__kindofUIView *> *)views`展示了怎么用一个数组初始化StackView了，数组中的view会依照其顺序添加到容器View StackView中，其包括两个部分，一部分是将布局托管给StackView设置，另一方面会调用addSubView，添加到StackView中显示。

如果需要添加新的子View可以调用：

	- (void)addArrangedSubview:(UIView *)view 
将一个新的view托管给StackView进行布局，并addSubView进行显示。这里新的view会别追加到已有子view的后面，如果想插入到中间，可以使用:

- (void)insertArrangedSubview:(UIView *)view
                      atIndex:(NSUInteger)stackIndex
                        
如果不想显示一个子view要怎么操作呢？当然调用子View的“removeFromSuperview”,但是这样就够了么？上面说了两步，这个remove只对应了其中的显示，但是并没有消除其布局的影响，所以还要调用StackView的：

	- (void)removeArrangedSubview:(UIView *)view
	
取消其对布局的影响。

最后看个例子，点击“赞”会增加星星，点击“贬”会减少星星数目：

![dynamic_demo](http://images.libcz.com:8000/images/blog/iOS/xcode/custom_template/images/dynamic_demo.png)

布局很简单，主要是操作StackView的增减子view:

	@interface DynamicVC ()
	
	@property (weak, nonatomic) IBOutlet UIStackView *starStackView;
	
	@end
	
	@implementation DynamicVC
	
	- (void)viewDidLoad {
	    [super viewDidLoad];
	    // Do any additional setup after loading the view.
	}
	
	- (void)didReceiveMemoryWarning {
	    [super didReceiveMemoryWarning];
	    // Dispose of any resources that can be recreated.
	}
	
	- (instancetype)initWithCoder:(NSCoder *)aDecoder  {
	    if ( self = [super initWithCoder:aDecoder]) {
	        self.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Dynamic" image:[UIImage imageNamed:@"test"] selectedImage:[UIImage imageNamed:@"test"]];
	    }
	    return  self;
	}
	- (IBAction)onUp:(id)sender {
	    UIImageView *star = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dynamic_start"]];
	    star.contentMode = UIViewContentModeScaleToFill;
	    [self.starStackView addArrangedSubview:star];
	
	    [UIView animateWithDuration:1.0 animations:^{
	        [self.starStackView layoutIfNeeded];
	    }];
	}
	
	- (IBAction)onDown:(id)sender {
	    UIImageView *star = [self.starStackView.arrangedSubviews lastObject];
	    [self.starStackView removeArrangedSubview:star];
	    [star removeFromSuperview];
	    [UIView animateWithDuration:1.0 animations:^{
	        [self.starStackView layoutIfNeeded];
	    }];
	}

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
