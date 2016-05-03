# 活用Masonry
> Masonry is still actively maintained, we are committed to fixing bugs and merging good quality PRs from the wider community. However if you're using Swift in your project, we recommend using SnapKit as it provides better type safety with a simpler API.
-- https://github.com/SnapKit/Masonry

首先来段免责声明，Masonry现在虽然任在维护中，但是官方现在的精力在其Swift版本的[SnapKit](https://github.com/SnapKit/SnapKit)。

Masonry提供了一种链式（chainable）描述AutoLayout的DSL(Domain Specific Language)。何为链式呢？比如

	xiaoming.goToScholl().and.playBasketball()

类似这样，用“.”将各个语义连接起来达成一项功能的时候，这样使得表达式（DSL）更接近自然语言。上面的语句字面意思是不是就是"小明去学校打篮球去了"，会几个英语单词的小学生基本都能读懂。如果真如Masonry自己描述的一样，他用这样一个“chainable”的DSL是否能够消除AutoLayout的复杂和冗余呢？

## 赶紧尝一口

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
	        //make.width.equalTo(_topLeft);
	        make.top.equalTo(self.view.mas_top).offset(20);
	        make.right.equalTo(self.view.mas_right).offset(-10);
	        //make.left.equalTo(_topLeft.mas_left).offset(10);
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

![first_blood](./images/first_blood.png)

## 使用Masonry进行布局

