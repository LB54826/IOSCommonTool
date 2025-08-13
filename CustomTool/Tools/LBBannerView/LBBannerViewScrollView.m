//
//  LBBannerViewScrollView.m
//
//  Created by Liubo on 2025/1/24.
//  Copyright © 2025 All rights reserved.
//

#import "LBBannerViewScrollView.h"
@interface LBBannerViewScrollView()
@property (nonatomic, strong) NSDictionary *animationInfo;
@end
@implementation LBBannerViewScrollView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        if (@available(iOS 11.0, *)) {
            self.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } else {
            
        }
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    if (@available(iOS 11.0, *)) {
        self.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    // 首先判断otherGestureRecognizer是不是系统pop手势
    if ([otherGestureRecognizer.view isKindOfClass:NSClassFromString(@"UILayoutContainerView")]) {
        // 再判断系统手势的state是began还是fail，同时判断scrollView的位置是不是正好在最左边
        if (otherGestureRecognizer.state == UIGestureRecognizerStateBegan && self.contentOffset.x == 0) {
            return YES;
        }
    }
    if ([gestureRecognizer isKindOfClass:NSClassFromString(@"UIScrollViewPanGestureRecognizer")]) {
        UIPanGestureRecognizer *pan = (UIPanGestureRecognizer *)gestureRecognizer;
        CGFloat velocity = [pan velocityInView:self].x;
        if (velocity > 0 && self.contentOffset.x == 0) {
            return YES;
        }
    }

    return NO;
}

////UIScrollView分类写法
//- (void)setContentOffset:(CGPoint)contentOffset
//           withDuration:(NSTimeInterval)duration
//              completion:(void (^)(BOOL finished))completion
//         progressHandler:(void (^)(CGPoint currentOffset))progressHandler {
//
//    CGPoint startOffset = self.contentOffset;
//    CGPoint endOffset = contentOffset;
//    __block NSTimeInterval elapsedTime = 0;
//
//    // 使用 CADisplayLink 实现逐帧更新
//    CADisplayLink *displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateOffset:)];
//    objc_setAssociatedObject(self, @selector(updateOffset:), displayLink, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//
//    // 保存所需信息
//    NSDictionary *animationInfo = @{
//        @"startOffset": [NSValue valueWithCGPoint:startOffset],
//        @"endOffset": [NSValue valueWithCGPoint:endOffset],
//        @"duration": @(duration),
//        @"elapsedTime": @(elapsedTime),
//        @"completion": completion ?: ^(BOOL finished) {},
//        @"progressHandler": progressHandler ?: ^(CGPoint offset) {}
//    };
//    objc_setAssociatedObject(self, @selector(animationInfo), animationInfo, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//
//    // 开始更新
//    [displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
//}
//
//- (void)updateOffset:(CADisplayLink *)displayLink {
//    NSDictionary *animationInfo = objc_getAssociatedObject(self, @selector(animationInfo));
//    if (!animationInfo) return;
//
//    CGPoint startOffset = [animationInfo[@"startOffset"] CGPointValue];
//    CGPoint endOffset = [animationInfo[@"endOffset"] CGPointValue];
//    NSTimeInterval duration = [animationInfo[@"duration"] doubleValue];
//    NSTimeInterval elapsedTime = [animationInfo[@"elapsedTime"] doubleValue] + displayLink.duration;
//    void (^completion)(BOOL finished) = animationInfo[@"completion"];
//    void (^progressHandler)(CGPoint offset) = animationInfo[@"progressHandler"];
//
//    // 更新动画时间
//    elapsedTime = MIN(elapsedTime, duration);
//    objc_setAssociatedObject(self, @selector(animationInfo), @{
//        @"startOffset": animationInfo[@"startOffset"],
//        @"endOffset": animationInfo[@"endOffset"],
//        @"duration": animationInfo[@"duration"],
//        @"elapsedTime": @(elapsedTime),
//        @"completion": completion,
//        @"progressHandler": progressHandler
//    }, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//
//    // 计算当前进度
//    CGFloat progress = elapsedTime / duration;
//    CGPoint currentOffset = CGPointMake(
//        startOffset.x + (endOffset.x - startOffset.x) * progress,
//        startOffset.y + (endOffset.y - startOffset.y) * progress
//    );
//
//    // 更新 UIScrollView 的 contentOffset
//    [self setContentOffset:currentOffset animated:NO];
//
//    // 调用进度回调
//    if (progressHandler) {
//        progressHandler(currentOffset);
//    }
//
//    // 判断是否完成
//    if (elapsedTime >= duration) {
//        [displayLink invalidate];
//        objc_setAssociatedObject(self, @selector(updateOffset:), nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//        objc_setAssociatedObject(self, @selector(animationInfo), nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//        if (completion) {
//            completion(YES);
//        }
//    }
//}

