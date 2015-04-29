# Flatbuffers 生成结构
Flatbuffer生成的代码，对于C++主要是一个.h文件。其中主要包含相关`struct`、`enum`以及相关辅助的函数定义。
接着之前“[Flutbuffers初体验](http://www.libcz.com/?p=4)”文中所说，主要观察“message.fbs”和其生成的"message_generated.h"文件。

##1. 基本的数据类型

* 8 bit: byte ubyte bool
* 16 bit: short ushort
* 32 bit: int uint float
* 64 bit: long ulong double

对于整形数据，会转换成对应的“stdint.h”中标准的整形类型。

	b: byte;
	ub: ubyte;
	bo: bool;
	s:short;
	us: ushort;
	i:int;
	ui: uint;
	f: float;
	l: long;
	ul: ulong;
	d: double;
	
对应生成的代码为：

	int8_t b_;
	uint8_t ub_;
	uint8_t bo_;
	int8_t __padding0;
	int16_t s_;
	uint16_t us_;
	int32_t i_;
	uint32_t ui_;
	float f_;
	int32_t __padding1;
	int64_t l_;
	uint64_t ul_;
	double d_;

依次为stdint中得类型。



##2. enum的生成
IDL中得定义为：

	enum CMD:ubyte { CMD_BLOG = 0, CMD_CATEGORY}
	
对应的生成的C++代码为：
	
	enum CMD {                                                                                              
		CMD_CMD_BLOG = 0,                                                                                     
		CMD_CMD_CATEGORY = 1                                                                                  
	};
	
这里可以看到，FB生成的代码中会自动加上枚举类型的前缀，更符合现代语言语法的表示。其中枚举的值和在C++中的基本一致，默认增加一。

##3. string类型
字符串在IDL中为“string”最后会被转换成“const flatbuffers::String *”，这个是FB内置的一个类型，实际为signed char的数组。这个暂不去深究其结构.按照FB的说法，其可以为UTF-8或者ASCII字符。

##4. 数组类型
在FB的IDL中，用“[]”来表示数组或者称“Vector”类型。其类型为“[]”中表示，如：

	blogIDs:[int];

会生成：

	const flatbuffers::Vector<int32_t> *
	
也就是转换成对应类型的FB内置的Vector。

##5. Union的生成

##6. Table的生成