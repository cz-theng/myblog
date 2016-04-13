# iOS CoreAudio(三)：使用AVAudioPlayer播放音频
AVAudioPlayer可以对音频文件或者音频NSData数据进行播放，通常适用于IO延时较低的场景，比如来自网络上的音频流数据。并可以对播放进度进行控制，同时还可以
获得音频数据播放时的音量/能量大小等信息，从而可以绘制波形图进行展示。
##1. Hello World
先看一个例子，点击"Play"播放[Jason Chen](https://www.youtube.com/channel/UCoLmFHomrdplbGMj22ixdkA)翻唱的小幸运。“Play”变成“Stop”，点击“Stop”，停止播放。

	@interface ViewController ()
	@property (weak, nonatomic) IBOutlet UIButton *playBtn;
	@property (nonatomic, strong) AVAudioPlayer *player;
	@end
	
	@implementation ViewController
	
	- (void)viewDidLoad {
	    [super viewDidLoad];
	    // Do any additional setup after loading the view, typically from a nib.
	    
	    [self initPlayer];
	}
	
	- (void) initPlayer {
	    NSError *error;
	    NSString *soundPath = [[NSBundle mainBundle] pathForResource:@"xiao_xing_yun" ofType:@"mp3"];
	    _player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL URLWithString:soundPath] error:&error];
	    if (error != nil ) {
	        NSLog(@"init avaudioplayer error!");
	        return;
	    }
	}
	
	- (void)didReceiveMemoryWarning {
	    [super didReceiveMemoryWarning];
	    // Dispose of any resources that can be recreated.
	}
	- (IBAction)onPlayClick:(id)sender {
	    static BOOL clicked = NO;
	    if (!clicked) {
	        clicked = YES;
	        [_playBtn setTitle:@"Stop" forState:UIControlStateNormal];
	        [_player play];
	    } else {
	        clicked = NO;
	        [_playBtn setTitle:@"Play" forState:UIControlStateNormal];
	        [_player stop];
	    }
	}
	
	@end


##2. 获取播放信息
如果运行上面的程序，会发现，当点击"Play"的时候能正常播放音乐，当点击"Stop"的时候也能正常停止。但是当再次点击“Play”的时候，会发现它不是从头开始播放
，而是接着上次停止的位置。这里Stop虽然会接触player的perepare to play的状态，但是他并不会将`currentTime`清零。`currentTime`是什么呢？就是
音频数据到现在播放了的播放时间，比如一般MP3播放上面显示的总时间和当前播放时间，这个就是后者的当前播放时间。与之对应的还有个`deviceCurrentTime`
，这个时间指的是从_player 创建之后的时间，不论是否调用了`stop`或者`pause`其都会增长。这个时间主要用来做多个player之间的时间同步。这个后面会介绍到。这里说道了`pause`,上面的例子中也可以吧`stop`替换成`pause`,只是`pause`不会接触prepare to play的状态，同样也会记录当前的播放时间位置，不会从头开始播放。

对于上面的这个里


##3. 配合AVSession进行播放控制

##4. 总结


##参考文档
1. [AVAudioPlayer Class Reference](https://developer.apple.com/library/ios/documentation/AVFoundation/Reference/AVAudioPlayerClassReference/#//apple_ref/occ/instm/AVAudioPlayer/updateMeters)
2. [Audio Session Programming Guide](https://developer.apple.com/library/ios/documentation/Audio/Conceptual/AudioSessionProgrammingGuide/HandlingAudioInterruptions/HandlingAudioInterruptions.html#//apple_ref/doc/uid/TP40007875-CH4-SW1)
3. [AVAudioSession Class Reference]()