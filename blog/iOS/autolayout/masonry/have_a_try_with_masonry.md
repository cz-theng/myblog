# 活用Masonry
> Masonry is still actively maintained, we are committed to fixing bugs and merging good quality PRs from the wider community. However if you're using Swift in your project, we recommend using SnapKit as it provides better type safety with a simpler API.
-- https://github.com/SnapKit/Masonry

首先来段免责声明，Masonry现在虽然任在维护中，但是官方现在的精力在其Swift版本的[SnapKit](https://github.com/SnapKit/SnapKit)。

Masonry提供了一种链式（chainable）描述AutoLayout的DSL(Domain Specific Language)。何为链式呢？比如

	xiaoming.goToScholl().and.playBasketball()

类似这样，用“.”将各个词语连接起来达成一项功能的时候，这样使得表达式（DSL）更接近自然语言。上面的语句字面意思是不是就是"小明去学校打篮球去了"，会几个英语单词的小学生基本都能读懂。如果真如Masonry自己描述的一样，他用这样一个“chainable”的DSL是否能够消除AutoLayout的复杂和冗余呢？

## 1. 赶紧尝一口

Masonry支持CocoaPods安装（废话，这么Popular的项目怎么能不支持CocoaPods）。在Pod文件中加入

	pod 'Masonry'

然后执行：

	pod install
	
在代码中，只要包含“Masonry.h”头文件就可以了

	#import <Masonry/Masonry.h>

来看个例子效果，在我们写例子程序的时候，经常遇到几个按钮加个日志显示的场景，假设两个按钮在同一行，让后下面一个日志显示的TextView，这种的三角布局：

	
	@interface ViewController ()
	@property (nonatomic, strong) UIView *topLeft;
	@property (nonatomic, strong) UIView *topRight;
	@property (nonatomic, strong) UIView *bottom;
	@end
	
	@implementation ViewController
	
	- (void)viewDidLoad {
	    [super viewDidLoad];
	    // Do any additional setup after loading the view, typically from a nib.
	    _topLeft = [UIView new];
	    [_topLeft setBackgroundColor: [UIColor yellowColor]];
	    _topRight = [UIView new];
	    [_topRight setBackgroundColor:[UIColor redColor]];
	    _bottom = [UIView new];
	    [_bottom setBackgroundColor:[UIColor blueColor]];
	    [self.view addSubview:_topLeft];
	    [self.view addSubview:_topRight];
	    [self.view addSubview:_bottom];
	    
	    
	    // AutoLayout with Masonry
	    [_topLeft mas_makeConstraints:^(MASConstraintMaker *make) {
	        make.width.equalTo(_topRight.mas_width);
	        make.top.equalTo(self.view.mas_top).offset(20);
	        make.left.equalTo(self.view.mas_left).offset(10);
	        make.right.equalTo(_topRight.mas_left).offset(-10);
	        make.bottom.equalTo(_bottom.mas_top).offset(-10);
	    }];
	
	    [_topRight mas_makeConstraints:^(MASConstraintMaker *make) {
	        make.top.equalTo(self.view.mas_top).offset(20);
	        make.right.equalTo(self.view.mas_right).offset(-10);
	        make.bottom.equalTo(_bottom.mas_top).offset(-10);
	    }];
	    
	    [_bottom mas_makeConstraints:^(MASConstraintMaker *make) {
	        make.height.equalTo(_topLeft.mas_height);
	        make.left.equalTo(self.view.mas_left).offset(10);
	        make.right.equalTo(self.view.mas_right).offset(-10);
	        make.bottom.equalTo(self.view.mas_bottom).offset(-10);
	    }];
	    
	
	}

运行后效果如下：

![first_blood](http://images.libcz.com:8000/images/blog/iOS/autolayout/masonry/images/first_blood.png)

## 2.使用Masonry进行布局
看上面的代码，会发现和以往的frame+center布局的不同的是，这里不在使用`initWithFrame`，然后多出来一个函数调用，有且只有这一个函数调用：

	- (NSArray *)mas_makeConstraints:(void(^)(MASConstraintMaker *make))block;
	
正常来说，基本情况下使用这个一个函数就够了。Masonry还提供了另外两个`- (NSArray *)mas_updateConstraints:(void(^)(MASConstraintMaker *make))block;`和`- (NSArray *)mas_remakeConstraints:(void(^)(MASConstraintMaker *make))block;` 描述布局DSL作为补充，三者的原理是一样的，只是不同函数用在不同的上下文，所以只要了解上面这个函数的时候，基本上就掌握了Masonry的DSL了。

** 这里有个需要注意的点，`mas_makeConstraints`调用中影响的view必须是以及被`addSubview`，也就是必须有parentView **

先来看这个函数原型，就只有一个block参数，block内容会被及时的回调，所以这个函数其实也就是为了调用这个block而准备的，而block里面通过`MASConstraintMaker`作为载体来执行我们上面说的“链式”DSL，进行布局动作。所以可以认为上面的：

    [_topRight mas_makeConstraints:^(MASConstraintMaker *make) {
			//make.xxx.xxx().xxx()
    }];

是一个模板，填充里面make打头的DSL即可，这里make就可以认为是要布局的view的代理。对应的，如果要修改一个已经被布局的view的布局策略(只更新新的策略，原有未描述的策略保留)，则使用个`- (NSArray *)mas_updateConstraints:(void(^)(MASConstraintMaker *make))block;`一样的去填充“make”开头的DSL即可。或者完全重新开始布局 `- (NSArray *)mas_remakeConstraints:(void(^)(MASConstraintMaker *make))block;` ，先清除所有布局，然后再加上新布局条件。

了解了这个模板以后，再来看下模板里面变个内容：

	make.width.equalTo(_topRight.mas_width);		
基本格式是：

		make.attr.constrains
		
这里以"make"开头，然后指定其的一个属性（attr），然后再试这个属性的约束(constrains)。约束可能是多级的组合，比如`.equalTo(self.view.mas_top).offset(20)`的两级组合，显示找到父view的top位置，再向下（Y轴）移动20点。


## 3.布局中的属性
上面的attr属性主要有如下几种：


名称| autolayout 对应属性 | 作用
---| ---|---
left|NSLayoutAttributeLeft|左边框
top|NSLayoutAttributeTop|上边框
right|NSLayoutAttributeRight|右边框
bottom|NSLayoutAttributeBottom|下边框
leading|NSLayoutAttributeLeading|正常情况下等同于left
trailing|NSLayoutAttributeTrailing|正常情况下等同于right
centerX|NSLayoutAttributeCenterX| center的X坐标
centerY|NSLayoutAttributeCenterY| center的Y坐标
baseline|NSLayoutAttributeBaseline| 对齐基线
||
leftMargin|NSLayoutAttributeLeftMargin|左边的Margin
rightMargin|NSLayoutAttributeRightMargin|右边的Margin
topMargin|NSLayoutAttributeTopMargin|顶部的Margin
bottomMargin|NSLayoutAttributeBottomMargin|底部的Margin
leadingMargin|NSLayoutAttributeLeadingMargin|前导（基本等于left）Margin
trailingMargin|NSLayoutAttributeTrailingMargin|后尾（基本等于tail）Margin
centerXWithinMargins|NSLayoutAttributeCenterXWithinMargins|中心X坐标Margin
centerYWithinMargins|NSLayoutAttributeCenterYWithinMargins|中心Y坐标Margin
||
width|NSLayoutAttributeWidth|宽度
height|NSLayoutAttributeHeight|高度

注意，这里虽然说属性，但其其实不是属性，而是一个Block定义，为了和调用时候保值一直，这里就说他们是属性了。

这里的属性其实没有什么新鲜的，和IB中调storyboard里面的“Alignment Constraints”面板里面的前七项是完全一致的，只是多了两个新的属性"width"和“height”分别表示“宽度”和高度。

另外Margin也有对应的属性导出。

## 4.布局中的约束

上面的属性其实也不是属性，而是一个Block，其返回值都是`MASConstraint *`。而每个“MASConstraint”都有一些约束动作，其也是一个Block并且返回值任是一个`MASConstraint *`因此就可以用"."号进行连接类似`left.equalTo(self.view.mas_left).offset(10);`进行链式操作了。

下面为了符合调用时表现，将Block写成不带返回值的C函数原型的形式,而影响的属性也替换成上表中表示的属性的Blcok名。

###设置偏移
调用方式|参数|效果
---|---|---
insets(MASEdgeInsets insets)|MASEdgeInsets|设置view的四边缩小大小，等于缩放效果
sizeOffset(CGSize offset)|CGSize| frame的size相当于参考量的偏移大小
centerOffset(CGPoint offset)|CGPoint| center相对于参考量的偏移大小
offset(CGFloat offset)|CGFloat|所指属性相对于参考量的偏移大小

上面的MASEdgeInsets是UIEdgeInsets的typedef:

	typedef struct UIEdgeInsets {
	    CGFloat top, left, bottom, right;  
	} UIEdgeInsets;
类似于一个CGRect。

另外计算偏移的时候是按照iPhone的屏幕坐标的，也就是往下为Y增长方向，往右为X增长方向，所以上面的例子中（-10）表示靠近右边框往左10个点或者靠近下边框网上10个点。

###设置优先级
调用方式|参数|效果
---|---|---
priority|MASLayoutPriority|其实就是float的UILayoutPriority，设置属性的优先级
priorityLow|无| 等于priority(MASLayoutPriorityDefaultLow)
priorityMedium|无|等于priority(MASLayoutPriorityDefaultMedium)
priorityHigh|无|等于priority(MASLayoutPriorityDefaultHigh)

这里Masonry定义了一些priority的常量

    typedef UILayoutPriority MASLayoutPriority;
    static const MASLayoutPriority MASLayoutPriorityRequired = UILayoutPriorityRequired;
    static const MASLayoutPriority MASLayoutPriorityDefaultHigh = UILayoutPriorityDefaultHigh;
    static const MASLayoutPriority MASLayoutPriorityDefaultMedium = 500;
    static const MASLayoutPriority MASLayoutPriorityDefaultLow = UILayoutPriorityDefaultLow;
    static const MASLayoutPriority MASLayoutPriorityFittingSizeLevel = UILayoutPriorityFittingSizeLevel;
    
所以后面直接定义了low、medium以及high,在一般场景，分三个等级已经够用了，不需要再每次记着具体的数值。

### 关系计算
调用方式|参数|效果
---|---|---
equalTo(id attr)|CGFloat| 设置属性等于某个数值
greaterThanOrEqualTo((id attr))|CGFloat| 设置属性大于或等于某个数值
lessThanOrEqualTo(id attr)| CGFloat | 设置属性小于或等于某个数值
multipliedBy(CGFloat multiplier)|CGFloat|设置属性乘以因子后的值
dividedBy(CGFloat divider)|CGFloat|设置属性除以因子后的值

### 连词

还有两个特殊的连词：

	- (MASConstraint *)with;
	- (MASConstraint *)and;
	
实际上他们什么也没有做，只是返回自己本身：

	- (MASConstraint *)with {
	    return self;
	}
	
	- (MASConstraint *)and {
	    return self;
	}
	
但是放到表达式中，却可以作为连词让链式表达式更接近自然语言。

## 5.总结
通过上面的实例程序，和AutoLayout的官方例子一比较也可以看得出Masonry的可读性更强，在Masonry的例子工程中演示的各种示例向我们展示了其基本能
满足大部分的布局需求，所以在布局的时候，还是比较推荐用Masonry试一下，如果产品真的有特殊的要求，再行替代也不迟，只是在demo阶段，Masonry是首要选择。

另外一个需要了解的是，当布局不成功的时候，首先请先不要怀疑Masonry，Masonry只是对AutoLayout的一个轻量封装，先想想AutoLayout的使用约束，是不是
本身的描述就有悖于AutoLayout的设计。这一点可能看文档还不够，需要多去实验才能逐步掌握，希望这边文章能够为你的实践迈出第一步。

## 参考
1. [Masonry](https://github.com/SnapKit/Masonry)
2. [Auto Layout Guide](https://developer.apple.com/library/watchos/documentation/UserExperience/Conceptual/AutolayoutPG/Introduction/Introduction.html)

