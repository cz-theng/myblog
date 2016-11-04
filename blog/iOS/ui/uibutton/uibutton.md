#全面了解UIKit之UIButton

##使用步骤

* 选择一个类型类创建一个按钮
* 设置按钮的背景图片或者标题，并设置好大小
* 为按钮添加触发执行的动作
* 调整按钮在UI中的位置
* 提供辅助信息和国际化的文字或者图片

## 创建指定类型的按钮
按钮需要指定一个类型来创建：

	 buttonWithType:
	
按钮类型之后不可以修改	

按钮类型

    UIButtonTypeCustom = 0,                         // no button type
    UIButtonTypeSystem NS_ENUM_AVAILABLE_IOS(7_0),  // standard system button

    UIButtonTypeDetailDisclosure,
    UIButtonTypeInfoLight,
    UIButtonTypeInfoDark,
    UIButtonTypeContactAdd,

## 按钮状态（5种）

    UIControlStateNormal  
    UIControlStateHighlighted 
    UIControlStateDisabled    
    UIControlStateSelected    
    UIControlStateFocused

## 设置按钮触发动作
方法：

	addTarget:action:forControlEvents:
	
方法的类型：

	- (IBAction)doSomething;
	- (IBAction)doSomething:(id)sender;
	- (IBAction)doSomething:(id)sender forEvent:(UIEvent*)event;	

## 按钮的基本组成
包含三个部分：
*  titleLabel
*  imageView
*  backgroud

![button_component](./images/button_component.png)
	

##参考
[Cocoa Application Competencies for iOS](https://developer.apple.com/library/content/documentation/General/Conceptual/Devpedia-CocoaApp/TargetAction.html#//apple_ref/doc/uid/TP40009071-CH3)