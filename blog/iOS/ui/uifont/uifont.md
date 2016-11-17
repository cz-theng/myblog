#庖丁UIKit之UIFont
App界面中少不了的肯定是各种各样的文字内容。那如何让文字在不同的位置都有相应的表现效果呢？像Word操作一样，自然干是通过设置各种各样的字体来表达不同的效果。UIKit为此提供了UIFont类型来表示字体。当然，UIFont只是粗略的对已有的字体进行表现，如果希望定制更炫的文本效果,比如数学表达式、电子书，则还需要求助于"CoreText.framework"。
## 创建系统默认字体
iOS系统默认支持好几种字体，并且系统界面也是有特定字体的，比如iOS9就因为更新了新字体--中文字体「苹方」以及英文字体「San Francisco」，被大家甚是调侃了一番。

所以最简单的创建字体的方式就是用系统默认的字体，比如：

	class func systemFont(ofSize fontSize: CGFloat) -> UIFonts // 获取指定大小的系统字体
	class func systemFont(ofSize fontSize: CGFloat,                weight: CGFloat) -> UIFont // 获取指定大小和粗细的系统字体
	class func boldSystemFont(ofSize fontSize: CGFloat) -> UIFont //获得指定大小的粗体系统字体
	class func italicSystemFont(ofSize fontSize: CGFloat) -> UIFont // 获取指定大小的斜体系统字体
	class func monospacedDigitSystemFont(ofSize fontSize: CGFloat,                               weight: CGFloat) -> UIFont // 获取指定大小和粗细的系统字体，并且其中的数字字符间距相等
	
这里介绍的几种方法，无非是在字体大小、粗细、斜体上不同的,但都是系统当前的默认字体。除此之外，iOS10还提供了一套UI推荐标准字号方法：
	
	class func preferredFont(forTextStyle style: UIFontTextStyle) -> UIFont

其通过枚举值规定了各个场景的字号，比如

* 大标题 `.title1` 类似HTML的h1
* 中标题 `.title2` 类似HTML的h2
* 小标题 `.title3` 类似HTML的h3
* 大抬头 `.headline`
* 小抬头 `.subheadline`
* 文本内容主体  `.body`

用这里的枚举，会更符合[iOS Human Interface Guidelines](https://developer.apple.com/ios/human-interface-guidelines/overview/interface-essentials/)
## 获取系统支持的字体

## 获取字体属性

## 创建自定义字体

## 总结


##参考：
1. [Text Programming Guide for iOS](https://developer.apple.com/library/content/documentation/StringsTextFonts/Conceptual/TextAndWebiPhoneOS/Introduction/Introduction.html#//apple_ref/doc/uid/TP40009542)

2. [UIFont Class Reference](https://developer.apple.com/reference/uikit/uifont)