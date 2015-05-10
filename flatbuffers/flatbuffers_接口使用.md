#Flatbuffers 接口使用
在使用类似PB/Cap'nProto/SBE以及Flatbuffers等“serialization library”的时候。最主要就是使用其序列化和反序列化的功能。

FB通过一个Builder对象来组织一次完整的序列化操作。该对象为`FlatBufferBuilder`，其是非线程安全的，因此想对FB的使用做到线程安全，一定不要在多个线程中共享Builder对象。


##一、序列化接口

##二、反序列化接口