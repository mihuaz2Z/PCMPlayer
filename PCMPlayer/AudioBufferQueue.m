//
//  AudioBufferQueue.m
//  PCMPlayer
//
//  Created by Ruiwen Feng on 2017/5/31.
//  Copyright © 2017年 Ruiwen Feng. All rights reserved.
//

#import "AudioBufferQueue.h"

typedef struct AudioBufferQueueUnit {
    
    AudioBuffer                 * _audioBuffer;
    struct AudioBufferQueueUnit * _nextUnit;
    
    
}QueueUnit;

@interface AudioBufferQueue (){
    QueueUnit  * header;
    QueueUnit  * rear;
    unsigned int current_num;
}

@end

@implementation AudioBufferQueue

- (instancetype)init
{
    self = [super init];
    if (self) {
        current_num = 0;
        header = NULL;
        rear = NULL;
    }
    return self;
}

//存入一个音频buffer
- (BOOL)insertBuffer:(AudioBuffer*)buffer {
    
    if (current_num < AUDIO_BUFFER_QUEUE_MAX_SIZE-2) {   //数据没有满。
        current_num += 1;
        QueueUnit *unit = NULL;
        unit = malloc(sizeof(QueueUnit*));
        unit->_audioBuffer = malloc(sizeof(AudioBuffer*));
        
        [self copySourceBuffer:buffer toDestinationBuffer:unit->_audioBuffer];
        if (current_num == 1) { //如果是第一个数据。
            header = unit;
            rear = unit;
        }
        else {   //不是第一个数据。
            rear->_nextUnit = unit;
            rear = unit;
        }
    }
    else {     //数据满了。
        printf("audio Queue if full");
        return NO;
    }
    return YES;
}

//取出一个音频buffer
- (BOOL)extractBuffer:(void(^)(AudioBuffer*))callback {
    
    //没有内容。
    if (current_num <= DELAY_SEC*45 ) {
        return NO;
    }
    
    dispatch_block_t block = ^{
        callback(header->_audioBuffer); //回调出去。
        current_num --;
        QueueUnit * unit = header;     //头部向后移动
        header = header->_nextUnit;
        [self destoryQueueUnit:unit];//用完删除
    };
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), block);
    
    return YES;
}

- (void)copySourceBuffer:(AudioBuffer*)srcbuffer toDestinationBuffer:(AudioBuffer*)dstbuffer {
    char * buffer = malloc(srcbuffer->mDataByteSize);
    memcpy(buffer, srcbuffer->mData, srcbuffer->mDataByteSize);
    dstbuffer->mDataByteSize = srcbuffer->mDataByteSize;
    dstbuffer->mData = buffer;
}

- (void)destoryQueueUnit:(QueueUnit*)unit {
    free(unit->_audioBuffer->mData);
    unit->_audioBuffer = NULL;
    unit->_nextUnit = NULL;
    free(unit);
}

- (void)reSet {
    
    QueueUnit * unit = header;
    //从头删除。
    do {
        QueueUnit * TempUnit = unit;
        unit = TempUnit->_nextUnit;
        [self destoryQueueUnit:TempUnit];
    } while (unit != NULL);
    header = NULL;
    rear = NULL;
    current_num = 0;

}

- (void)dealloc
{
    [self reSet];
}

@end
