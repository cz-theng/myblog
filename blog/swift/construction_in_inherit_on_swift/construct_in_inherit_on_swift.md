title: Swift语法：继承中的构造函数
tags: swift 
category: swift
date: 2015-04-04
---

Swift要求在构造函数中要完成对所有“Stored”属性的初始化操作。因此在继承时，也要保证这一要求。
##一、Sotred Properties  
什么是"Sotred Properties"?苦逼程序员在大一或者大n得时候学习C++或者Java时，不是只有“属性”？咋来了个“Stored”?

> 在Swift里面，类的属性分成两种，一种叫做“Sotred Properties”，另一种叫做“Computed Properties”

简单来说，“Stored Properties”就是大学里学C++、Java里面的属性。凡是可以存一个值的就叫她“stored”，那什么是“Computed”呢？苦逼程序员一般都听说过C#还有OC（Objective-C）,这两个语言中都有个get和set的语法糖，比如在OC中声明为"@property a"的成员，其实他有个类似这里“Stored”属性的“_a”成员，然后当使用“.a”访问时，其实类似于C++/Java里面的getA方法。在这个get方法中可以添加计算逻辑，比如double一下。是计算过之后的值，因此管他们叫做“Computed”
<!-- more -->
在Swift里面，前者的定义和一般语言中得属性定义没有什么差别，后者则是在变量后面用一个大括号包裹着一个get/set方法：


	class People {
		var name: String
		var _age: Int
		var age : Int {
			set(age) {
				if (age >0) {
					_age = age
				}
			}
			
			get() {
				return _age
			}
		}
	}
	
上述代码中`name`是一个“Stored”属性，而`age`则是一个“Computed”属性
## 二、Designated Initializers
这个名字这么高大上，也不容易理解，其实就是一个意思:“通过自己或者父类的构造函数完成对所有Stored属性的初始化的构造函数”

就是要再构造函数里面将自己的成员都做初始化操作。这里要注意了，必须先初始化自己的然后才能用 `super.init(xxx)` 来调用父类的构造函数。而不同于我们在C++或者Java中优先初始化父类。

## 三、Convenience Initializers
有了上面的构造函数，为什么还有另一种分类呢？答案从名字中也可以看出来，就是要提供一个友好的构造接口，我们可以认为他是一系列的helper函数构造函数。按照Swift的说法，我们尽量减少 Designated的构造函数，而用Convenience构造函数提供接口。这里我们可以想象一下在Objective-C中，一个类通常有一个init()函数，然后还有一系列的init:withXXX的函数，前者可以认为是Designated的后者可以认为是Convenience的。

## 四、Initial Rules
了解了构造函数的分类，我们再来看下构造时的规则，这也是这篇文章的意义所在。


* 一个Designated构造必须要调用一个其父类的Designated构造函数，没有父类的除外
* 一个Convenience构造函数必须调用该类的一个构造函数，可以是Designated也可以是另一个Convenience的构造函数
* 一个Convenience的调用路径上，最终必须调用一个Designated构造函数

![init_chain](http://images.libcz.com:8000/images/blog/swift/construction_in_inherit_on_swift/init_chain.png)

如上图所示，最下面的子类的两个Designated的构造函数都调用了父类的Designated构造函数，而其Convenience构造函数则通过调用其Designated进行初始化，最上面的父类的第二个Convenience构造函数调用其第一个Convenience，最终还是调用了其Designated构造函数。

这样的规则是的Swift同OC以及Cocos2dx遵循同样的“两段式构造”规则。首先在构造函数里面保证所有的Sotred的属性都被初始化了，这里的初始化主要是默认初始化。然后进行第二步，用户再对这些值作自定义修改，从而对外表现为特定初始化。

为了满足这样的规则，我们在写构造函数就要注意了

* Designated构造函数必须先初始化好子类中所有的Stored的属性，才能调用父类的Designatede构造函数
* Designated构造函数如果要修改继承父类中得属性的值，必须在调用了父类的Designated构造函数之后，否则回报父类覆盖
* 一个Convenience构造函数如果想修改属性的默认值，必须在调用了Designated构造函数之后，否则会被Designed构造函数覆盖
* 在完成对所有Stored属性的初始化之前，是不能引用实例方法和属性的，比如用self.x访问一个属性来初始化另一个属性。

这里我们看一个表示两段构造的例子：
![two_step_init_one](http://images.libcz.com:8000/images/blog/swift/construction_in_inherit_on_swift/two_step_init_one.png)
首先子类从Convenience构造函数开始，先调用其Designated构造函数，在这初始化子类里面的Stored属性，然后调用父类的Designated构造函数，初始化好父类的Stored属性。这样完成第一步，此后才可以访问实例的属性。
![two_step_init_two](http://images.libcz.com:8000/images/blog/swift/construction_in_inherit_on_swift/two_step_init_two.png)
进入到第二阶段，从父类开始，执行用户的代码对初始化后的属性作修改，然后再到子类里面再做修改，这里可以修改继承的父类的属性，最后到Convenience构造函数里面可以访问实例的属性方式进行再自定义修改，比如将UIView的一个子类里面的某个属性设置为self.bouds大小。




##五、继承和重写构造函数

在Swift中，默认情况下，子类是不继承父类的构造函数的，需要子类自己选择是否调用父类的构造函数。调用父类的构造方法通过`super`来指定父类如`super.init()`


与C++和Java不同，在Swift中子如果要重写父类的Designated构造函数，需要在函数前面添加overide关键字,而与父类的Convenience构造函数同名时则不用写overide。

另外，有两个极端情况：

* 如果子类不提供Designated构造函数，那么默认继承了所有的父类的Designated构造函数
* 如果子类overide了父类的所有Designated构造函数，那么子类默认继承了父类的所有Convenience构造函数


