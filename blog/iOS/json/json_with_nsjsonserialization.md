# 用NSJSONSerialization让JSON变服帖
之前的文章[使用Ono读取XML文件](http://www.libcz.com/blog/2016/03/08/iOS/xml/Ono/use_ono_to_read_xml/#more)/[简书](http://www.jianshu.com/p/92d8d109bfc8)介绍了如何处理XML数据，随着Web时代的ajax的盛行，在App时代，另一个最常需要处理的的数据就是JSON数据，尤其现在的Restful背景下API数据的传递，更有胜者直接就是JSON RPC。此时既要读取解析JSON也要为数据结构生成对应的JSON数据。在以前，iOS/Mac平台有多中JSON解决方案，如SBJSON、TouchJSON、YAJL、JSONKit，当然还有C里面的CJSON/RapidJSON可以进行封装，效率和正确率也是刚刚的。Apple自家也提供了一套解决方案：NSJSONSerialization，这个NSJSONSerialization比他们自家的XML解析工具NSXMLParser可好多了，他既有可人的接口，又提供了非凡的效率（有[测评表明比SBJSON/JSONKit等强](http://arthurchen.blog.51cto.com/2483760/723910)），并且是Apple系统提供的，因此首推这个方案。

NSJSONSerialization提供的接口非常简单，甚至于[官网的Manual](https://developer.apple.com/library/ios/documentation/Foundation/Reference/NSJSONSerialization_Class/index.html)只有少量的文字描述。
> You use the NSJSONSerialization class to convert JSON to Foundation objects and convert Foundation objects to JSON
可见，NSJSONSerialization是可以直接将JSON数据转换成Foundation中提供的对象的如NSArray、NSDictionary、NSString、NSNumber等；也可以直接把这些Foundation的对象转换成JSON数据，这一看就是个超人性的接口。

但是这么好的接口也有些限制，他要求被解析的JSON数据必须是

* 顶级对象需要是一个{}表示的字典或者[]表示的数组，因此也只能对NSArray/NSDictionary做序列化。（这点感觉基本都是这么用的）
* 所有的节点数据必须要能被解析成 NSString, NSNumber, NSArray, NSDictionary 或者 NSNull.反之也只能对这些对象做序列化。
* 字典的Key必须是NSString表达的类型。
* 数字类型的数不能是NaN或者无限大。

总结来看其实只要我们：
在序列化的时候，最后是只要是对NSArray或者NSDictionary，并且其单元组成只能是 NSString, NSNumber(NaN/无限大不可以), NSArray, NSDictionary（key必须是NSString） 或者 NSNull即可。而在解析JSON数据的时候则可以通过

	+ (BOOL)isValidJSONObject:(id)obj

这个类方法来判断其是否可以被正确解析。