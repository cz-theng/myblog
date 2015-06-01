#Flatbuffers实现
FB的实现主要分为两个部分，一个是FB自身的库文件，实际上就是头文件。另一部分是Flatc攻击更加IDL生成的头文件。库的头文件主要是“flatbuffers.h”，定义了Builder类型`FlatBufferBuilder`。而生成的头文件则主要包含自定义中“Union”、"Struct"、"Table"等数据类型的定义。


##一、编码端序
在FB内部，数据都是按照小端序进行组织的，当今时代和当年的网络不一样，大家你一个标准，我一个规则。现今大部分的设备都是采用的小端序，因此FB将所有的数据按照小端序进行组织，最终在网络上呈现出字符流，就可以减少大量的端序转换操作，从而提高效率。该规则通过FLATBUFFERS_LITTLEENDIAN宏进行控制。

端序的转换主要在下面的函数中：
	
	template<typename T> T EndianScalar(T t) {
	  #if FLATBUFFERS_LITTLEENDIAN
	    return t;
	  #else
	    #if defined(_MSC_VER)
	      #pragma push_macro("__builtin_bswap16")
	      #pragma push_macro("__builtin_bswap32")
	      #pragma push_macro("__builtin_bswap64")
	      #define __builtin_bswap16 _byteswap_ushort
	      #define __builtin_bswap32 _byteswap_ulong
	      #define __builtin_bswap64 _byteswap_uint64
	    #endif
	    // If you're on the few remaining big endian platforms, we make the bold
	    // assumption you're also on gcc/clang, and thus have bswap intrinsics:
	    if (sizeof(T) == 1) {   // Compile-time if-then's.
	      return t;
	    } else if (sizeof(T) == 2) {
	      auto r = __builtin_bswap16(*reinterpret_cast<uint16_t *>(&t));
	      return *reinterpret_cast<T *>(&r);
	    } else if (sizeof(T) == 4) {
	      auto r = __builtin_bswap32(*reinterpret_cast<uint32_t *>(&t));
	      return *reinterpret_cast<T *>(&r);
	    } else if (sizeof(T) == 8) {
	      auto r = __builtin_bswap64(*reinterpret_cast<uint64_t *>(&t));
	      return *reinterpret_cast<T *>(&r);
	    } else {
	      assert(0);
	    }
	    #if defined(_MSC_VER)
	      #pragma pop_macro("__builtin_bswap16")
	      #pragma pop_macro("__builtin_bswap32")
	      #pragma pop_macro("__builtin_bswap64")
	    #endif
	  #endif
	}

主要通过gcc的扩展:__builtin_bswap16/32/64交换字节序，对于vs是__builtin_bswap16/_byteswap_ulong/_byteswap_uint64。这些函数也可以用来实现hton/ntoh。这里的push_macro/pop_macro，用来临时保存vs中该宏的定义，待使用后重新恢复。	


##二、Builder对象

##三、内置类型
FB内置了两种类型，`flatbuffers::String`和`flatbuffers::Vector`。其中"String"实际上就是“Vector<char>”。这里两者的实现其实和stl的实现是类似的，原理可以参考侯杰老师的《STL源码剖析》以及[SGI的STL](http://www.sgi.com/tech/stl/)实现。主要就是实现标准vector的操作。

与STL的Vector不同的是，FB的Vector只用作从FB管理的内存中访问已有结构的数据，而不能通过构造函数创建一个Vector，Vector的创建需要通过Builder对象的"CreateVector"方法。

Vector的实现主要由两个结构组成：VectorIterator和Vector。并且只实现了Get方法，如上所述，这里的Vector主要用来从内存中读出数据。

	template<typename T> class Vector {
		public:
		  typedef VectorIterator<T, false> iterator;
		  typedef VectorIterator<T, true> const_iterator;
		  ...
	}
	
	template<typename T, bool bConst>
	struct VectorIterator : public 
	  std::iterator < std::input_iterator_tag,
	  typename std::conditional < bConst,
	  const typename IndirectHelper<T>::return_type,
	  typename IndirectHelper<T>::return_type > ::type, uoffset_t > {
	
		public:
		  VectorIterator(const uint8_t *data, uoffset_t i) :
		      data_(data + IndirectHelper<T>::element_stride * i) {};
	      ...
	};
VectorIterator和STL的iterator一样，主要是用来做单元的运算操作，可以看到其实现了一堆的运算符重载。作为只有Get方法的对象，我们主要看其Get是如何获得数据的：

	typedef typename IndirectHelper<T>::return_type return_type;
	return_type Get(uoffset_t i) const {
		assert(i < size());
		return IndirectHelper<T>::Read(Data(), i);
	}
为了能够得到一个类型的数据，这里FB实现了一个返回该数据所在的便宜以及其对应的长度的类似C中得Void*但更智能的结构：

		// 取得类似对象数组中的元素
		template<typename T> struct IndirectHelper {
		  typedef T return_type;
		  static const size_t element_stride = sizeof(T);
		  static return_type Read(const uint8_t *p, uoffset_t i) {
		    return EndianScalar((reinterpret_cast<const T *>(p))[i]);
		  }
		};
		// 取得一段存储数据指针的数组中的某个数据
		template<typename T> struct IndirectHelper<Offset<T>> {
		  typedef const T *return_type;
		  static const size_t element_stride = sizeof(uoffset_t);
		  static return_type Read(const uint8_t *p, uoffset_t i) {
		    p += i * sizeof(uoffset_t);
		    return reinterpret_cast<return_type>(p + ReadScalar<uoffset_t>(p));
		  }
		};
		// 取得一段内存中规则的偏移结构（类似数组）
		template<typename T> struct IndirectHelper<const T *> {
		  typedef const T *return_type;
		  static const size_t element_stride = sizeof(T);
		  static return_type Read(const uint8_t *p, uoffset_t i) {
		    return reinterpret_cast<const T *>(p + i * sizeof(T));
		  }
		};
		
通过上面的结构，从而使得Vector的Get操作可以从数据内存中取得对应偏移offset的值。

##四、Enum类型

对于枚举对象,FB并非有一个对应的枚举类型，而仅仅是定义了两个辅助函数。我们先来看其为IDL生成的代码：

	//IDL: enum CMD:ubyte { CMD_BLOG = 0, CMD_CATEGORY} 
	enum CMD {
	  CMD_CMD_BLOG = 0,
	  CMD_CMD_CATEGORY = 1
	};
	
	inline const char **EnumNamesCMD() {
	  static const char *names[] = { "CMD_BLOG", "CMD_CATEGORY", nullptr };
	  return names;
	}
	
	inline const char *EnumNameCMD(CMD e) { return EnumNamesCMD()[e]; }

FB会先定义一个枚举表示其真实的值，比如这里的`CMD`，然后还会为其枚举的名字定义一个用其真实值索引的字面值数组，已经一个获得其字面值的接口。这样就组成了一个完整的现代意义上的枚举值：“不关心枚举值的具体值，重要的是其字面值”，这样甚至可以用print函数打印出一个枚举值的字面值。
##五、Struct类型
由于Struct被定义为成员不可缺少的数据类型。FB为其定义了一个内部类型，同时也通过flatc生成了一个在构造函数中便将数据进行序列化的结构。

##六、Table类型

##七、Union类型