- (void)setContentOffset:(CGPoint)contentOffset
           withDuration:(NSTimeInterval)duration
              completion:(void (^)(UIScrollView *currentScrollView,BOOL isFinished))completion
         progressHandler:(void (^)(UIScrollView *currentScrollView))progressHandler {
    
    CGPoint startOffset = self.contentOffset;
    CGPoint endOffset = contentOffset;
    __block NSTimeInterval elapsedTime = 0;
    
    // 使用 CADisplayLink 实现逐帧更新
    CADisplayLink *displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateOffset:)];
//    objc_setAssociatedObject(self, @selector(updateOffset:), displayLink, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    // 保存所需信息
    NSDictionary *animationInfo = @{
        @"startOffset": [NSValue valueWithCGPoint:startOffset],
        @"endOffset": [NSValue valueWithCGPoint:endOffset],
        @"duration": @(duration),
        @"elapsedTime": @(elapsedTime),
        @"completion": completion ?: ^(UIScrollView *currentScrollView,BOOL isFinished) {},
        @"progressHandler": progressHandler ?: ^(UIScrollView *currentScrollView) {}
    };
    self.animationInfo = animationInfo;
//    objc_setAssociatedObject(self, @selector(animationInfo), animationInfo, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    // 开始更新
    [displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)updateOffset:(CADisplayLink *)displayLink {
//    NSDictionary *animationInfo = objc_getAssociatedObject(self, @selector(animationInfo));
    NSDictionary *animationInfo = self.animationInfo;
    if (!animationInfo) return;
    
    CGPoint startOffset = [animationInfo[@"startOffset"] CGPointValue];
    CGPoint endOffset = [animationInfo[@"endOffset"] CGPointValue];
    NSTimeInterval duration = [animationInfo[@"duration"] doubleValue];
    NSTimeInterval elapsedTime = [animationInfo[@"elapsedTime"] doubleValue] + displayLink.duration;
    void (^completion)(UIScrollView *currentScrollView,BOOL isFinished) = animationInfo[@"completion"];
    void (^progressHandler)(UIScrollView *currentScrollView) = animationInfo[@"progressHandler"];
    
    // 更新动画时间
    elapsedTime = MIN(elapsedTime, duration);
    self.animationInfo = @{
        @"startOffset": animationInfo[@"startOffset"],
        @"endOffset": animationInfo[@"endOffset"],
        @"duration": animationInfo[@"duration"],
        @"elapsedTime": @(elapsedTime),
        @"completion": completion,
        @"progressHandler": progressHandler
    };
//    objc_setAssociatedObject(self, @selector(animationInfo), @{
//        @"startOffset": animationInfo[@"startOffset"],
//        @"endOffset": animationInfo[@"endOffset"],
//        @"duration": animationInfo[@"duration"],
//        @"elapsedTime": @(elapsedTime),
//        @"completion": completion,
//        @"progressHandler": progressHandler
//    }, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    // 计算当前进度
    CGFloat progress = elapsedTime / duration;
    if (progress > 1) {
        progress = 1;
    }
    CGPoint currentOffset = CGPointMake(
        startOffset.x + (endOffset.x - startOffset.x) * progress,
        startOffset.y + (endOffset.y - startOffset.y) * progress
    );
    
    // 更新 UIScrollView 的 contentOffset
    [self setContentOffset:currentOffset animated:NO];
    
    // 调用进度回调
    if (progress < 1) {
        if (progressHandler) {
            progressHandler(self);
        }
    }
    
    // 判断是否完成
    if (elapsedTime >= duration) {
        [displayLink invalidate];
        _animationInfo = nil;
//        objc_setAssociatedObject(self, @selector(updateOffset:), nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//        objc_setAssociatedObject(self, @selector(animationInfo), nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        if (progressHandler) {
            progressHandler(self);
        }
        if (completion) {
            completion(self,YES);
        }
    }
}

@end
