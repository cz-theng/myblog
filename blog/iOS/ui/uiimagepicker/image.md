#庖丁UIKit之用UIImagePickerController拍照



## 0. 设置UIImagePickerController进行拍照

UIImagePickerController在获取图像资源，首先需要指定一个资源源，有三类：

* photoLibrary ： 照片库
* camera ： 摄像头
* savedPhotosAlbum ： 照片集

其实就是从摄像头采集还是从手机系统里面的图片进行选取。

在选择了图像资源后，还需要指定那种资源：

* kUTTypeImage： 图片
* kUTTypeMovie ：视频

这里我们是要拍照，当然是选择图片资源了。 

要拍照的话，首先检查摄像头资源是否可用：

	if UIImagePickerController.isSourceTypeAvailable(.camera) {
		...
	}
通过调用“UIImagePickerController”的类方法：

	class func isSourceTypeAvailable(UIImagePickerControllerSourceType)
	
检查其是否支持从摄像头采集资源。

然后再设置资源为摄像头：

	picker.sourceType = .camera
设置`var sourceType: UIImagePickerControllerSourceType`实例变量为摄像头。

设置了摄像头资源还不够，因为iPhone通常有两个摄像头：前置摄像头和后置摄像头。

这里先判断对应的摄像头是否可用。如果可用优先选择后置摄像头：

    if UIImagePickerController.isCameraDeviceAvailable(.rear) {
        picker.cameraDevice = .rear
    } else if UIImagePickerController.isCameraDeviceAvailable(.front) {
        picker.cameraDevice = .front
    } else {
    }
通过调用“UIImagePickerController”的类方法：

	class func isCameraDeviceAvailable(UIImagePickerControllerCameraDevice)

判断是否支持后置摄像头。
	
最后如上面所说，要把类型设置成照片类型：

    let types = UIImagePickerController.availableMediaTypes(for: .camera)
    if let ts = types {
        if ts.contains(kUTTypeImage as String) {
            picker.mediaTypes = [kUTTypeImage as String]
            Confirm(title: "kUTTypeImage", message: "设置为采集照片模式")
        }
    }
首先调用“UIImagePickerController”的类方法：

	`class func availableMediaTypes(for: UIImagePickerControllerSourceType)`
	
查询摄像头支持的所有类型媒体，然后再判断图片类型kUTTypeImage是否包含在其中，如果在的话，就设置可以采集的类型的`var mediaTypes: [String]`为 `[kUTTypeImage as String]`。这样就完成设置采集源以及采集资源的类型操作了。

## 1. 进行拍照
在进行了设置后，就可以准备进行拍照了。用UIImagePickerController拍照的过程，实际上是拉起一个包含拍照功能的ViewController,那么只要“present”这个ViewController出来就可以了：

    self.present(picker, animated: true) {
        //
    }
    
如果一切正常的话，这时候应该就可以看到弹出来的拍照界面了:

![camera](./images/camera.png)

这里就和操作系统应用“相机”里面的拍照一样，但是如果拍照完，点击“使用照片”，会发现虽然拍照的界面消失了，但是系统“照片”里面却没有照片，同时也没有其他提示。

## 2. 自定义拍照界面

## 3.总结