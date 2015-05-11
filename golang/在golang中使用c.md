#c cgo 

## 数据交互
go []byte 2 c xxx*

	cbuf := (*C.char)(unsafe.Pointer(&buf[0]))
	






3. 基于C语言printf的 Hello, 世界

	package main

	/*
		#include <stdio.h>

	static void myPrint(const char* msg) {
 	printf("myPrint: %s", msg);
	}
	*/
	import "C"

	func main() {
 		//C.puts(C.CString("Hello, 世界\n"))
 		//C.printf(C.CString("Hello, 世界\n")) // error
 		C.myPrint(C.CString("Hello, 世界\n"))
	}

我们通过myPrint来屏蔽printf的可变参数特性。在 import "C" 定义的函数一般建议定义为static。

4. CGO常用的函数

CGO内置了一些常用的函数：

	// Go string to C string
	// The C string is allocated in the C heap using malloc.
	// It is the caller's responsibility to arrange for it to be
	// freed, such as by calling C.free.
	func C.CString(string) *C.char

	// C string to Go string
	func C.GoString(*C.char) string

	// C string, length to Go string
	func C.GoStringN(*C.char, C.int) string

	// C pointer, length to Go []byte
	func C.GoBytes(unsafe.Pointer, C.int) []byte

我们前面的例子就是使用了 C.CString 将go的字符串转换为C语言的char*类型。
C.CString 返回的空间由C语言的malloc分配，使用完毕后需要用free释放。

5. 释放C.CString分配的空间

	package main

	/*
	#include <stdio.h>
	#include <stdlib.h>
	*/
	import "C"
	import "unsafe"

	func main() {
 		cStr := C.CString("Hello, 世界\n")
 		defer C.free(unsafe.Pointer(cStr))
 		C.puts(C.CString("Hello, 世界\n"))
	}

C.CString返回的是C语言的char*类型，对应go语言的*C.char。 C语言的free参数是void*类型，
对应go语言的unsafe.Pointer。由于go语言禁止2种不同类型的隐式转换，因此用C.free时需要手工转换
类型，对应代码 unsafe.Pointer(cStr)。这样cStr的空间就不会出现内存泄露了。

另外，使用CGO时，一般都会导入"unsafe"包。"unsafe"中提供了一些类似C语言中的底层工具：

	func Alignof(v ArbitraryType) uintptr
	func Offsetof(v ArbitraryType) uintptr
	func Sizeof(v ArbitraryType) uintptr
	type ArbitraryType
	type Pointer

6. 常见的C/go类型转换

使用CGO时，c和go之间的基本数据类型转换是经常遇到的一个问题。

整数/浮点数 转换:

	// c -> go
	i_go = int(C.i_c)
	f32_fo = float32(C.float_c)
	f64_fo = float64(C.double_c)

	// go -> c
	i_c = C.int(i_go)
	float_c = C.float(f32_go)
	double_c = C.double(f64_go)

字符串转换：

	// c -> go
	str_go = C.GoString(C.str_c)

	// go -> c
	str_c = C.CString(str_go)

指针转换：
	// c -> go
	p_int_go = (*int)(unsafe.Pointer(C.p_int))
	// go -> c
	p_int_c = (*C.int)(unsafe.Pointer(&myIntSlice[0]))

比如要调用C语言的main函数(代码不能运行，只是为了说明字符串数组转换)：

	func CallMain(args []string) int {
 		argc := C.int(len(args))
 		argv := make([]*C.char, len(args))
 		for i := 0; i < len(args); i++ {
  			argv[i] = C.CString(args[i])
 		}
		rv := C.main(argc, (**C.char)(unsafe.Pointer(&argv)))
 		return int(rv)
	}

如果是回调函数，需要在C中作一层封装(相对比较麻烦)。

7. 连接选项

可以使用#cgo扩展预处理命令指定CFLAGS/LDFLAGS。

比如go-gdal库的连接参数为：
	/*
	#include "go_gdal.h"

	#cgo linux  pkg-config: gdal
	#cgo darwin pkg-config: gdal
	#cgo windows LDFLAGS: -lgdal.dll
	*/
	import "C"

\#cgo之后可以跟系统命令，指定参数对应生效的系统。对于Linux等系统，可以直接使用pkg-config。