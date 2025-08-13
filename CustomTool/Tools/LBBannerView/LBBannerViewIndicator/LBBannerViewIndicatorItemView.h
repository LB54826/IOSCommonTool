//
//  LBBannerViewIndicatorItemView.h
//
//  Created by Liubo on 2025/2/8.
//  Copyright © 2025 All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LBBannerViewIndicatorItemView : UIView
- (void)showIndicatorItemViewWithNormalView:(UIView *)normalView selectedView:(UIView *)selectedView isHorizontalShow:(BOOL)isHorizontalShow;
- (void)setIndicatorItemViewSelected:(BOOL)setSelected;
@end

NS_ASSUME_NONNULL_END
