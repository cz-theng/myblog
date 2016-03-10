title: 使用Ono读取XML文件
tags: Ono xml
category: iOS
date: 2016-03-04
---


在做App的过程中，读取XML文件是最常见的功能之一。并且在iOS的发展过程中涌现出了多种XML的解决方案。如Apple自家提供的NSXMLParser和libxml2(C接口).另外还有大量第三方库工具如TBXML、TouchXML、KissXML、TinyXML。在[raywenderlich上面有个详细的对比](https://www.raywenderlich.com/553/xml-tutorial-for-ios-how-to-choose-the-best-xml-parser-for-your-iphone-project)，他的对比结论是：

* 如果仅仅是解析比较小的XML数据，可以考虑NSXMLParser、TouchXML、KissXML或者GDataXML ，理由是简单好用
* 如果是解析比较大数据的XML，则推荐 libxml2(SAX模式)或者 TBXML。性能较好，但是使用复杂

> 解析XML通常有两种方式：DOM和SAX

>DOM解析XML时，读入整个XML文档并构建一个驻留内存的树结构（称“节点树”），之后就通过遍历树结构可以检索任意XML节点，读取它的属性和值。而起通常情况下，可以借助XPath，直接查询XML节点。
>SAX解析XML，是基于事件通知的模式，一边读取XML文档一边处理，不必等整个文档加载完之后才采取操作，当在读取解析过程中遇到需要处理的对象，会发出通知对其进行处理。

从上面来看，后两者可以满足各种场景，只是使用上面偏向复杂，尤其是libxml2还是C接口。而今天我们要介绍的是Ono就是对这个C接口的libxml2的一层OC友好接口的封装，这个接口是谁设计的呢？靠谱么？
<!-- more -->
来，我们可以看下他的作者:Mattt Thompson，[matt](https://github.com/mattt) github显示他供职于Apple，且是著名的FormatKit的作者。

这样它就既继承了libxml2的高效，同时又拥有了和NSXMLParser一样友好的接口。

不过现在的Ono有点比较坑的是没有提供修改XML的接口，仅可用于读取的XML(如配置文件、数据文件)的场景(客户端更多的场景还是解析XML)。



##1. 集成Ono
Ono提供了CocoaPods支持，因此只要在Podfile里面加上

	pod 'Ono'
	
然后执行`pod install` 即可完成对Ono的安装，由于Ono是封装的libxml2，因此需要在“Build Phases”里面的“Link Binary with Libraries”里面添加上对libxml2的依赖.可以看到Ono的源码非常简单，只有两个文件（外加一个版本信息文件）总共1.5k行左右代码完成对libxml2的一个友好OC API的封装。

在需要用到Ono的文件里面import头文件：

	#import <Ono/Ono.h>
	
即可。

Demo可以参考作者自己的[Demo](https://github.com/mattt/Ono/tree/master/Example)。

## 2. 加载XML数据
XML数据对象由ONOXMLDocument来表示。其可以从NSData或者NSString中进行加载。

	XMLDocumentWithString:(NSString *)string
                encoding:(NSStringEncoding)encoding
                   error:(NSError * __autoreleasing *)error;
                   
	XMLDocumentWithData:(NSData *)data
						 error:(NSError * __autoreleasing *)error;
					
encoding参数表示数据的格式，可以从文件中读取数据内容到NSData中，然后从NSData中进行解析得到一个ONOXMLDocument。如：
	
	ONOXMLDocument *document = [ONOXMLDocument XMLDocumentWithData:[NSData dataWithContentsOfFile:xmlFilePath] error:&error];
	if (error || nil == document) {
		 NSLog(@"[Error] %@", error);
		 return nil;
	}


## 3.获取节点信息
ONOXMLDocument有个rootElement成员表示XML数据的根节点，其实一个ONOXMLElement结构对象。该结构用来描述每一个节点，每个节点的属性都保存在该对象中，如:

属性|类型|意义说明
---|---|---
tag| NSString|节点的名字
lineNumber| NSUInteger| 所在行号
attributes|NSDictionary| 节点属性
parent| ONOXMLElement| 父亲节点
children | NSArray | 子节点
previousSibling | ONOXMLElement| 左（前一个）兄弟节点
nextSibling | ONOXMLElement | 右兄弟节点
blank|BOOL | 节点是否为空

除了上面直接的属性外，还可以通过Ono提供的接口直接获得相关信息

* -(id)valueForAttribute:(NSString *)attribute; 
	
直接获得这个节点的某个属性。比如

	<?xml version="1.0" encoding="utf-8"?>
	<student name="pony"> 	</student>
要获得student节点的name属性,直接对student（tag为student）节点调用`valueForAttribute：@“name”` 即可。

* -(NSString *)stringValue;

将该节点的内容当成字符串，获取该节点的字符串值。如：


	<?xml version="1.0" encoding="utf-8"?>
	<city> shenzhen 	</city>
city节点(tag为city)的 stringValue 为“shenzhen”。

* -(NSNumber *)numberValue;

将该节点的内容当成数字，获取该节点的数字内容。如：

	<?xml version="1.0" encoding="utf-8"?>
	<number> 1024	</number>	
number节点的numberValue为1024

* -(NSDate *)dateValue;
将该节点当成日期进行解析，获得该节点的日期内容。如：

	<?xml version="1.0" encoding="utf-8"?>
	<date> 2016-03-15 </date>	
	
date节点的dateValue为NSDate表示的2016年3月15日，可见这里接口非常友好，Ono已经自动帮我们转换成了NSDate类型。

## 4.获取同类节点
为了方便使用Ono为我们封装了一系列的遍历接口，可以满足基本的使用，如：
###获得指定tag的第一个元素

	-(ONOXMLElement *)firstChildWithTag:(NSString *)tag;
如果用于
	<?xml version="1.0" encoding="utf-8"?>
	<city> shenzhen 	</city>
	<city> shanghai   </city>
传入city会得到第一个"shenzhen"。

###返回值为tag的所有子节点

	-(NSArray *)childrenWithTag:(NSString *)tag;

如果对上面数据进行操作则可以得到"shanghai"、"shenzhen"组成的数组，一般对于数组较为常用。

### 按照索引返回第idx个子节点
	
	-(id)objectAtIndexedSubscript:(NSUInteger)idx;

将节点按照顺序进行排列，按照索引返回第idx个子节点。


## 5.通过选择器获取类型节点
如何在解析的过程中找到目标节点，或者怎么去遍历节点元素，Ono支持两种选择器
> XPath： XPath是XML文档内容寻址语言，他将一个XML文档建模成为一棵节点树，有不同类型的节点，包括元素节点、属性节点和正文节点。XPath定义了一种方法来计算每类的节点的字串值。简单来说就是通过一级一级路径找元素
> 
> CSS： CSS就是CSS那个描述HTML格式里面用到的选择器方法，一般用于HTML，如使用#id来根据ID获取元素,以及使用.class来根据class获取元素.

因此Ono既支持标准格式的XML也支持HTML(HTML是XML的子集)。

Ono中通过ONOSearching协议定义了其选择器接口：
	
	//XPath API
	- (id <NSFastEnumeration>)XPath:(NSString *)XPath;
	- (void)enumerateElementsWithXPath:(NSString *)XPath
                           usingBlock:(void (^)(ONOXMLElement *element, NSUInteger idx, BOOL *stop))block;
	- (ONOXMLElement *)firstChildWithXPath:(NSString *)XPath;      
	
	//CSS API
	- (id <NSFastEnumeration>)CSS:(NSString *)CSS;
	- (void)enumerateElementsWithCSS:(NSString *)CSS
                         usingBlock:(void (^)(ONOXMLElement *element, NSUInteger idx, BOOL *stop))block;                     
	- (ONOXMLElement *)firstChildWithCSS:(NSString *)CSS;                      

可以看到XPath的接口和CSS基本是对应一致的，其实也就是适用对象不同，CSS用于HTML，XPath用于XML，这里当然我们就以XPath来进行介绍。接口主要分成三类

###获得所有符合XPath描述的节点对象
	(id <NSFastEnumeration>)XPath:(NSString *)XPath;

可以获得获得符合XPath描述的所有对象的一个可迭代对象，可以适用for...in...语法对其进行遍历，然后取出每个ONOXMLElement进行相关操作。

###获得符合条件的第一个节点
	(ONOXMLElement *)firstChildWithXPath:(NSString *)XPath;
	
字面意思以及说的很清楚了，就是获得符合XPath描述的所有节点中的第一个节点。

###遍历符合的XPath节点

	(void)enumerateElementsWithXPath:(NSString *)XPath 
									 usingBlock:(void (^)(ONOXMLElement *element, NSUInteger idx, BOOL *stop))block;
	
手动获得所有符合XPath定义的节点迭代器再进行操作，在代码上面还是比较的不美观，Ono结合OC的block特点，还为我们提供了一个用block遍历节点的接口。该函数会将block运行于符合XPath定义的节点。

element表示所遍历到的节点，idx表示其下标，该下标就是上面`objectAtIndexedSubscript`用到的下标， stop控制是否继续遍历，如果被设置为NO，则不继续遍历了。比如:

	 NSString *XPath = @"//food/name";
	 NSLog(@"XPath Search: %@", XPath);
	 [document enumerateElementsWithXPath:XPath usingBlock:^(ONOXMLElement *element, __unused NSUInteger idx, __unused BOOL *stop) {
	     NSLog(@"%@", element);
	 }];
	 
会一次打印出所有food节点下的name节点。





