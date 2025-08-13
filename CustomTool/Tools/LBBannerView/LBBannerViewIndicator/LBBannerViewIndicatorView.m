//
//  LBBannerViewIndicatorView.m
//
//  Created by Liubo on 2025/2/10.
//  Copyright © 2025 All rights reserved.
//

#define kItemViewBaseTag 10000

#import "LBBannerViewIndicatorView.h"
#import "LBBannerViewIndicatorItemView.h"
@interface LBBannerViewIndicatorView()
{
    NSInteger _itemCount;
}
@property (nonatomic, strong) UIButton *clickBtn;
@end

@implementation LBBannerViewIndicatorView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

#pragma mark - 获取delegate数据
- (BOOL)getIsHorizontalShow
{
    BOOL isHorizontalShow = YES;
    if ([_delegate respondsToSelector:@selector(indicatorViewIsHorizontalShow:)]) {
        isHorizontalShow = [_delegate indicatorViewIsHorizontalShow:self];
    }
    return isHorizontalShow;
}
- (UIView *)getItemNormalView
{
    UIView *view = nil;
    if ([_delegate respondsToSelector:@selector(indicatorViewItemNormalView:)]) {
        view = [_delegate indicatorViewItemNormalView:self];
    }
    return view;
}
- (UIView *)getItemSelectedView
{
    UIView *view = nil;
    if ([_delegate respondsToSelector:@selector(indicatorViewItemSelectedView:)]) {
        view = [_delegate indicatorViewItemSelectedView:self];
    }
    return view;
}
- (CGFloat)getItemToItemSpace
{
    CGFloat space = 0;
    if ([_delegate respondsToSelector:@selector(indicatorViewItemToItemSpace:)]) {
        space = [_delegate indicatorViewItemToItemSpace:self];
    }
    return space;
}
- (BOOL)getIndicatorViewCanClick
{
    BOOL canClick = NO;
    if ([_delegate respondsToSelector:@selector(indicatorViewIndicatorViewCanClick:)]) {
        canClick = [_delegate indicatorViewIndicatorViewCanClick:self];
    }
    return canClick;
}
- (void)indicatorViewClickToDo
{
    if ([_delegate respondsToSelector:@selector(indicatorViewIndicatorViewClick:)]) {
        [_delegate indicatorViewIndicatorViewClick:self];
    }
}
#pragma mark - 展示数据
- (void)indicatorViewShowDatasWithItemCount:(NSInteger)itemCount
{
    [self clearAllDatas];
    
    _itemCount = itemCount;
    
    if (_delegate) {
        UIView *normalView = [self getItemNormalView];
        UIView *selectedView = [self getItemSelectedView];
        if (normalView && selectedView) {
            CGFloat itemMaxWidth = normalView.frame.size.width >= selectedView.frame.size.width ? normalView.frame.size.width : selectedView.frame.size.width;
            CGFloat itemMaxHeight = normalView.frame.size.height >= selectedView.frame.size.height ? normalView.frame.size.height : selectedView.frame.size.height;
            
            BOOL isHorizontalShow = [self getIsHorizontalShow];
            
            CGFloat itemToItemSpace = [self getItemToItemSpace];
            
            LBBannerViewIndicatorItemView *lastItemView = nil;
            for (int i = 0; i < itemCount; i++) {
                UIView *itemNormalView = [self getItemNormalView];
                UIView *itemSelectedView = [self getItemSelectedView];
                
                LBBannerViewIndicatorItemView *itemView = [[LBBannerViewIndicatorItemView alloc] initWithFrame:CGRectZero];
                itemView.tag = kItemViewBaseTag + i;
                [self addSubview:itemView];
                [itemView showIndicatorItemViewWithNormalView:itemNormalView selectedView:itemSelectedView isHorizontalShow:isHorizontalShow];
                
                CGRect itemViewFrame = itemView.frame;
                if (isHorizontalShow) {
                    itemViewFrame.origin.x = lastItemView ? CGRectGetMaxX(lastItemView.frame) + itemToItemSpace : 0;
                } else {
                    itemViewFrame.origin.y = lastItemView ? CGRectGetMaxY(lastItemView.frame) + itemToItemSpace : 0;
                }
                itemView.frame = itemViewFrame;
                
                lastItemView = itemView;
            }
            
            CGRect frame = self.frame;
            if (isHorizontalShow) {
                frame.size.width = CGRectGetMaxX(lastItemView.frame);
                frame.size.height = itemMaxHeight;
            } else {
                frame.size.width = itemMaxWidth;
                frame.size.height = CGRectGetMaxY(lastItemView.frame);
            }
            self.frame = frame;
            
            [self showClickBtnToDo];
        }
    }
}
- (void)indicatorViewShowIndex:(NSInteger)showIndex
{
    NSLog(@"indicator--showIndex:%ld",(long)showIndex);
    
    BOOL isHorizontalShow = [self getIsHorizontalShow];
    
    CGFloat itemToItemSpace = [self getItemToItemSpace];
    
    LBBannerViewIndicatorItemView *lastItemView = nil;
    for (int i = 0; i < _itemCount; i++) {
        LBBannerViewIndicatorItemView *showItemView = [self viewWithTag:kItemViewBaseTag + i];
        if (showItemView) {
            if (i == showIndex) {
                [showItemView setIndicatorItemViewSelected:YES];
            } else {
                [showItemView setIndicatorItemViewSelected:NO];
            }
            CGRect itemViewFrame = showItemView.frame;
            if (isHorizontalShow) {
                itemViewFrame.origin.x = lastItemView ? CGRectGetMaxX(lastItemView.frame) + itemToItemSpace : 0;
            } else {
                itemViewFrame.origin.y = lastItemView ? CGRectGetMaxY(lastItemView.frame) + itemToItemSpace : 0;
            }
            showItemView.frame = itemViewFrame;
            
            lastItemView = showItemView;
        }
    }
    
    CGRect frame = self.frame;
    if (isHorizontalShow) {
        frame.size.width = CGRectGetMaxX(lastItemView.frame);
    } else {
        frame.size.height = CGRectGetMaxY(lastItemView.frame);
    }
    self.frame = frame;
    
    [self setClickBtnFrame];
}

- (void)showClickBtnToDo
{
    BOOL canClick = [self getIndicatorViewCanClick];
    if (canClick) {
        self.clickBtn.frame = self.bounds;
        [self addSubview:self.clickBtn];
    }
}
- (UIButton *)clickBtn
{
    if (!_clickBtn) {
        _clickBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_clickBtn addTarget:self action:@selector(clickBtnClickToDo) forControlEvents:UIControlEventTouchUpInside];
    }
    return _clickBtn;
}
- (void)clickBtnClickToDo
{
    [self indicatorViewClickToDo];
}
- (void)setClickBtnFrame
{
    if (_clickBtn) {
        self.clickBtn.frame = self.bounds;
    }
}

- (void)clearAllDatas
{
    _itemCount = 0;

    for (UIView *subView in self.subviews) {
        [subView removeFromSuperview];
    }
    
    self.frame = CGRectZero;
}

@end
