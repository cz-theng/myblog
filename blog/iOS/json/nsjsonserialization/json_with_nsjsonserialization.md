title: 用NSJSONSerialization让JSON变服帖
tags: [JSON, NSJSONSerialization]
category: iOS
date: 2016-03-09
---


之前的文章[使用Ono读取XML文件](http://www.libcz.com/blog/2016/03/08/iOS/xml/Ono/use_ono_to_read_xml/#more)/[简书](http://www.jianshu.com/p/92d8d109bfc8)介绍了如何处理XML数据，随着Web时代的ajax的盛行，在App时代，另一个最常需要处理的的数据就是JSON数据，尤其现在的Restful背景下API数据的传递，更有胜者直接就是JSON RPC。此时既要读取解析JSON也要为数据结构生成对应的JSON数据。在以前，iOS/Mac平台有多钟JSON解决方案，如SBJSON、TouchJSON、YAJL、JSONKit，当然还有C里面的cJSON/RapidJSON可以进行封装，效率和正确率也是刚刚的。Apple自家也提供了一套解决方案：NSJSONSerialization，这个NSJSONSerialization比他们自家的XML解析工具NSXMLParser可好多了，他既有可人的接口，又提供了非凡的效率（有[测评表明比SBJSON/JSONKit等强](http://arthurchen.blog.51cto.com/2483760/723910)），并且是Apple系统提供的正规军，因此首推这个方案。

NSJSONSerialization提供的接口非常简单，甚至于[官网的Manual](https://developer.apple.com/library/ios/documentation/Foundation/Reference/NSJSONSerialization_Class/index.html)只有少量的文字描述。
> You use the NSJSONSerialization class to convert JSON to Foundation objects and convert Foundation objects to JSON



可见，NSJSONSerialization是可以直接将JSON数据转换成Foundation中提供的对象如NSArray、NSDictionary、NSString、NSNumber等；也可以直接把这些Foundation的对象转换成JSON数据，这一看就是个超人性的接口。
<!-- more -->
但是这么好的接口也有些限制，他要求被解析的JSON数据必须是

* 顶级对象需要是一个{}表示的字典或者[]表示的数组，因此也只能对NSArray/NSDictionary做序列化。（这点感觉基本都是这么用的）
* 所有的节点数据必须要能被解析成 NSString, NSNumber, NSArray, NSDictionary 或者 NSNull.反之也只能对这些对象做序列化。
* 字典的Key必须是NSString表达的类型。
* 数字类型的数不能是NaN或者无限大。

总结来看其实只要我们：
在序列化的时候，只要是对NSArray或者NSDictionary对象序列化，并且其单元组成只能是 NSString, NSNumber(NaN/无限大不可以), NSArray, NSDictionary（key必须是NSString） 或者 NSNull即可。也可以通过

	+ (BOOL)isValidJSONObject:(id)obj

这个类方法来判断其是否可以被正确序列化。

##1. 解析JSON数据到Foundation对象
NSJSONSerialization提供了两个方法来解析JSON数据，一个是从NSData里面取数据，另一个是从NSInputStream 输入流中取数据，从而方便对File/Sokcet的操作。数据的格式必须是UTF-8, UTF-16LE, UTF-16BE, UTF-32LE, UTF-32BE中的一种，是否带有BOM都可以。

	+ (nullable id)JSONObjectWithData:(NSData *)data options:(NSJSONReadingOptions)opt error:(NSError **)error;

	+ (nullable id)JSONObjectWithStream:(NSInputStream *)stream options:(NSJSONReadingOptions)opt error:(NSError **)error;

两个函数不同的地方就是第一个参数，一个传入的是NSData一个传入的是NSInputStream.

options参数控制读入的策略:

* NSJSONReadingMutableContainers : 读出来的对象放入到NSMutableArray或者NSMutableDictionary中，默认是放到NSArray/NSDictionary中。这个选项在我们读取一段JSON然后进行追加或者删除节点的时候，非常适合，修改下Array或者Dictionary成员，然后在序列化就可以了。
* NSJSONReadingMutableLeaves： 读出来的每个节点对象的String放入到NSMutableString中，这样就为修改节点提供了可能，在读入后修改节点再序列化回去的场景比较适用。
* NSJSONReadingAllowFragments ： 正常情况JSON的顶级节点要么是Array[]要么是Dictionary{}。如果JSON数据不是通过{}/[]表示的dictionary或者array的片段数据，这用这个选项进行指定。

error参数是Cocoa API常用的出错方式，传入一个NSError **，如果出错，通过这个值返回回来。
解析回来以后就可以按照NSArray或者NSDictionary的方式进行使用了，特别方便。比如：

	{
	    "id": 1,
	    "name": "hanmeimei",
	    "class": [
	        "English",
	        "Mathematics"
	    ]
	}
相当于：

    NSArray *myClass = @[@"English",@"Mathematics"];
    NSDictionary *student = @{@"id":@1, @"name":@"hmeimei", @"class": myClass};
    
解析出来就是一个 student.


##2. 将Foundation对象序列化到JSON中
与上面对应的NSJSONSerialization也提供了两个将对象序列化到JSON的接口，一个是序列化到NSData中，一个是序列化到NSOutputStream中，方便对File/Socket的操作，序列化的结果是UTF-8格式编码数据。

	+ (nullable NSData *)dataWithJSONObject:(id)obj options:(NSJSONWritingOptions)opt error:(NSError **)error;
	
	+ (NSInteger)writeJSONObject:(id)obj toStream:(NSOutputStream *)stream options:(NSJSONWritingOptions)opt error:(NSError **)error;
	
两个函数不同的地方就是第一个参数，一个传入的是NSData一个传入的是NSOutputStream.

默认情况下，生成的JSON是尽量压缩后的结果，去掉了不必要的空格，可读性比较差。如果希望生成可读性较好的格式，比如在调试的阶段，可以使用`NSJSONWritingPrettyPrinted` 的option参数为输出的格式加上必要空格，进行格式化。

同样，如果序列化过程中出错，通过error参数进行返回。在进行序列化的时候可以使用

	+ (BOOL)isValidJSONObject:(id)obj;
判断是否可以正常序列化。

比如上面的对student执行序列化话，就可以得到上面的JSON数据。

##3. 一个示例
最后通过一个示例程序看下基本的调用流程。

JSON文件为students.json:

	[
	    {
	        "id": 1,
	        "name": "hanmeimei",
	        "class": [
	            "English",
	            "Mathematics"
	        ]
	    },
	    {
	        "id": 2,
	        "name": "lilei",
	        "class": [
	            "English",
	            "Mathematics"
	        ]
	    }
	]
	
程序主要代码：

	NSInputStream *ifs = [[NSInputStream alloc] initWithFileAtPath:@"your_file_path/students.json"];
	if (nil == ifs) {
	    NSLog(@"ifs is nil");
	    return -1;
	}
	[ifs open];
	NSError *error = nil;
	NSMutableArray *students = [NSJSONSerialization JSONObjectWithStream:ifs options:NSJSONReadingMutableContainers error:&error];
	if (nil != error) {
	    NSLog(@"Unparse JSON Error");
	}
	for (NSDictionary *student in students) {
	    NSLog(@"student: %@", [student objectForKey:@"name"]);
	    NSLog(@"    select class:");
	    for (NSString *cls in [student objectForKey:@"class"]) {
	        NSLog(@"        %@\n", cls);
	    }
	}
	
	// Parse To
	NSDictionary *xiaowang =@{@"id":@3, @"name":@"xiaowang", @"class": @[@"none"]};
	[students addObject:xiaowang];
	error = nil;
	NSData *jsonBuf  = [NSJSONSerialization dataWithJSONObject:students options:NSJSONWritingPrettyPrinted error:&error];
	NSString *jsonStr = [[NSString alloc] initWithData:jsonBuf encoding:NSUTF8StringEncoding];
	NSLog(@"JSON is %@", jsonStr);

输出为：

	student: hanmeimei
		select class:
	         English
	         Mathematics
	student: lilei
		select class:
		       English
		       Mathematics
	JSON is [
	  {
    "id" : 1,
    "name" : "hanmeimei",
    "class" : [
      "English",
      "Mathematics"
    ]
	  },
	  {
	    "id" : 2,
	    "name" : "lilei",
	    "class" : [
	      "English",
	      "Mathematics"
	    ]
	  },
	  {
	    "id" : 3,
	    "name" : "xiaowang",
	    "class" : [
	      "none"
	    ]
	  }
	]
可以看到加空格的格式化效果还是比较明显的。