#用Cocoapods管理包依赖
在安装Linux软件时，我们是不是经常会遇到这样的问题：好不容下载了automake的源码包，结果./configure 时候提示先装autoconf，然后下载了个autoconf的源码，安装好后
发现automake的configure提示说autoconf的版本不对。

这一百个闹心的事，在后来的90后世界时很少出现了，因为现在的在Linux发行版引入了包管理系统来解决这个问题。目前有两大系列（当然还有其他系列），一个是Redhat主导的yum
命令的rmp软件包系列（Fedora/Redhat/CentOS），另一个是Debine引入的apt-xxx系列的deb包(Debine/Ubuntu)。这些包管理系统做的事情是主要为了解决软件安装过程的
依赖关系。比如安装A的1.9.1版本，需要先安装B的1.3.1以上版本，以及C的1.4.2以上版本。

同样的事情还会出现在我们引用第三方SDK库的时候，比如在Github上看到一个非常好用的X语言的Json库，然后下载到本地，集成到项目中。某天，发现这个Json库有个bug，同时发现
其在一个较新的版本中被修复了，那么这个时候，又要去Github上，吧代码down下来，然后再合入我们的项目中。如果项目结果组织的清晰（比如有目录名标示），替换过程还算好。否则
就是一百个痛快。在C/C++的世界里面，其实主要就是这么来引用的第三方库的：
> 1.若要使用第三方库，需要手动去找资源下载
> 
> 2.若要更新库，就必须重新下载合入

在开源如火如荼、Github成为程序员Blog的今天，这样的问题更容易出现。因此现代化的语言要么通过工具来解决这样的问题。如Python的easy_install
,Java世界里面的Marven,Node.js（非新语言）的npm.要么在语言的层面便提供了支持,如Golang的 "go get"

在Mac的世界里面，CocoaPods就承担了此重任，其支持Objective-C以及Swift。

## 一、安装Cocoapods
Cocoapods是用Ruby写的，Mac下一般Ruby环境以及默认安装好了，如果没有则需要用brew或者手动安装下ruby的环境，这里不做介绍。打开终端，输入命令：

	sudo gem install cocoapods
	
