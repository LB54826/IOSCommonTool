//
//  LBBannerViewDisplayLinkTool.m
//
//  Created by Liubo on 2025/1/24.
//  Copyright © 2025 All rights reserved.
//

#import "LBBannerViewDisplayLinkTool.h"
#import <QuartzCore/QuartzCore.h>

@interface LBBannerViewDisplaylinkModel : NSObject
@property (nonatomic, assign) CGFloat duration;
@property (nonatomic, assign) CGFloat elapsedTime;//流逝的时间
@end

@implementation LBBannerViewDisplaylinkModel
@end

@interface LBBannerViewDisplayLinkTool()
{
    CADisplayLink *_displayLink;
}
@property (nonatomic, strong) LBBannerViewDisplaylinkModel *model;
@property (nonatomic, copy) void(^updatingBlock)(CGFloat progress);
@property (nonatomic, copy) void(^finishUpdateBlock)(void);
@end

@implementation LBBannerViewDisplayLinkTool
- (void)begeinUpdateDataWithDuration:(CGFloat)duration beginUpdateBlock:(void(^__nullable)(void))beginUpdateBlock updatingBlock:(void (^__nullable)(CGFloat))updatingBlock finishUpdateBlock:(void (^__nullable)(void))finishUpdateBlock
{
    [self clearAllData];
    
    if (duration > 0) {
        
        _updatingBlock = updatingBlock;
        _finishUpdateBlock = finishUpdateBlock;
        
        // 使用 CADisplayLink 实现逐帧更新
        _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateData:)];
        
        // 保存所需信息
        _model = [[LBBannerViewDisplaylinkModel alloc] init];
        _model.duration = duration;
        _model.elapsedTime = 0;
        
        //开始更新
        if (beginUpdateBlock) {
            beginUpdateBlock();
        }
        
        [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
        
    } else {
        if (beginUpdateBlock) {
            beginUpdateBlock();
        }
        if (updatingBlock) {
            updatingBlock(1);
        }
        if (finishUpdateBlock) {
            finishUpdateBlock();
        }
    }
}

- (void)updateData:(CADisplayLink *)displayLink {
    if (!_model) return;
    
    CGFloat duration = _model.duration;
    CGFloat elapsedTime = _model.elapsedTime + displayLink.duration;
    
    // 更新动画时间
    elapsedTime = MIN(elapsedTime, duration);
    _model.elapsedTime = elapsedTime;
    
    // 计算当前进度
    CGFloat progress = elapsedTime / duration;
    
    if (progress < 1) {
        if (_updatingBlock) {
            _updatingBlock(progress);
        }
    }
    
    // 判断是否完成
    if (progress >= 1) {
        
        if (progress > 1) {
            progress = 1;
        }
        if (_updatingBlock) {
            _updatingBlock(progress);
        }
        
        if (_finishUpdateBlock) {
            _finishUpdateBlock();
        }
        
        [self clearAllData];
    }
}

- (void)clearAllData
{
    if (_displayLink) {
        [_displayLink invalidate];
    }
    _model = nil;
    _updatingBlock = nil;
    _finishUpdateBlock = nil;
}
@end
