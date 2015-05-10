#Flatbuffers 接口使用
在使用类似PB/Cap'nProto/SBE以及Flatbuffers等“serialization library”的时候。最主要就是使用其序列化和反序列化的功能。

FB通过一个Builder对象来组织一次完整的序列化操作。该对象为`FlatBufferBuilder`，其是非线程安全的，因此想对FB的使用做到线程安全，一定不要在多个线程中共享Builder对象。该对象可以认为是存储容器，所有的序列化操作都会将数据压入到该对象的内存中。

将数据序列化到Builder对象中有两种方法，一种是对于FB内置对象（string/vecotr）分别通过调用Builder对象的`CreateString/CreateVector`来创建。另一种是用户定义复合类型（struct/table）则通过FBC工具生成的`CreateYourDatastruct`的接口生成，该接口需要传递一个Builder对象，实际上通过自定义复合类型的builder代理将数据内容传递给具体存储内容的Builder对象。


##一、序列化接口
###1.1 基本数据类型
###1.2 内置类型
###1.3 自定义复合类型


##二、反序列化接口
###2.1 基本数据类型
###2.2 内置类型
###3.3 自定义复合类型