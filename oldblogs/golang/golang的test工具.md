#golang的test工具
Golang自身携带了一个test工具，其有两大功能：单元测试和性能测试。通过使用星河测试和gprof的结合可以很好的找出当前golang程序的性能消耗。	


##一、使用
当使用golang的工具 `go test` 时，会将该目录下以 `_test.go` 结尾的文件进行重新编译（以`_`或者`.`开头的文件除外，如“_test.go”、".test.go"），并作为一个单独测试程序执行。
 
 `go test` 有如下命令选项：
 
 * -c
 * -i
 * -exec xprog
 
 
 
##二、go help testfunc
 
##三、go help testflag
 
##四、testing package


##examples
###1. 写个正常的程序，配个test文件。然后测试嘴基本的使用

第一步先不管性能测试。先看Test 和 Example