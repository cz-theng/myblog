#Flatbuffers 接口使用
在使用类似PB/Cap'nProto/SBE以及Flatbuffers等“serialization library”的时候。最主要就是使用其序列化和反序列化的功能。

FB通过一个Builder对象来组织一次完整的序列化操作。该对象为`FlatBufferBuilder`，其是非线程安全的，因此想对FB的使用做到线程安全，一定不要在多个线程中共享Builder对象。该对象可以认为是存储容器，所有的序列化操作都会将数据压入到该对象的内存中。

将数据序列化到Builder对象中有两种方法，一种是对于FB内置对象（string/vecotr）分别通过调用Builder对象的`CreateString/CreateVector`来创建。另一种是用户定义复合类型（struct/table）则通过FBC工具生成的`CreateYourDatastruct`的接口生成，该接口需要传递一个Builder对象，实际上通过自定义复合类型的builder代理将数据内容传递给具体存储内容的Builder对象。


##一、序列化接口
###1.1 基本数据类型
对于基本的数据类型

	8 bit: byte ubyte bool
	16 bit: short ushort
	32 bit: int uint float
	64 bit: long ulong double
分别有对应的标准整形"<cstdint.h>"类型。



|FB类型 |  STDInt类型|
|------|------------|
|byte |int8_t|
|ubyte|uint8_t|
|bool|uint8_t|
|short|int16_t|
|ushort|uint16_t|
|int|int32_t|
|uint|uint32_t|
|float|float|
|long|int32_t|
|ulong|int64_t|
|double|double|


这些类型值的*存* *取*可以直接通过对应的类型进行，必要时可以进行相应的强制转换。更直接的，对于字面值数字则可以直接进行赋值。


###1.2 内置类型
内置类型主要是String和Vector。FB自己构造了两个类STL的容器对象，分别是`String`和`Vector`，String实际上就是'char'型的'Vector'.
	
		struct String : public Vector<char> {
		...
		}
`Vector`则是FB使用的自己定义的主要容器类型。

当要序列化一个字符串的时候，使用FB的Builder对象的`CreateString`方法，该方法接受三种参数类型：

	* char* C风格的字符串
	* char* + int len的buffer指定的内存段
	* C++的STL中的std::string类型
	
该函数返回在Builder内存对象中存储了该字符串后的内存的偏移也就是数据最后一个元素的偏移地址。在FB中用了模板类型`Offset`来表示该值，该类型有个`Union`的接口，用来返回`void *`指针偏移，在Union对象中，因为内部的成员的结构不确定，因此都一个Offset<void>表示其地址。

创建Vector的时候，Builder对象有`CreateVector`方法，该方法接受四种参数：
	
	* 同一基础类型的buffer段和数目。
	* 同一基础类型的vector
	* struct类型的buffer段和数目
	* struct类型的vector

该函数函数一样返回内存位置的偏移。

###1.3 自定义复合类型
自定义复合类型主要分为`struct`和`table`类型。由于`struct`类型的所有字段都是必须的，因此在构造的时候直接用其构造函数，并依次传入每个成员的值即可。如[官方示例中](http://google.github.io/flatbuffers/md__cpp_usage.html)的：
	
	Vec3 vec(1, 2, 3);
	
对于Table类型。在“flatc”命令行生成的头文件中有对应的`CreateXxx`的函数。该函数于上面的Builder对象的CreateString/CreateVector类似，返回其在内存中的偏移，不同的是在传递成员的最开始需要传递Buidler对象。将table内部的数据都序列化到Builder中的内存中。

###1.4 获得序列化的数据

在完成对对象的赋值之后，通过调用Builder对象的`Finish`接口完成对所有数据的落地。该接口需要指定“Root”	对象的偏移位置。

	template<typename T> void Finish(Offset<T> root,
                                   const char *file_identifier = nullptr) 
或者也可以调用"flatc"为“root”类型生成的`FinishRootType`方法。
	
	FinishReqMsgBuffer(flatbuffers::FlatBufferBuilder &fbb, flatbuffers::Offset<ReqMsg> root)；

最后调用Builder对象的`GetBufferPointer`方法获得序列化之后内存的起始地址，`GetSize`获得序列化后内存的大小。

##二、反序列化接口
在获得了FB产生的序列化之后的二级制数据后，首先要获得其root类型。从而对其中的数据进行进一步的解释。可以通过"flatc"产生的`GetRootType`方法获得。该方法传入二进制数据内存地址，返回root类型的数据对象。

对于成员的获取，FB为其生成了类似OC语言里面的Accessor方法，即同名的`Get`方法，假设有个成员名位“name”，那么通过调用该类型的“name()”方法即可获得其值。
