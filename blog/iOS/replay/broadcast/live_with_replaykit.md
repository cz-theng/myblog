#通过ReplayKit在触手、映客、企鹅电竞上直播游戏界面

在去年（2015）的WWDC Apple分享了主题[Going Social with ReplayKit and Game Center](https://developer.apple.com/videos/play/wwdc2015/605/)。该Session展示了Apple在iOS9上面引入了一个全新的framework来提供录屏功能，这样游戏用户就可以通过这个功能将自己玩的内容进行录制并分享了，但是实际使用起来，这个工具却有诸多弊端，比如内容要自己编辑、不能进行微信分享等。发布一年多来，使用的人甚少，至少在腾讯、网易这些手游大拿的游戏上面都没有看到该录制功能。

所以在今年（2016）的WWDC上面，Apple又展开了一个新的Session [Go Live with ReplayKit](https://developer.apple.com/videos/play/wwdc2016/601/),扩展了ReplayKit使其支持录屏直播的功能。简单描述就是可以将玩家的屏幕进行录屏并可以将录制的实时流取出来传递到网络上面进行广播。想想近年来火热的游戏直播，是不是很兴奋。Aplle更变（gei）态(li)的是，在直播屏幕的同时还可以录制摄像头，这简直是给美女游戏直播撤掉了蒙羞布啊。

废话不多说，先来看个效果图：

![iPhone's Screen](./images/iPhone_screen.png)

首先这张是我们提供的demo运行在iPhone上的效果。


再来：

![Android's Screen](./images/Android_screen.png)

这个是在Android上面通过触手直播进行的观看效果，那个美美的键盘加豆浆就是我等程序猿早上的必备装备了。

虽然这个Demo比较挫，但是也可以脑补下这个换成游戏界面（如果游戏是横屏的，直播那里也是横屏的），然后在加上美女头像，是多美的一个画面。文中Demo可以在[github]()上进行下载。

## 拉起主播平台选择界面

## 调用直播接口

## 设置麦克风和摄像头

## 总结
通过上面的演示Demo可以了解到，Apple这次的诚意还是比较足的，以往一般主播是通过一个PC客户端的第三方工具获取屏幕内容，然后还要做麦克风和摄像头的同步，直播位置受限。现在通过ReplayKit，玩家可以随时随地的进行录屏直播，从而为iPhone游戏直播提供了一条更便捷的方式。

作为游戏测，只要使用ReplayKit的几个拉起直播平台的简单接口就可以实现通过第三方直播App进行直播。而直播App放则还要按照ReplayKit的要求创建“BroadCast UI Extension”以及“BroadCast Upload Extension”的功能来实现视频流的接收和上传，当然这个不在我们这篇文章的介绍范围之内。