即可。由于ruby镜像被ZF的大墙挡住，因此可以选择配置国内的Ruby镜像，比如配置TaoBao的镜像(注意以前的http（http://ruby.taobao.org/非https已经停用了，现在都是https）：

	$ gem sources --remove https://rubygems.org/
	
	$ gem sources -a https://ruby.taobao.org/

安装好了以后，我们可以运行：
	
	pod --version 

来查看Cocoapods的版本，从而确认完成安装。至此就完成了对Cocoapods的安装了，是不是太简单？
	
## 二、安装第三方库
CocoaPods(下文中CocoaPods表示CocoaPods工具，而cocoapods表示示例的工程名)通过使用一个配置文件来管理工程中依赖的第三方库文件。在XCode工程的工程目录下，也就是xxx.xcodeproj 的同级目录创建一个Podfile文件。Cocoapods官方文档是用
touch命令生成 `touch Podfile`。这里我们以最常用到的AFNetworking库为例，创建一个Podfile文件，然后写上内容：

	// 这里假设工程名叫做Cocoapods
	target 'cocoapods' do
	  pod 'AFNetworking', '~> 3.0'
	  pod 'FBSDKCoreKit', '~> 4.9'
	end
	
表示选择AFNetworking3.0的版本前最近的版本，而不是2.0老版本。此时目录结构如下：

	// 这里假设工程名叫做cocoapods
	Podfile			cocoapods.xcodeproj
	cocoapods		cocoapodsTests
	
然后再Podfile同级目录下运行:

	pod install 
	
	// 提示：
	czs-iMac:cocopods apollo$ pod install
	Re-creating CocoaPods due to major version update.
	Analyzing dependencies
	Downloading dependencies
	Installing AFNetworking (3.1.0)
	Installing Bolts (1.7.0)
	Installing FBSDKCoreKit (4.11.0)
	Generating Pods project
	Integrating client project
	Sending stats
	Pod installation complete! There are 2 dependencies from the Podfile and 3 total pods installed.


说明此时已经安装好AFNetworking 3.1.0以及FBSDKCoreKit4.11.0版本的库。

这个时候仔细看上面提示“There are 2 dependencies from the Podfile and 3 total pods”会发现我们虽然只指定了两个库，但是CocoaPods非常智能的帮我们推导出FBSDKCoreKit依赖Bolts并自动帮我们下载并安装上。这个就是CocoaPods这类包管理系统最强大的地方了。

此时我们再看目录结构为：

	Podfile			Pods			cocoapods.xcodeproj  cocoapodsTests
	Podfile.lock		cocoapods		cocoapods.xcworkspace
	

	
这里我们发现多了3个文件：

	Podfile.lock
	Pods
	cocoapods.xcworkspace

Podfile.lock 记录了一些Meta信息，如cocoapods的版本、依赖库的版本等，可以认为是类似依赖信息的数据库文件。Pods目录里面存放了依赖库的库文件，如这里的AFnetworking/FBSDKCoreKit。
cocoapods.xcworkspace是一个类似XCode工程文件Cocoapods.xcodeproj文件的工程文件。

使用了cocoapods以后，就可以忽略cocoapods.xcodeproj了，并且不能用改文件打开工程，要使用cocoapods生成的这个xcworkspace。这里可以直接用XCode打开：

![xcworkspace](http://images.libcz.com:8000/images/blog/iOS/packagemgr/cocoapods/images/xcworkspace.png)

此时，直接“Command+B”就可以直接编译工程。和一个普通的XCode工程是一样的。

看左边的工程目录结果，发现比普通的工程多了一个Pod工程依赖。原来的工程中多了一个“Pods”和“Frameworks”的Group。这两个Group主要就是配置文件和库的依赖。其他的Group
还是和一个普通的XCode工程一样的。在使用时，我们可以忽略这些新增的目录、工程已经Group。添加文件、设置工程就在原来的XCode工程上按一般的规则设置即可。

在Pods工程中，我们可以找到Pods的Group下有AFNetworking，所有第三方的framework都会在这个Group中。这里可以看到头文件和.m等其他文件，需要时可以过来进行查看。在工程中就可以直接引用AFNetworking库的API了。


## 三、Repo的Hint

在上面使用CocoaPods的过程中，使用pod工具生成了三个文件夹，那么在我们的Repo中，该如何对待这些文件呢？其实对于XCode工程，最好是在创建工程的那一刻就创建好.gitignore
文件，因为XCode会自己进行Add操作，当然这个是没有使用XCode的代码管理工具的情况下。在.gitigore中，我们把和Cocoapods相关的四个文件中仅“Podfile”放入git托管，二把其他三个生成的文件均写入.gitignore里面。这样多人之间仅共享配置文件，通过pod进行实时生成。

## 四、Podfile自定义

### 指定库的名称和版本
在上面的Podfile文件中，首先指定了一个Xcode工程的Targe然后写上需要依赖的库文件：

	target 'cocoapods' do
	  pod 'AFNetworking', '~> 3.0'
	  pod 'FBSDKCoreKit', '~> 4.9'
	end
	
Podfile是基于Ruby的，就如同Scons使用Python，Gradle使用Groovy一样，内容使用Ruby的语法。上面这个语句指定了依赖的库以及对应的版本。用pod关键字，加上单引号括上的库的名字和版本信息，中间用逗号分隔,版本信息规则如下：

版本号表示 | 版本
---|---
> 0.1 | 大于0.1的版本
>= 0.1| 大于等于0.1 的版本
< 0.1 | 小于0.1的版本
<= 0.1| 小于等于0.1 的版本
~> 0.1.2 | 0.1.2(含)到0.2(不含)之间的版本，也就是 >=0.1.2 && <0.2.0
~>0.1 | 同上 >= 0.1 && <1.0

除了用版本号表示CocoaPods收录的库外，还可以指定Github上的库：

	pod 'AFNetworking', :git => 'https://github.com/gowalla/AFNetworking.git'
	pod 'AFNetworking', :git => 'https://github.com/gowalla/AFNetworking.git', :branch => 'dev'
	pod 'AFNetworking', :git => 'https://github.com/gowalla/AFNetworking.git', :tag => '0.7.0'
	pod 'AFNetworking', :git => 'https://github.com/gowalla/AFNetworking.git', :commit => '082f8319af'
	
上面几条分别表示：
* 使用trunck上的版本
* 使用分支dev上的版本
* 使用tag号版本
* 使用commit号版本

### 自定义Target
Podfile通过Target
来组织依赖关系，Target就是我们普通XCode工程中的Target，每个Target产出一个Prouduct，因此只要设置好这个Target依赖的库文件，也就达到目的了。

![target](http://images.libcz.com:8000/images/blog/iOS/packagemgr/cocoapods/images/target.png)


每个Podfile有一个默认的Target,Cocoapods选择Podfile同级目录下的xcodeproj文件为默认工程，这也是上面为什么说要吧Podfile放在xcodeproj文件同级目录的原因。因此原来XCode工程文件中的第一个Target。所以上面的那一句话，其实是为我们的默认Target定义了一条依赖AFNetworking的规则。

*注意，在1.0版本以前的CocoaPods支持不写Target的默认目标，在1.0之后就不可以了*

target的定义符合Ruby的语法，用end结束：

	target :'cocopods' do
	  pod 'OCMock', '~> 2.0.1'
	end

这样就定义了一个test的target依赖OCMock。

这里xcodeproj是根据默认规则的，也可以不将Profile文件放在其同级目录下，此时需要指定xcodeproj的位置：

	xcodeproj './YourProj/cocopods.xcodeproj'

	target :'cocopods' do
	  pod 'OCMock', '~> 2.0.1'
	end

对于每个依赖的库（比如这里的OCMock），还可以指定其编译时的sdk，如：

	xcodeproj './YourProj/cocopods.xcodeproj'

	target :'cocopods' do
		platform :ios, '7.0'   
	  	pod 'OCMock', '~> 2.0.1'
	  	
	  	platform :ios, '7.0'
	  	pod 'AFNetworking', '~> 0.2'
	end
	
指定了OCMock和AFNetworking编译的使用用的SDK。

### Bring it to all

了解了这几条规则，就够我们去定义自己工程中的依赖关系了。Podfile还提供了一些其他特性，比如“link_with”,"user_frameworkds"等，可以参考[官方文档](https://guides.cocoapods.org/syntax/podfile.html#podfile)


















































































