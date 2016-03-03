#golang提供的List

作为现代10后语言的golang(12年正式发布)。Golang的标准库提供了高级的数据结构List。具体在包`container/list`。该包里主要有两个数据结构组成：“Element”、“List”。其中“Element”相当于CPP里面的"iterator",其有Prev和Next方法用于得到前一个或者下一个迭代器，迭代器的间接引用直接使用其成员Value。

##1 创建一个List对象来感受一下

	l := list.New()
	l.PushBack("one")
	l.PushBack(2)
	
	fmt.Println(l)
	
上面的代码可以得到如下的输出：

	&{{0x2081a21b0 0x2081a21e0 <nil> ?reflect.Value?} 2}

这里具体的0x数据可能会变动，其实际记录的是对象的地址，但是最后的“2”不会变动，其表示当前的list对象里面有两个元素。

这里我们通过使用 `list.New()` 创建一个list对象，然后调用该对象的`PushBack（）`方法向list对象中插入一个元素。这里我们发现神奇的一个现象：在CPP里面，list的成员的必须是同一个类型的，但是我们的Golang却允许list中插入任意类型的成员。这个很容易让我们想到了python的特性。这里我们可以通过源码了解到Element中其实存储的是一个 `interface{}` 成员，从而支持任意成员的特性：

	type Element struct {

   	// The value stored with this element.
   	Value interface{}
   	// contains filtered or unexported fields
	}

##2.遍历list

上面的例子，仅仅用fmt.Println看到了list得简单的信息，那么若要遍历整个list怎么操作呢？来看代码：

	l := list.New()
	l.PushBack("one")
	l.PushBack(2)
	l.PushBack("three")

	for iter := l.Front();iter != nil ;iter = iter.Next() {
		fmt.Println("item:",iter.Value)
	}

运行代码，我们可以看到结果：

	item: one
	item: 2
	item: three	

这里，我们定义了一个迭代器变量iter，其为Element类型，通过调用list的 `Front()`函数，可以得到list的第一个对象，若list为空，则得到nil。同样的通过调用调用list的`Back()`可以得到最后一个对象的迭代器。在for语句中，我们用list的`Next()`方法得到当前迭代器的下一个元素的迭代器，若没有元素了，则返回nil。因此我们用 `iter !=nil`作为循环结束条件。上面说了。通过引用迭代器的`Value`成员，可以实现对其内存储元素的间接应用。

除了可以通过上面的函数得到单个元素外，我们还可以通过list的`Len()`函数获得其内元素的个数。美中不足的是Golang的List没有提供python中得通过索引引用元素的功能，也没有`index`或者`at`类似的接口

##3.修改list的成员
在上面的例子中，我们已经演示了怎么向list中添加元素。`PushBack()`会将新元素添加到list的尾部。除此之外，还有`PushFront()`可以将元素插入到list得首部。`InsertAfter()`能将元素插入到list中指定元素的后面,`InsertBefor`能将元素插入到list中指定的元素的前面。

插入后如何删除元素呢？通过list的`Remove()`函数可以删除指定的元素。与Insert对应的`MoveAfter()`、`MoveBefore()`，可以list中指定元素的后面或者前面的元素。

我们来看一个实例。用这几个接口组合成一个Queue的实例：

	type Queue struct {
		data *list.List
	}

	func NewQueue() *Queue {
		q := new(Queue)
		q.data = list.New()
		return q
	}

	func (q *Queue)Enqueue(v interface{}) {
		q.data.PushBack(v)
	}

	func (q *Queue)Dequeue() interface{} {
		iter := q.data.Front()
		v := iter.Value
		q.data.Remove(iter)
		return v
	}

	func (q *Queue) Dump(){
		for iter:=q.data.Front();iter!=nil;iter=iter.Next() {
			fmt.Println("item:",iter.Value)
		}
	}

	func main(){
		q := NewQueue()
		q.Enqueue("one")
		q.Enqueue("two")
		q.Dump()
		v := q.Dequeue()

		fmt.Println("v:",v)
		q.Dump()

	}
	
我们可以看到结果为：

	item: one
	item: two
	v: one
	item: two
	
最后。如果我们想清空list。可以调用其`Init()` 接口。