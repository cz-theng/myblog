#获得当前Apple/Android 设备的Model类型
要想获得当前手机是神马手机，比如“iPhone 5”还是“iPhone 6”，是“samsung note4”还是“HuaWei p600”。我们可以通过获取Model来进行判断。

iPhone一年一更的速度，至今已经有数十款硬件版本了，这里说的是Model版本而不是iOS系统版本，因为有的时候，我们需要根据硬件来判断相关功能是否拥有。比如指纹识别，Iop支持等。
虽然可以通过UIDevice获得一定的信息，但是要想获得具体的硬件信息，还是需要通过c API来获得。同样，Android也是有类似接口。

##iOS 硬件Model获取
头文件<sys/sysctl.h>中定义了 `int	sysctlbyname(const char *, void *, size_t *, void *, size_t);`有点类似fcntl可以获得对应的属性信息。比如：

	size_t size;
	sysctlbyname("hw.machine", NULL, &size, NULL, 0);
	sysctlbyname("hw.machine", device_type, &size, NULL, 0);
	
首先获得键值为“hw.machine”的长度，然后再根据这个长度获得其内容。得到的结果是类似“iPhone6,2”的结果，但是这个结果并不能和我们熟知的"iPhone 5s"对应上，这里需要参考
“iPhone WIKI”中的[Models](https://www.theiphonewiki.com/wiki/Models)章节。可以得到一一对应的关系。这里定义了一个函数进行获取：

	const char * get_device_type ()
    {
        memset(device_type, 0, AV_DEVICE_TYPE_MAX_SIZE);
        size_t size;
        sysctlbyname("hw.machine", NULL, &size, NULL, 0);
        sysctlbyname("hw.machine", device_type, &size, NULL, 0);
        
        #define RETRUN_MODEL(sys_model,model)  do {\
        if (!strcmp(device_type, (sys_model))){\
        return model;\
        } }while(0)
        
        // iPhone
        RETRUN_MODEL("iPhone1,1", "iPhome");
        RETRUN_MODEL("iPhone1,2", "iPhone 3G");
        RETRUN_MODEL("iPhone2,1", "iPhone 3GS");
        RETRUN_MODEL("iPhone3,1", "iPhone 4");
        RETRUN_MODEL("iPhone3,2", "iPhone 4");
        RETRUN_MODEL("iPhone3,3", "iPhone 4");
        RETRUN_MODEL("iPhone4,1", "iPhone 4S");
        RETRUN_MODEL("iPhone5,1", "iPhone 5");
        RETRUN_MODEL("iPhone5,2", "iPhone 5");
        RETRUN_MODEL("iPhone5,3", "iPhone 5c");
        RETRUN_MODEL("iPhone5,4", "iPhone 5c");
        RETRUN_MODEL("iPhone6,1", "iPhone 5s");
        RETRUN_MODEL("iPhone6,2", "iPhone 5s");
        RETRUN_MODEL("iPhone7,2", "iPhone 6");
        RETRUN_MODEL("iPhone7,1", "iPhone 6 Plus");
        // iPad
        RETRUN_MODEL("iPad1,1", "iPad");
        RETRUN_MODEL("iPad2,1", "iPad 2");
        RETRUN_MODEL("iPad2,2", "iPad 2");
        RETRUN_MODEL("iPad2,3", "iPad 2");
        RETRUN_MODEL("iPad3,1", "iPad 3");
        RETRUN_MODEL("iPad3,2", "iPad 3");
        RETRUN_MODEL("iPad3,3", "iPad 3");
        RETRUN_MODEL("iPad3,4", "iPad 4");
        RETRUN_MODEL("iPad3,5", "iPad 4");
        RETRUN_MODEL("iPad3,6", "iPad 4");
        RETRUN_MODEL("iPad4,1", "iPad Air");
        RETRUN_MODEL("iPad4,2", "iPad Air");
        RETRUN_MODEL("iPad4,3", "iPad Air");
        RETRUN_MODEL("iPad5,3", "iPad Air 2");
        RETRUN_MODEL("iPad5,4", "iPad Air 2");
        // Ipad Mini
        RETRUN_MODEL("iPad2,5", "iPad mini 1G");
        RETRUN_MODEL("iPad2,6", "iPad mini 1G");
        RETRUN_MODEL("iPad2,7", "iPad mini 1G");
        RETRUN_MODEL("iPad4,4", "iPad mini 2");
        RETRUN_MODEL("iPad4,5", "iPad mini 2");
        RETRUN_MODEL("iPad4,6", "iPad mini 2");
        RETRUN_MODEL("iPad4,7", "iPad mini 3");
        RETRUN_MODEL("iPad4,8", "iPad mini 3");
        RETRUN_MODEL("iPad4,9", "iPad mini 3");
        // iPod Touch
        RETRUN_MODEL("iPod1,1", "iPod touch");
        RETRUN_MODEL("iPod2,1", "iPod touch 2G");
        RETRUN_MODEL("iPod3,1", "iPod touch 3G");
        RETRUN_MODEL("iPod4,1", "iPod touch 4G");
        RETRUN_MODEL("iPod5,1", "iPod touch 5G");
        RETRUN_MODEL("iPod7,1", "iPad mini 3");
        RETRUN_MODEL("iPad4,9", "iPod touch 6G");
        
        #undef RETRUN_MODEL
	}
	
这里定义了一个`RETRUN_MODEL`来简化if...else...。当有新的iPhone发布时，可以对这个表进行更新。

##Android 硬件Model获取
Android系统里面对等的是在 <sys/system_properties.h>这个头文件里面的`int __system_property_get(const char *name, char *value);`。 

	__system_property_get("ro.product.model", device_type);
	
这里不需神马特殊的权限，写好NDK的JNI代码即可。当然，Android还有对应的Java接口。这里的C接口，只是方便写底层代码的同学，可以减少对JNI反调的使用。

	String deviceType = Build.MODEL
	
这个属性的使用以及其他属性可以在Android的Develop Reference 中的[Build](http://developer.android.com/reference/android/os/Build.html)中找到。