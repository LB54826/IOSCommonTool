//
//  LBBannerViewIndicatorItemView.m
//
//  Created by Liubo on 2025/2/8.
//  Copyright © 2025 All rights reserved.
//

#import "LBBannerViewIndicatorItemView.h"
@interface LBBannerViewIndicatorItemView()
{
    UIView *_normalView;
    UIView *_selectedView;
    
    BOOL _isHorizontalShow;
    
    CGFloat _showWidth;
    CGFloat _showHeight;
    
    BOOL _isSelected;
}
@end

@implementation LBBannerViewIndicatorItemView
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)showIndicatorItemViewWithNormalView:(UIView *)normalView selectedView:(UIView *)selectedView isHorizontalShow:(BOOL)isHorizontalShow
{
    normalView.frame = CGRectMake(0, 0, normalView.frame.size.width, normalView.frame.size.height);
    selectedView.frame = CGRectMake(0, 0, selectedView.frame.size.width, selectedView.frame.size.height);
    
    _normalView = normalView;
    _selectedView = selectedView;
    _isHorizontalShow = isHorizontalShow;
    
    CGFloat showWidth = normalView.frame.size.width >= selectedView.frame.size.width ? normalView.frame.size.width : selectedView.frame.size.width;
    _showWidth = showWidth;
    CGFloat showHeight = normalView.frame.size.height >= selectedView.frame.size.height ? normalView.frame.size.height : selectedView.frame.size.height;
    _showHeight = showHeight;
    
    [self addSubview:normalView];
    [self addSubview:selectedView];
    
    [self setItemViewStatusIsNormal:YES];
}
- (void)setIndicatorItemViewSelected:(BOOL)setSelected
{
    if (setSelected) {
        if (!_isSelected) {
            [self setItemViewStatusIsNormal:NO];
            _isSelected = YES;
        }
    } else {
        if (_isSelected) {
            [self setItemViewStatusIsNormal:YES];
            _isSelected = NO;
        }
    }
}

- (void)setItemViewStatusIsNormal:(BOOL)isNormal
{
    if (isNormal) {
        [self updateFrameWithShowView:_normalView];
        _normalView.hidden = NO;
        _selectedView.hidden = YES;
    } else {
        [self updateFrameWithShowView:_selectedView];
        _normalView.hidden = YES;
        _selectedView.hidden = NO;
    }
}

- (void)updateFrameWithShowView:(UIView *)showView
{
    CGRect selfFrame = self.frame;
    selfFrame.size = showView.frame.size;
    if (_isHorizontalShow) {
        selfFrame.origin.y = (_showHeight - showView.frame.size.height) / 2.0;
    } else {
        selfFrame.origin.x = (_showWidth - showView.frame.size.width) / 2.0;
    }
    self.frame = selfFrame;
}

@end
