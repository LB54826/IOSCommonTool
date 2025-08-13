//
//  LBBannerViewExecuteTool.m
//
//  Created by Liubo on 2025/1/24.
//  Copyright © 2025 All rights reserved.
//

#import "LBBannerViewExecuteTool.h"
@interface LBBannerViewExecuteTool()
@property (nonatomic, copy) dispatch_block_t afterDelayToDoBlock;
@end

@implementation LBBannerViewExecuteTool
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
@end
