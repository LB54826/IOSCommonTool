//
//  LikeTanTanCardViewDelegate.h
//
//  Created by lb on 2018/10/24.
//  Copyright © 2018年 All rights reserved.
//

#ifndef LikeTanTanCardViewDelegate_h
#define LikeTanTanCardViewDelegate_h


#endif /* LikeTanTanCardViewDelegate_h */


typedef enum {
    CardStandOutOrientationTop,//向上突出
    CardStandOutOrientationBottom,//向下突出
    CardStandOutOrientationLeft,//向左突出
    CardStandOutOrientationRight//向右突出
}CardStandOutOrientation;//卡片突出的方向

@class LikeTanTanCardView;
@protocol LikeTanTanCardViewDelegate <NSObject>
@optional
- (CGFloat)cardViewCardToCardSpace:(LikeTanTanCardView *)cardView;//卡片和卡片之间的间隙（即左右缩进去的距离和底部露出的距离或者上部露出的距离）
- (CardStandOutOrientation)cardViewCardStandOutOrientation:(LikeTanTanCardView *)cardView;//卡片突出的方向
- (CGFloat)cardViewCardCornerRadius:(LikeTanTanCardView *)cardView;//卡片圆角
//movingAlpha:从左边缘到右边缘，值为-1~1，为正时是在左侧，为负时是在右侧
- (void)cardView:(LikeTanTanCardView *)cardView movingWithIndex:(NSInteger)index movingAlpha:(CGFloat)movingAlpha;
- (CGFloat)cardViewSensitiveForMove:(LikeTanTanCardView *)cardView;//移动的灵敏度（卡片宽度一半的百分比，越小灵敏度越高，默认是 1.0 / 3.0）
- (BOOL)cardViewCannotMove:(LikeTanTanCardView *)cardView;//返回YES，卡片将不能移动，默认为NO
- (BOOL)cardViewOnlyHorizontalLeftAndRightMoveOut:(LikeTanTanCardView *)cardView;//卡片只支持水平向左或水平向右划走，默认为NO；为YES时，移动卡片时将没有旋转动效
- (BOOL)cardViewShowCardContentViewNeedAlphaAnimation:(LikeTanTanCardView *)cardView;//显示卡片上内容时是否需要渐变动画，默认为YES-需要动画
- (UIColor *)cardViewShadowColor:(LikeTanTanCardView *)cardView;//阴影颜色
- (CGSize)cardViewShadowOffset:(LikeTanTanCardView *)cardView;//阴影偏移量
- (float)cardViewShadowOpacity:(LikeTanTanCardView *)cardView;//阴影透明度
- (CGFloat)cardViewShadowRadius:(LikeTanTanCardView *)cardView;//阴影半径
- (UIBezierPath *)cardViewShadowPath:(LikeTanTanCardView *)cardView;//阴影路径
@required
- (void)cardView:(LikeTanTanCardView *)cardView moveEndWithIndex:(NSInteger)index moveToLeft:(BOOL)moveToLeft;//卡片移除完毕，moveToLeft：YES-从左边移除，NO-从右边移除
- (NSInteger)cardViewShowAnimationViewCount:(LikeTanTanCardView *)cardView;//要显示动画卡片的个数
- (NSInteger)cardViewWillShowCardTotalCount:(LikeTanTanCardView *)cardView;//将要展示的卡片总数
- (CGSize)cardViewCardShowSize:(LikeTanTanCardView *)cardView;//卡片的宽高
- (UIView *)cardView:(LikeTanTanCardView *)cardView topCardShowViewWithIndex:(NSInteger)index;//顶层展示的View
@end
