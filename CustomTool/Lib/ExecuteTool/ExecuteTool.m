//
//  ExcuteTool.m
//
//  Created by lb on 2016/9/14.
//  Copyright © 2016年. All rights reserved.
//

#import "ExecuteTool.h"
@interface ExecuteTool()
@property (nonatomic, copy) dispatch_block_t afterDelayToDoBlock;
@end
@implementation ExecuteTool
- (void)executeSomethingAfterDelay:(CGFloat)delay repeat:(BOOL)repeat afterDelay:(void(^)(void))afterDelay
{
    __weak typeof(self) wself = self;
    _afterDelayToDoBlock = dispatch_block_create(0, ^{
        __strong typeof(wself) sself = wself;
        if (afterDelay) {
            afterDelay();
        }
        if (repeat) {
            [sself beginExecuteAfterDelay:delay];
        }
    });
    [self beginExecuteAfterDelay:delay];
}
- (void)cancleExecuteBlockWithCompleteBlock:(void (^)(void))completeBlock
{
    if (_afterDelayToDoBlock) {
        dispatch_block_cancel(_afterDelayToDoBlock);
        _afterDelayToDoBlock = nil;
    }
    if (completeBlock) {
        completeBlock();
    }
}

- (void)beginExecuteAfterDelay:(CGFloat)delay
{
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC));
    dispatch_after(popTime,dispatch_get_main_queue(),_afterDelayToDoBlock);
}

+ (void)executeSomethingAfterDelay:(CGFloat)delay afterDelay:(void(^)(void))afterDelay
{
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC));
    dispatch_after(popTime,dispatch_get_main_queue(),^(void){
        if (afterDelay) {
            afterDelay();
        }
    });
}
@end
