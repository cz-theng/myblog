#接受新时代的UIStackView


虽然UIStackView是继承与UIView，但是却没有继承UIView的渲染功能，所以UIStackView是没有UI的，也就是不显示本身的。所以类似“backgroundColor”的界面属性就无效了，同时重写 `layerClass`, `drawRect:`甚至`drawLayer:inContext:`都是无效的。

1. [iOS 9: Getting Started with UIStackView](http://code.tutsplus.com/tutorials/ios-9-getting-started-with-uistackview--cms-24193)
2. [UIStackView Class Reference](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UIStackView_Class_Reference/index.html#//apple_ref/c/tdef/UIStackViewAlignment)
3. [Auto Layout Guide -- Stack Views](https://developer.apple.com/library/ios/documentation/UserExperience/Conceptual/AutolayoutPG/LayoutUsingStackViews.html#//apple_ref/doc/uid/TP40010853-CH11-SW1)
