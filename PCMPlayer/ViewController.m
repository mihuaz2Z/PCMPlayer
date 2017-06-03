//
//  ViewController.m
//  PCMPlayer
//
//  Created by Ruiwen Feng on 2017/5/31.
//  Copyright © 2017年 Ruiwen Feng. All rights reserved.
//

#import "ViewController.h"
#import "PCMPlayer.h"
#import <AVFoundation/AVFoundation.h>

@interface ViewController ()
@property (strong,nonatomic) PCMPlayer *recorder;;

@end

@implementation ViewController {

    FILE * file;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.recorder = [[PCMPlayer alloc]init];
    
    AudioStreamBasicDescription streamDes;
    [PCMPlayer defaultAudioFormat:&streamDes];
    [self.recorder createUnit:streamDes];
    
    [self.recorder startPlay];

    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.02 * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [self readFile];
    });
    
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)readFile {

    if (file == NULL) {
        NSString * path = [[NSBundle mainBundle] pathForResource:@"8000hz16bit1channel" ofType:@"pcm"];
        file = fopen(path.UTF8String,"r");
    }
    
    if (feof(file)) {
        return;
    }
    
    char data[320];
    fread(data, 320, 1, file);
    AudioBuffer buffer;
    buffer.mData = data;
    buffer.mDataByteSize = 320;
    buffer.mNumberChannels = 1;
    [self.recorder inserAudioBuffer:&buffer];
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1/(8000*2/320) * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [self readFile];
    });
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
