//
//  LBBannerViewIndicatorView.h
//
//  Created by Liubo on 2025/2/10.
//  Copyright © 2025 All rights reserved.
//

#import <UIKit/UIKit.h>
@class LBBannerViewIndicatorView;
@protocol LBBannerViewIndicatorViewDelegate <NSObject>
//是否横向显示 YES-横向 NO-竖向
- (BOOL)indicatorViewIsHorizontalShow:(LBBannerViewIndicatorView *_Nonnull)indicatorView;

//未选中样式的view
- (UIView *_Nonnull)indicatorViewItemNormalView:(LBBannerViewIndicatorView *_Nonnull)indicatorView;

//选中状态view
- (UIView *_Nonnull)indicatorViewItemSelectedView:(LBBannerViewIndicatorView *_Nonnull)indicatorView;

//item之间的间隙
- (CGFloat)indicatorViewItemToItemSpace:(LBBannerViewIndicatorView *_Nonnull)indicatorView;

//指示器view是否可点击
- (BOOL)indicatorViewIndicatorViewCanClick:(LBBannerViewIndicatorView *_Nonnull)indicatorView;

//指示器view点击了的回调
- (void)indicatorViewIndicatorViewClick:(LBBannerViewIndicatorView *_Nonnull)indicatorView;
@end

NS_ASSUME_NONNULL_BEGIN

@interface LBBannerViewIndicatorView : UIView
@property (nonatomic, assign) id<LBBannerViewIndicatorViewDelegate> delegate;
- (void)indicatorViewShowDatasWithItemCount:(NSInteger)itemCount;
- (void)indicatorViewShowIndex:(NSInteger)showIndex;
- (BOOL)getIsHorizontalShow;
- (void)clearAllDatas;
@end

NS_ASSUME_NONNULL_END
