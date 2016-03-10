title: Golang实现命令行菜单CLI效果
tags: [golang, cli] 
category: golang
date: 2015-03-05
---
在Unix-Like系统中，CLI(Command Line Interface)通常都是通过传统的getopt来实现的，在Python中除了getopt外还有更高级的optparse以及argparse。在Golang中，系统库flag为我们提供了CLI的支持，当然还有一些更高级的封装实现，如[codegangsta/cli](https://github.com/codegangsta/cli),[docker增强的flag](https://github.com/docker/docker/tree/master/pkg/mflag)。但是对于平民百姓的一般使用，用官方的flag库即可。

<!-- more -->


##初试
使用Flat模块，通过几行代码就可以构建一个丰富的CLI界面了：

	package main
	
	import (
		"flag"
		"fmt"
	)
	
	func main() {

		flag.Usage = func() {
			fmt.Println("Usage:Test Flag Module")
			flag.PrintDefaults()
		}

		var logSwitch bool
		var outputPath string
	
		flag.BoolVar(&logSwitch, "l", false, "    Logcat switch ")
		flag.StringVar(&outputPath, "out","./output","     Path to output")
		var v = flag.Bool( "v", true, "    Show Version")
		
		flag.Parse()
		
		fmt.Println("v is ",*v)
		for i,_  := range flag.Args() {
			fmt.Println("the ",i," th arg is:",flag.Arg(i))
		}

	}
	
执行 `go build` 并运行程序后，可以尝试几个选项，比如：
	
	./test_flag -h
	Usage:Test Flag Module
 		-l=false: Logcat switch
 		-out="./output": Path to output
	  -v=true: Show Version
	  
这里可以使用
* 带有选项和值的参数，如： `./test_flag -l false` 
* 带有两个横杠的，如： `./test_flag --out ./output_path`
* 单个参数的选项，如：`./test_flag -v`
* 带有多个参数，如：`./test_flag one two`


在上面的例子中，通过调用`flag.Parse()`对选项进行了解析，从而可以获得选项字段。而选项字段内容的获取则通过
`Type[Var]()`的接口获得，其中参数忽略第一个分别是

* 命令行上给到的名称
* 默认值
* help提示信息

主要提供了Bool,Duration,Float64,Int,UInt,Int64,UInt64,String几种类型数据的获得，每个类型有一个带有Var后缀的版本，该版本会再前面多
增加一个参数，为对应类型的指针，用来存储获得的值，而不带的版本则是返回一个该类型的指针，从而获得对应选项的值。如：

	func Int(name string, value int, usage string) *int
	func IntVar(p *int, name string, value int, usage string)
分别是通过返回值和指定变量指针的方式。

在写Python的命令行时，有时候为了兼容多个Python版本，通常选择最裸的argv的方式，这样通常都免不了对参数进行转换的操作，如:
	
	try:
		count = int(sys.argv[1])
	except:
		echo_helper()

而上面的这些带有类型的接口就已经完成了这样的操作，比如传入一个浮点数给到一个Int[Var]()的选项，将会自动打印出Help信息并进行退出动作。

上面我们看到通过为` flag.Usage` 进行赋值，可以实现自定义的help输出。如果使用了上面的demo可能会觉得奇怪，为什么没有对各个选项写help信息
为什么默认的help会打印出对应的信息。这个神奇的语法就得依赖于 `flag.PrintDefaults()`，他会把其他选项中的help一并打印出来。
另外在写单个项的help的时候，字符串最好tab一个键开头，这样`flag.PrintDefaults()`在合成help信息的时候，排版起来相对好看。

除了选项外，还可以获取没有选项带的参数值，根据上面的经验，这些值也是需要Parse之后才能得到，因此对其的遍历放在了Parse操作之后，否则
取出来的都是空。

上面的这个Demo基本可以作为一个模板，稍加修改便可以满足一个简单的CLI的需求。下面对Unix-Like命令中几种常见选项做一个实现。




##-v/--verion

对于单个选项的开关，需要将该选项定义为bool类型，并默认给一个false的值。这样可以实现当有该选项时，会被设置为true，否则任为false。

	var v = flag.Bool( "v", false, "    Show Version")

	flag.Parse()
	fmt.Println("v is ",*v)
	
这样在没有加 "-v"的时候得到的结果为false,加了的话，得到的是true。

flag比较讨厌的是，对于长短选项没有做特殊的合并方法。感觉只能二者选其一了。


##-o a.out

如果想获取一个带有参数的选项的值，可以选择的使用上面的Type[Var]()系列的函数了，这里以String举例：

	var outputName string
	var outputDir = flag.String("o","","    output directory")
	flag.StringVar(&outputName,"n","", "    output name")
	flag.Parse()
	fmt.Println("Output directory is ",*outputDir," And name is ",outputName)
	
这里通过带有Var和不带的接口实现了获取输出目录和文件名的操作。

##mkdir tmp	
如果不想使用选项，而直接带上参数，flag也是支持的，可以通过flag.Args()获得一个sting的list，或者通过
flag.Arg(index int)获得第几个参数。但是这里受限的时，参数只能获得string类型，具体需要自己转换一下，就和Python里面
使用getopt一样。  
  	flag.Parse()

	if len(flag.Args())  !=2 {
		flag.Usage()
		return
	}

	argName := flag.Arg(0)
	argAge := flag.Arg(1)
	age,err := strconv.Atoi(argAge)
	if err != nil {
		flag.Usage()
		return
	}

	fmt.Printf("Name is %s,Age is %d\n",argName,age)
	
	
这里先对参数个数进行判断，然后再用strconv来实现对字符串的转换操作。如果转换不成功则退出。

##Help

上面已经对Help进行了比较详尽的说明了，总结就是在适当的时候会调用flag.Usage。其是一个无参数不返回值的函数，相当于
C里面的`void (* func)()`。其配合一个助手`flag.PrintDefaults()`可以将选项中得help信息也打印出来。基本就是一个
范式，每次这么写就对了：

	flag.Usage = func() {
		fmt.Println("Usage:Test Flag Module")
		flag.PrintDefaults()
	}