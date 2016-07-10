# Realm的CRUD
Realm标榜其为专注于移动平台的数据库，那既然是数据库，我们当然要看最基本的CRUD(Create/Read/Update/Delete)操作。当然在做这些基本的操作之前还是需要学习下Realm的基本知识。

## 0. Realm与我们熟悉的SQL
当使用SQL（SQLite）时，首先我们会设计关系数据库的结构，比如设计几个表，每个表里面哪些是主键、对哪些键做索引、默认值是什么等等，并将这些用SQL表示好，然后调用函数执行创建表的SQL语句或者通过一些ORM工具如：FMDB的函数创建表格，然后还要对应的创建一个class/struct来表示这个数据结构。而Realm抛弃了这繁琐的中间语言，而采用目标语言（比如Objective-C/Swift/Java）本身作为DSL(domain-specific language)来描述同样的类似表格的数据结构，由于是目标语言，其自身就能表达一个数据结构，因此带有了一些Model层属性，比如SQL很难描述某列的属性是另一个结构，需要自己定义数据结构来表示，而Realm的DSL则自动包含了这层定义。

比如我们来看个例子，描述省与城市的天气：省有其天气属性，同时还有其包含的城市；而城市也有天气属性。用SQL的话，我们可能会设计如下三个表：

	// table t_provience
	CREATE TABLE t_provience (
		f_provience_id int, 
		f_proviecne_name varchar(255), 
		f_weather varchar(255)
		PRIMARY KEY (f_provience_id)
	)

	// table f_city
	CREATE TABLE t_city (
		f_city_id int, 
		f_city_name varchar(255), 
		f_city varchar(255)
		PRIMARY KEY (f_city)
	)
	
	// relationship of city and provience
	CREATE TABLE t_provience_city (
		f_provience_id int, 
		f_city_id int, 
		PRIMARY KEY (f_provience_id)
	)
表t_provience表示省份信息，表f_city表示城市信息，这里为了凸显要表示的二者之间的关系，用了一个表t_provience_city来表示一个省有几个城市。然后在程序中可能还要定义两个结构Provience和City。

那同样的意思如何用Realm来表示呢？
## 1. 学生信息管理Demo

## 2. Create

## 3. Read

## 4. Update

## 5. Delete

## 6. 总结

## 参考
1. [Realm Objective-C](https://realm.io/docs/objc/latest/)
2. [Realm Reference](https://realm.io/docs/objc/latest/api/)