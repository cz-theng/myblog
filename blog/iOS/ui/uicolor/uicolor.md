#UIKit庖丁之UIColor
颜色作为UI最基本的要素之一，是构建界面必不可少的部分。iOS上有三个framework都提供了颜色类型，分别是“Core Image”的 "CIColor"、“ Quartz Core”中的“CoreGraphic”提供的"CGColor"以及这里要介绍的"UIColor"。

所以UIKit提供的元素，比如各种View，各种字体等的颜色设置，我们都可以通过UIColor来进行。 UIColor主要分成两类色系：

* 灰度色，也就是通常说的黑白色
* RGB彩色，用RGB或者HSB加上特别度a组成的彩色

所以UIColor的使用和在CSS或者其他界面组件一样，既有常见颜色的定义，也可以自己根据aRGB也可以根据aHSB调制特定的颜色。

## 0. 使用既定的常用色
UIColor定义了一些最常见的颜色，使用时非常简单，比如设置一个UILabel的背景色为蓝色：

    let lbl = UILabel(frame: CGRect(x: 10, y: 48, width: 100, height: 100))
    lbl.backgroundColor = UIColor.blue
这里`UIColor.blue`就表色蓝色。

类变量|颜色
---|---
black| 黑色
blue| 蓝色
brown|棕色
clear|无色
cyan|蓝绿色
darkGray|深灰
gray| 灰色
green| 绿色
lightGray|浅灰
magenta|品红
orange|橘色
purple|紫色
red|红色
white|白色
yellow|黄色

## 1. 创建自定义颜色
如果上面的常用色满足不了需求，还可以使用灰度或者RGB/HSB给数值进行调色。

先来看黑白色：

	init(white: CGFloat, alpha: CGFloat)

`white`范围是0.0-1.0表示灰度的值，约小颜色越黑。1.0表示白色。

然后来看RGB:

	init(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat)
	
很显然，这里的RGB非常明显，最后一个`alpha`表示透明度。

最后来看HSB:

	init(hue: CGFloat, saturation: CGFloat, brightness: CGFloat, alpha: CGFloat)
	
同样的，参数非常明显，最后的`alpha`也是表示透明度。

既然可以创建颜色，自然也可以获得颜色的RGB/HSB值。UIColor提供了值结果函数：

	func getHue(_ hue: UnsafeMutablePointer<CGFloat>?, 
				 saturation: UnsafeMutablePointer<CGFloat>?, 
				 brightness: UnsafeMutablePointer<CGFloat>?, 
				      alpha: UnsafeMutablePointer<CGFloat>?) -> Bool	
来获得颜色的HSK以及alpha值，需要传递一个指针给对应的参数，然后其被填充预定的值。

同样的：

	func getRed(_ red: UnsafeMutablePointer<CGFloat>?, 
				      green: UnsafeMutablePointer<CGFloat>?, 
				       blue: UnsafeMutablePointer<CGFloat>?, 
				      alpha: UnsafeMutablePointer<CGFloat>?) -> Bool				     
获取其RGB和alpha值。而

	func getWhite(_ white: UnsafeMutablePointer<CGFloat>?, 
        alpha: UnsafeMutablePointer<CGFloat>?) -> Bool
则获得灰度和alpha值。        				      

## 2. 颜色的转换
上面介绍说iOS有三种表示颜色的数据结构，除了UIColor还有CGColor以及CIColor。那么他们是如何转换的呢？

首先来看从其他颜色转换成UIColor：

	init(ciColor: CIColor)
	init(cgColor: CGColor)

UIKit是直接提供构造函数来进行转换的。那要怎么吧UIColor转换成其他颜色呢？其提供了方法	
	var ciColor: CIColor { get }
	var cgColor: CGColor { get }

可以直接获取CIColor和CGColor对象。

可见这里的数据类型转换其实和类型强制转换没什么区别，无非就是通过构造函数和getter来实现的。

除了不同颜色类型的转换，UIColor对于灰色系，还可以通过
	
		func withAlphaComponent(_ alpha: CGFloat) -> UIColor
从原有颜色上获得不同灰度的颜色。


## 3. 最特殊的颜色表示--图片
UIColor还有个让人很费解的颜色--图片。如果之前有Google过如何设置一个View的背景颜色为图片，你一定看到过类似：

        let v = UIView(frame: CGRect(x: 10, y: 180, width: 100, height: 100))
        v.backgroundColor = UIColor(patternImage: UIImage(named: "my_view")!)
        
这样的答案。设置背景图片变成了设置背景颜色。其实可以吧背景图片理解成一种特殊的颜色系，所以也就有了用一个UIImage来初始化颜色的操作了。

