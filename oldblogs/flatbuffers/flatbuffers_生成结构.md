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

除此之外，FB还为获得枚举值得名称抽出对应的接口，这样就可以实现在dump的时候得到枚举的值名。类似于C#里面用print打出枚举值时可以选择打印出枚举值得字面值。

	inline const char **EnumNamesCMD() {
		static const char *names[] = { "CMD_BLOG", "CMD_CATEGORY", nullptr };
		return names;
	}

	inline const char *EnumNameCMD(CMD e) { return EnumNamesCMD()[e]; }
	
通过调用 EnumNameCMD并传入对应的枚举值，即可获得枚举值的字面值。

##3. string类型
字符串在IDL中为“string”最后会被转换成“const flatbuffers::String *”，这个是FB内置的一个类型，实际为signed char的数组。这个暂不去深究其结构.按照FB的说法，其可以为UTF-8或者ASCII字符。

##4. 数组类型
在FB的IDL中，用“[]”来表示数组或者称“Vector”类型。其类型为“[]”中表示，如：

	blogIDs:[int];

会生成：

	const flatbuffers::Vector<int32_t> *
	
也就是转换成对应类型的FB内置的Vector。

##5. Union的生成
对于Union，FB采取的方式并非将其转换成传统C++里面的Union。而是采用`void * data`+`length`+`type`的编码方式进行数据组织。

首先FB为枚举中可以承载的数据内容的`type`做一个FB的枚举值的定义，类似上面的枚举类型抽出枚举字面值获取接口：

	inline const char **EnumNamesMsg() {
		static const char *names[] = { "NONE", "BlogMsg", "CategoryMsg", nullptr };
		return names;
	}

	inline const char *EnumNameMsg(Msg e) { return EnumNamesMsg()[e]; }
	
通过调用`EnumNameMsg`接口，传入对应的枚举值，获得类型枚举值的字面值。

当数据在存入和获取的时候，通过将其转换成`void *`+`len`数据并结合上面的类型枚举进行类型指针的转换。


##6. Table的生成

Table是FB中最主要的数据结构，有点类似Lua中得Table，其主要还是作为数据集合的结构存在，可以理解为C/C++中的class或者struct,虽然FB中也有struct的概念，其实质可以理解为PB中全部带有`required`成员的结构。

FB中得IDL：
	
	table BlogMsg {
		blogID:int ;
		blogName:string;
		blogTXT:[byte];
	}
	
对应于C++中生成的代码主要包含一个C++的两个struct（XXX,XXXBuilder）的定义和一个普通函数(CreateXXX)。其中`XXX`为主要的数据内容承载对象，`XXXBuilder`为对FB的主builder对象`flatbuffers::FlatBufferBuilder `的代理。使用接口`CreateXXX`创建内存对象。


	struct BlogMsg FLATBUFFERS_FINAL_CLASS : private flatbuffers::Table {
	  int32_t blogID() const { return GetField<int32_t>(4, 0); }
	  const flatbuffers::String *blogName() const { return GetPointer<const flatbuffers::String *>(6); }
	  const flatbuffers::Vector<int8_t> *blogTXT() const { return GetPointer<const flatbuffers::Vector<int8_t> *>(8); }
	  bool Verify(flatbuffers::Verifier &verifier) const {
	    return VerifyTableStart(verifier) &&
	           VerifyField<int32_t>(verifier, 4 /* blogID */) &&
	           VerifyField<flatbuffers::uoffset_t>(verifier, 6 /* blogName */) &&
	           verifier.Verify(blogName()) &&
	           VerifyField<flatbuffers::uoffset_t>(verifier, 8 /* blogTXT */) &&
	           verifier.Verify(blogTXT()) &&
	           verifier.EndTable();
	  }
	};
	
	struct BlogMsgBuilder {
	  flatbuffers::FlatBufferBuilder &fbb_;
	  flatbuffers::uoffset_t start_;
	  void add_blogID(int32_t blogID) { fbb_.AddElement<int32_t>(4, blogID, 0); }
	  void add_blogName(flatbuffers::Offset<flatbuffers::String> blogName) { fbb_.AddOffset(6, blogName); }
	  void add_blogTXT(flatbuffers::Offset<flatbuffers::Vector<int8_t>> blogTXT) { fbb_.AddOffset(8, blogTXT); }
	  BlogMsgBuilder(flatbuffers::FlatBufferBuilder &_fbb) : fbb_(_fbb) { start_ = fbb_.StartTable(); }
	  BlogMsgBuilder &operator=(const BlogMsgBuilder &);
	  flatbuffers::Offset<BlogMsg> Finish() {
	    auto o = flatbuffers::Offset<BlogMsg>(fbb_.EndTable(start_, 3));
	    return o;
	  }
	};
	
	inline flatbuffers::Offset<BlogMsg> CreateBlogMsg(flatbuffers::FlatBufferBuilder &_fbb,
	   int32_t blogID = 0,
	   flatbuffers::Offset<flatbuffers::String> blogName = 0,
	   flatbuffers::Offset<flatbuffers::Vector<int8_t>> blogTXT = 0) {
	  BlogMsgBuilder builder_(_fbb);
	  builder_.add_blogTXT(blogTXT);
	  builder_.add_blogName(blogName);
	  builder_.add_blogID(blogID);
	  return builder_.Finish();
	}

为上面的IDL生成的C++代码。

可以看到，对于对象`BlogMsg`主要使用FB的内置基本数据对象以及集合对象（String,Vector）作为成员，存储数据。并包含一个`Verify`的成员函数对结构数据进行合法性判断。

对象`BlogMsgBuilder`主要包含FB的主builder对象`flatbuffers::FlatBufferBuilder `，以及一个表示内存物理位置的偏移`start_`。
同时为每个成员抽象出`add_xxx`的接口用于将对象按照FB的格式存入到FB的主builder对象内存中，并更新偏移`start_`,最后通过调用`Finish`,完成对一个结构体的闭环并返回其在FB的主builder对象中得偏移。

`CreateBlogMsg`接口在FB的主builder对象内存中根据所给值创建一个对应的对象，并返回最终该对象在FB的主builder对象内存中得偏移，结合类型从而构成`type`+`length`+`void *`的经典TLV结构。