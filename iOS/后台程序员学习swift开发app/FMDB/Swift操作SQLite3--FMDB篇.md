#Swift操作SQLite3--FMDB篇
在做App的时候，需要将一些结构化的数据进行存储和查询，此时后台程序猿立马就想到了MySQL解决方案，但是iOS/Android上是肯定没有MySQL,但是作为替代，我们可以使用SQLite,在Android上，Android提供了一套系统API来操作SQLite，而在iOS上，系统提供了SQLite的替代产品：CoreData接口。但是后台程序猿还是对SQL熟悉。iOS提供了sqlite3.dylib已经头文件来使用SQLite原始的C API。

在Swift中，我们可以自行添加一个Bridge文件来将系统提供的C接口导出到Swift中使用，这是一种方法。但是使用过SQLite3的C接口的都知道，其繁琐无比（MySQL的C接口也没好哪去）。因此有哥们就用Swift包装了一套接口,如Stephen Celies 的[SQLite.swift](https://github.com/stephencelis/SQLite.swift)，采用纯Swift实现，并且接口较为友好。除此之外，还有一个OC界非常出名的SQLite3的封装，其知名度差不多都是iOS开发使用SQLite3的标准库级别了。最近其也抛出了Swift接口。为了能和OC接轨，这里我们用FMDB来看如何用Swift操作SQLite 数据。

## 一、集成FMDB
FMDB已经是一个被大家广泛使用的库了，因此比较成熟，并且对CocoaPods支持完美。这里无需手动去下载再集合到自己的项目中，只要在Podfile中添加

	pod 'FMDB'
	
即可使用最新版本的FMDB。关于CocoaPods的使用，可以参考之前的文章[用Cocopods管理包依赖]()。然后执行 `pod install/update` 接着打开xcworkspace即可在Pods工程的Pods Group中看到FMDB了。

FMDB官方Readme中介绍的集成Swift过于繁琐，其实只要这里的Podfile方法即可，在用CocoaPods按照好FMDB后，为工程添加一个Bridging文件（或者在已有的Bridging文件中）中添加 

	#import "FMDB.h"
	
Bridging的生成规则是“ProjName-Briding-Header.h”，具体可以参加Developer上的[Swift and Objective-C in the Same Project](https://developer.apple.com/library/prerelease/ios/documentation/Swift/Conceptual/BuildingCocoaApps/MixandMatch.html#//apple_ref/doc/uid/TP40014216-CH10-ID122)。

这样操作之后，就可以在swift文件中引用FMDB的接口了。这里不再需要import什么framework，因为Bridging本身是Module可见的，也就是本App中可见。

## 二、FMDB接口介绍
FMDB的接口中有五个类和两个Category：

* FMDatabase
* FMDatabasePool
* FMDatabaseQueue
* FMResultSet
* FMStatement

* FMDatabase(FMDatabaseAdditions)
* NSObject(FMDatabasePoolDelegate)

实际使用中主要使用两个类：

* FMDatabase 数据库对象，可以认为这个就是一个SQLite3的DB文件，或者一个操作的句柄
* FMResultSet 数据库查询的结果

另一个可能被用到的FMDatabaseQueue是在多线程的情况下代替非线程安全的FMDatabase来使用，不过通过上面两个类，就可以实现基本的CURD操作了。

使用FMDB接口，首先提供一个路径从而创建一个FMDatabase数据库对象，数据的路径可以参照之前的文章[访问沙箱DataContainer中的文件]()放到Document目录下：
	
	let dbPath = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory,NSSearchPathDomainMask.UserDomainMask, true)[0] as! String + String("/sqlite3.db")
	let db = FMDatabase(path: dbPath)
	if db == nil {
	    print("Create DB Error!")
	    return
	}
	 
然后调用该对象的open方法进行相关初始化：

	let rst = db.open()
	if !rst {
	    print("Open DB Error!")
	    return 
	}
该函数返回一个Bool值，成功时为true，失败时为false。

在这之后就可以对数据库进行操作了。FMDB将数据库操作抽象成两种类型，一种是更新（Update)另一种是查询（Query）。对应的接口分别是`executeUpdate`和 `executeQuery`。分类规则是： 所有非SQL的`SELECT`都是Update操作，比如`CREATE` `UPDATE` `INSERT` `ALTER` `COMMIT` `BEGIN` `DETACH` `DELETE` `DROP` `END` `EXPLAIN` `VACUUM` `REPLACE`都是Update操作。

其中`executeUpdate`返回结果是Bool类型，成功时返回true，失败时返回false。 `executeQuery`返回FMResultSet对象来保存查询的结果。FMResultSet有一个`next()`方法，每次调用完`next()`方法后，可以调用改对象的“{type}ForColumn/ColumnIndex”来获得该条记录上对应Field的值：

	intForColumn:
	intForColumnIndex:
	longForColumn:
	longForColumnIndex:
	longLongIntForColumn:
	longLongIntForColumnIndex:
	boolForColumn:
	boolForColumnIndex:
	doubleForColumn:
	doubleForColumnIndex:
	stringForColumn:
	stringForColumnIndex:
	dateForColumn:
	dateForColumnIndex:
	dataForColumn:
	dataForColumnIndex:
	dataNoCopyForColumn:
	dataNoCopyForColumnIndex:
	UTF8StringForColumnName:
	UTF8StringForColumnNameIndex:
	objectForColumnName:
	objectForColumnNameIndex:
	
通过这些函数可以获得每条记录上的值。

除了执行查询和更新，对于创建数据库，创建表删除表等操作，还可以使用`executeStatements`来执行SQL语句，改函数还有一个带有回调版本，但是不是很Swiftic,可以进行包装下通过Trailing Closure来实现命令执行后的操作：

	executeStatements(sql: String!)
	executeStatements(sql: String!, withResultBlock: FMDBExecuteStatementsCallbackBlock! ([NSObject : AnyObject]!) -> Int32)

	
	
当操作完数据后，调用数据库对象的`close()`方法进行关闭。

## 三、CRUD
##创建表（Create）
创建表适用`db.executeStatements`函数来执行SQL语句：

	let sqlCMD = "CREATE TABLE IF NOT EXISTS CONTACTS (ID INTEGER PRIMARY KEY AUTOINCREMENT, NAME TEXT)"
	rst = db.executeStatements(sqlCMD)
	if !rst {
	    print("Create Table Error")
	    return
	}
	
也可以用	executeUpdate 来实现：

	let sqlCMD = "CREATE TABLE IF NOT EXISTS CONTACTS (ID INTEGER PRIMARY KEY AUTOINCREMENT, NAME TEXT)"
	rst = db.executeUpdate(sqlCMD, withArgumentsInArray: nil)
	if !rst {
	    print("Create Table Error")
	    return
	}
	
很直观的通过SQL语句创建一个数据表。

##读取记录（Read）

## 更新记录 （Update）

## 删除记录（Delete）


