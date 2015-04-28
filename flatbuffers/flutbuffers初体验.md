#Flutbuffers初体验
Flutbuffers作为新时代的序列化工具，出身于Google，和Golang一样，出身富贵。那么到底好用不好用？适用于什么场景？怎样使用？

##1. 先看看定义语法

	// IDL of Flutbuffers
	namespace Message;
	
	enum CMD:ubyte { CMD_BLOG = 0, CMD_CATEGORY}
	
	union Msg { BlogMsg, CategoryMsg}
	
	table RspMsg {
	  cmd: ubyte;
	  version: ushort = 1;
	  msg: Msg;
	}
	
	table BlogMsg {
	  blogID:int ;
	  blogName:string;
	  blogTXT:[byte];
	}
	
	table CategoryMsg {
	  categoryID:int;
	  categoryName:string;
	  blogIDs:[int];
	}
	
	root_type ReqMsg;
	
如上的IDL(Interface Definition Language)用来定义一条通讯消息的协议结构。该消息由一个消息结构`RspMsg`承载了一个命令字`cmd`和一个版本号`version`以及用Union定义的具体的消息内容。消息内容根据命令字进行解析，判断是否哪种消息内容。这里有消息`BlogMsg`和`CategoryMsg`类型。其中有普通的整形数`int`以及字符串类型`stirng`,除了基本的数据类型之外，还有数组类型或者叫做容器类型。比如这里的整形数组`[int]`

在Flutbuffers中的定义语言。主要有几种数据类型：enum、union、table、struct。除了table，其他几种类型和C++等类C语言中得类型功能类似。其中Table可以认为是类似`class`或者更直接的是类似Lua中得`table`。可以认为是聚合的数据类型。

##2. 写入数据（C++）
写完了定义数据结构的文件，就可以使用flatbuffers的编译工具`flatc`将上述文件生成对应的.h文件（这里仅以C++为例）

具体命令为：

	flatc -c message.fbs
	
对应会生成`message_generated.h`的文件（这里message为本例中文件名称，生成的文件为xxx_generated.h）。

在C++中使用Flatbuffers的时候。需要引用Flatbuffersf安装包种的include目录下的头文件。并同时依赖上面生成的头文件。

使用过程需要先创建一个`FlatBufferBuilder`，通过该builer创建相应的flatbuffers内部的数据结构。

    auto blogName = fbb.CreateString("blog");
    auto blogTXT  = fbb.CreateVector((int8_t *)txt.data(),txt.size());
    int blogID = 1;
   
对于基本数字类型 ：

	8 bit: byte ubyte bool
	16 bit: short ushort
	32 bit: int uint float
	64 bit: long ulong double
	
可以直接进行赋值，而对于字符串和vector类型数据，需要使用`FlatBufferBuilder`的`CreateString`和`CreateVector`来创建：

    auto blogName = fbb.CreateString("blog");
    auto blogTXT  = fbb.CreateVector((int8_t *)txt.data(),txt.size());
    
而对于用户自定义的数据结构，则需要使用生成的头文件中对应的函数进行创建：

    auto blogMsg = Message::CreateBlogMsg(fbb,blogID,blogName,blogTXT);
    
该函数由flatc生成。

这里需要注意的是，对于Union类型，Flatbuffers是使用标志位“类型” 和数据来存储的，因此在创建时也需要进行相应的转换：

	struct ReqMsg FLATBUFFERS_FINAL_CLASS : private flatbuffers::Table {
	  uint8_t cmd() const { return GetField<uint8_t>(4, 0); }
	  uint16_t version() const { return GetField<uint16_t>(6, 1); }
	  Msg msg_type() const { return static_cast<Msg>(GetField<uint8_t>(8, 0)); }
	  const void *msg() const { return GetPointer<const void *>(10); }
	  bool Verify(flatbuffers::Verifier &verifier) const {
	    return VerifyTableStart(verifier) &&
	           VerifyField<uint8_t>(verifier, 4 /* cmd */) &&
	           VerifyField<uint16_t>(verifier, 6 /* version */) &&
	           VerifyField<uint8_t>(verifier, 8 /* msg_type */) &&
	           VerifyField<flatbuffers::uoffset_t>(verifier, 10 /* msg */) &&
	           VerifyMsg(verifier, msg(), msg_type()) &&
	           verifier.EndTable();
	  }
	};
	
这里通过msg_type()来区别（void*）表示的数据。因此创建的时候，需要使用：

	auto blogReq = Message::CreateReqMsg(fbb,cmd,version,Message::Msg_BlogMsg,blogMsg.Union());
这里指定类型`Message::Msg_BlogMsg`,并调用Union类型数据的`Union()`获得其内部的数据。

最后通过调用：

	Message::FinishReqMsgBuffer(fbb, blogReq);
	
对数据进行落地。当需要二进制数据时，通过调用：

    auto buf = fbb.GetBufferPointer();
    auto size = fbb.GetSize();
获得二进制数据内存。


#3. 读取数据（C++）
读取以及序列化好的二进制数据时，只用用Root_Type的Get函数即可将二进制数据读入：

	auto msg = Message::GetReqMsg(buf);

这里msg为root_type的ReqMsg类型。通过该类型的属性方法可以获得属性的值，这里属性方法的定义有点类似于Objective-C里面的Accesser的定义，或者叫做property的定义，就是通过属性名位函数名获得该属性的值。如：

	 printf("verstion is %d\n",msg->version());
    printf("cmd  is %d\n",msg->cmd());
    
对于自定义数据类型，这可以通过指针的直接转换得到：

	Message::BlogMsg *blogMsgUser =(Message::BlogMsg *) msg->msg();	printf("blogName is %s\n",blogMsgUser->blogName()->c_str());
	
这也就是Flatbuffers相对于PB优点所在处，无需进行打包和解包的操作，即可获得对象的内容。
