#通过ReplayKit在触手、映客、企鹅电竞上直播游戏界面

在去年（2015）的WWDC Apple分享了主题[《Going Social with ReplayKit and Game Center》](https://developer.apple.com/videos/play/wwdc2015/605/)。该Session展示了Apple在iOS9上面引入了一个全新的framework来提供录屏功能，这样游戏用户就可以通过这个功能将自己玩的内容进行录制并分享了，但是实际使用起来，这个工具却有诸多弊端，比如内容要自己编辑、需要自己保存等。发布一年多来，使用的人甚少，至少在腾讯、网易这些手游大拿的游戏上面都没有看到该录制功能。

所以在今年（2016）的WWDC上面，Apple又展开了一个新的Session [《Go Live with ReplayKit》](https://developer.apple.com/videos/play/wwdc2016/601/),扩展了ReplayKit使其支持录屏直播的功能。简单描述就是可以将玩家的屏幕进行录屏并可以将录制的实时流取出来传递到网络上面进行广播。想想近年来火热的游戏直播，是不是很兴奋。Aplle更变（gei）态(li)的是，在直播屏幕的同时还可以录制摄像头，这简直是给美女游戏直播撤掉了蒙羞布啊。

废话不多说，先来看个效果图：

![iPhone's Screen](http://images.libcz.com:8000/images/blog/iOS/replay/broadcast/images/iPhone_screen.png)

首先这张是我们提供的demo运行在iPhone上的效果。


再来：

![Android's Screen](http://images.libcz.com:8000/images/blog/iOS/replay/broadcast/images/Android_screen.png)

这个是在Android上面通过触手直播进行的观看效果，那个美美的键盘加豆浆就是我等程序猿早上的必备装备了。

虽然这个Demo比较挫，但是也可以脑补下这个换成游戏界面（如果游戏是横屏的，直播那里也是横屏的），然后在加上美女头像，是多美的一个画面。文中Demo可以在[github](https://github.com/cz-it/myblog/tree/master/blog/iOS/replay/broadcast/proj/broadcastdemo)上进行下载。

## 拉起主播平台选择界面
既然是通过第三方App进行直播，首要工作肯定就是要拉起第三方应用（虽然这里说的是第三方应用，实际上是苹果的一个机制，就类似分享一样，有个列表可以选择内嵌App）。效果如下：

![tabs](http://images.libcz.com:8000/images/blog/iOS/replay/broadcast/images/tabs.png)

这里和分享一样，拉起一个列表，罗列了本机上装了的App中已经实现“BroadCast UI Extension”（直播App才需要实现）的App。

那要如何实现这一步呢？来看下面代码：

	- (IBAction)onPopBroadcastServices:(id)sender {
	    [RPBroadcastActivityViewController loadBroadcastActivityViewControllerWithHandler:^(RPBroadcastActivityViewController * _Nullable broadcastActivityViewController, NSError * _Nullable error) {
	        if (nil != error) {
	            NSLog(@"loadBroadcastActivityViewControllerWithHandler with error %@", error.domain);
	            return ;
	        }
	        
	        broadcastActivityViewController.delegate = self;
	        [self presentViewController:broadcastActivityViewController animated:YES completion:^{
	            //
	        }];
	    }];
	}

这里主要调用`RPBroadcastActivityViewController`的一个类方法：

	+ (void)loadBroadcastActivityViewControllerWithHandler:(void (^)(RPBroadcastActivityViewController *broadcastActivityViewController, NSError *error))handler;
光光只调用这个接口，本身是不会弹出页面的，这个API作用是搜索出本机上装了的App中已经实现“BroadCast UI Extension”（直播App才需要实现）的App，并构建好UI。当完成后会调用上面的Block handler进行回调：

	void (^)(RPBroadcastActivityViewController *broadcastActivityViewController, NSError *error)
如果成功的话，`error`为nil，否则需要根据错误码进行判断。成功时，这里返回的RPBroadcastActivityViewController就是构建好的UI,一个UIViewController。通过rootViewController的`presentViewController `可以将其push出来。上面的代码就是做了这个事以后弹出UI的。

在弹出的页面中选择好要用的第三方直播App后，会短暂的切入到第三方直播App的控制界面中，比如给直播起个名字，有些直播App需要主播认证（企鹅电竞）。比如触手和映客的界面是这样的：

![chushou](http://images.libcz.com:8000/images/blog/iOS/replay/broadcast/images/chushou.png) ![yingke](http://images.libcz.com:8000/images/blog/iOS/replay/broadcast/images/yingke.png)

点击“开始直播”后。。。。

等

这个时候其实还没有开始直播，只是完成了一切设置过程而已。

如果这个时候回到App的界面，会发现，界面上的按钮都点击不了了。这是为啥呢？？？？

如果留意上面的步骤会发现，我们手动“present”了一个ViewController，但是却没有手动的去“dismiss”掉。那该什么时候来dismiss呢？

## RPBroadcastActivityViewController的Delegate
“什么时候？” 这种问题，肯定是要由Delegate来回答了。

上面构建的`RPBroadcastActivityViewController `我们可以为他设置一个Delegate:

	RPBroadcastActivityViewControllerDelegate
	
其目前就只有一个事件，就是当用户选择完第三方直播App之后：

	- (void)broadcastActivityViewController:(RPBroadcastActivityViewController *)broadcastActivityViewController 
       didFinishWithBroadcastController:(RPBroadcastController *)broadcastController 
                                  error:(NSError *)error;
                                  
error不为nil的话表示出错原因，比如用户点"X"的按钮。这里的`RPBroadcastActivityViewController `就是上面的罪魁祸首被"present"出来的ViewController了，我们在这个回调里面把他"dimiss"就可以了。

实现了这个Delegate后，如上面的例子，在`loadBroadcastActivityViewControllerWithHandler `的回调里面进行设置。

这里还有个重要的参数`RPBroadcastController `,其实他才是我们的主角，后面对录制过程的控制都要通过他来进行。

## 调用直播接口

怎么能没控制就直播呢？主播mm各种隐私是不是。所以还需要通过以下几个严格意义上的录制工具的API才能开始

	- (void)startBroadcastWithHandler:(void (^)(NSError *error))handler;
	- (void)pauseBroadcast;
	- (void)resumeBroadcast;
	- (void)finishBroadcastWithHandler:(void (^)(NSError *error))handler;

上面四个API对程序猿肯定没压力啦。就是开始、暂停、回复以及结束。这里需要注意的是开始和结束时有一个Block回调的，有同学反馈开始有的时候会失败，虽然我没有遇到过。不过还是做个检查比较好。

当调用`startBroadcastWithHandler `之后，在另一个手机上去看直播就可以了。经过试验，这个地方直播有个1-2min钟的延迟。另外不同的直播App表现也不一样。比如

* 触手TV: 在调用`startBroadcastWithHandler`后，会在通知里面弹出“直播已连接”的提示，当`finishBroadcastWithHandler `的时候，会弹出“直播已结束”的提示。
	![chushou1](http://images.libcz.com:8000/images/blog/iOS/replay/broadcast/images/chushou_1.png) ![chushou2](http://images.libcz.com:8000/images/blog/iOS/replay/broadcast/images/chushou_2.png)
* 映客： 调用哪个API都没有明确提示，需要关注主播后看效果。

开始后应该就可以在其他手机上面看到直播画面了。

## 设置麦克风和摄像头

按照上面走下来，会发现既没有主播声音也主播头像，这该怎么办呢？

这里还需要用到`RPScreenRecorder`这个类，他实际上是一个单例对象，通过其单例方法：
	
	+ (RPScreenRecorder *)sharedRecorder;
获得对象。

其有两个Setter方法：

	@property(nonatomic, getter=isCameraEnabled) BOOL cameraEnabled;
	@property(nonatomic, getter=isMicrophoneEnabled) BOOL microphoneEnabled;
将其设置成YES，就可以开启对应的功能了。

> 注意：这设置一定要再`startBroadcastWithHandler `之前设置好，否则不起作用

这个时候再直播看看。。。


此时会发现有主播MM甜甜的声音了，但是没有美美的头像。怎么整？这是因为摄像头的结果是个View，需要我们自己对其进行布局才可以显示。

在`startBroadcastWithHandler`的Block里面对`RPScreenRecorder `的

	@property(nonatomic, readonly) UIView *cameraPreviewView;
	
进行设置，比如调整下位置，然后在添加到rootView上面：
		
	[[RPScreenRecorder sharedRecorder].cameraPreviewView setFrame: CGRectMake(100, 100, 300, 300)];
	[self.view addSubview: [RPScreenRecorder sharedRecorder].cameraPreviewView];
	    
这里发现个坑爹的地方，就是这个View的位置可以改动，但是大小却不能变》》》》》

## 总结
通过上面的演示Demo可以了解到，Apple这次的诚意还是比较足的，以往一般主播是通过一个PC客户端的第三方工具获取屏幕内容，然后还要做麦克风和摄像头的同步，直播位置受限。现在通过ReplayKit，玩家可以随时随地的进行录屏直播，从而为iPhone游戏直播提供了一条更便捷的方式。

作为游戏测，只要使用ReplayKit的几个拉起直播平台的简单接口就可以实现通过第三方直播App进行直播。而直播App放则还要按照ReplayKit的要求创建“BroadCast UI Extension”以及“BroadCast Upload Extension”的功能来实现视频流的接收和上传，当然这个不在我们这篇文章的介绍范围之内。


##参考
1. [Go Live with ReplayKit](https://developer.apple.com/videos/play/wwdc2016/601/)
2. [ReplayKit API](https://developer.apple.com/reference/replaykit)