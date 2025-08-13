//
//  LikeTanTanCardView.h
//
//  Created by liubo on 2018/8/30.
//  Copyright © 2018年 All rights reserved.
//



#import <UIKit/UIKit.h>
#import "LikeTanTanCardViewDelegate.h"
@interface LikeTanTanCardView : UIView
@property (nonatomic, assign) id<LikeTanTanCardViewDelegate> delegate;
- (void)showLikeTanTanCardViewWithPoint:(CGPoint)cardPoint;
- (void)reloadDataWithCurrentShowIndex:(NSInteger)currentIndex;
//手动移除卡片，是否是从左侧，YES为左侧，NO为右侧
- (void)removeCardWithDirectionIsLeft:(BOOL)isLeft;
//需要重新设置frame时调用此方法
- (void)cardViewRefreshFrameWithCardFrame:(CGRect)cardFrame animationSetFrameBlock:(void(^)(CGRect cardViewFrame))animationSetFrameBlock animationFinishedBlock:(void(^)(void))animationFinishedBlock;
@end
