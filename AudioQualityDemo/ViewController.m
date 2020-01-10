//
//  ViewController.m
//  AudioQualityDemo
//
//  Created by 党玉华 on 2020/1/10.
//  Copyright © 2020 Linkdom. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "LameTool.h"

@interface ViewController ()<AVAudioRecorderDelegate>

@property(nonatomic,strong)AVAudioRecorder *record;
@property(nonatomic,strong)AVAudioPlayer *player;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];
}

-(void)setupUI{
    UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(30, 150, self.view.bounds.size.width-60, 50)];
    [btn setTitle:@"按住录音" forState:UIControlStateNormal];
    [btn setTitle:@"松手结束" forState:UIControlStateHighlighted];
    [btn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
    [self.view addSubview:btn];
    btn.layer.cornerRadius = 5;
    btn.layer.borderColor = [UIColor lightGrayColor].CGColor;
    btn.layer.borderWidth = 1;
    [btn addTarget:self action:@selector(recordButtonTouchBegin) forControlEvents:UIControlEventTouchDown];
    [btn addTarget:self action:@selector(recordButtonTouchEnd) forControlEvents:UIControlEventTouchUpInside];
    
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask, YES)lastObject]stringByAppendingPathComponent:@"record_encoded.caf"];
    NSURL *url = [NSURL fileURLWithPath:path];
    NSDictionary *configDic = @{// 编码格式
                                AVFormatIDKey:@(kAudioFormatLinearPCM),
                                // 采样率
                                AVSampleRateKey:@(11025.0),
                                // 通道数
                                AVNumberOfChannelsKey:@(2),
                                // 录音质量
                                AVEncoderAudioQualityKey:@(AVAudioQualityMax)
                                };
    NSError *error = nil;
    _record = [[AVAudioRecorder alloc]initWithURL:url settings:configDic error:&error];
    if (error) {
        NSLog(@"⚠️error:%@",error);
    }
    _record.delegate = self;
    // 准备录音(系统会给我们分配一些资源)
    [_record prepareToRecord];
}
//开始
- (void)recordButtonTouchBegin{
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [audioSession setActive:YES error:nil];
    [self.record record];
}
//结束
- (void)recordButtonTouchEnd{
    [self.record stop];
    self.title = @"音频处理中";
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.title = @"";
    });
}
- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag{
    NSString *recordPath = [[recorder url] path];
    NSString *path =  [LameTool audioToMP3:recordPath isDeleteSourchFile:YES];
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
    [audioSession setActive:YES error:nil];
    NSURL *url = [NSURL fileURLWithPath:path];
    AVURLAsset *mp3Asset = [AVURLAsset URLAssetWithURL:url options:nil];
    CMTime audioDuration = mp3Asset.duration;
    float audioDurationSeconds =CMTimeGetSeconds(audioDuration);
    if (audioDurationSeconds<0.5) {//少于0.5秒不做处理
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"太快了，未能获取到语音" message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    NSError *error = nil;
    self.player = [[AVAudioPlayer alloc]initWithContentsOfURL:url error:&error];
    if (error == nil) {
        [self.player prepareToPlay];
    }
    [self.player play];
}
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    
}
- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError * __nullable)error{
    NSLog(@"%@",error.localizedDescription);
}
@end
