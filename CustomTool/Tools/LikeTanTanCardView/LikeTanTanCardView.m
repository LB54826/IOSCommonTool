//
//  LikeTanTanCardView.m
//
//  Created by liubo on 2018/8/30.
//  Copyright © 2018年 All rights reserved.
//

#define kDefaultMoveSensitive 1.0 / 3.0 //默认移动的灵敏度

#define kCardViewShowScreenWidth [UIScreen mainScreen].bounds.size.width
#define kCardViewShowScreenHeight [UIScreen mainScreen].bounds.size.height

#import "LikeTanTanCardView.h"
@interface LikeTanTanCardView()
{
    CGFloat _cardToCardSpace;
    CGFloat _cardCornerRadius;
    CGFloat _cardMoveSensitive;//移动的灵敏度（卡片宽度一半的百分比）
    BOOL _cardCannotMove;
    BOOL _cardOnlyHorizontalLeftAndRightMoveOut;
    BOOL _cardShowCardContentNeedAlphaAnimation;
    NSInteger _animationCardCount;
    CardStandOutOrientation _standOutOrientation;
    CGSize _cardSize;
    UIView *_topCardShowView;
    UIView *_topCardCurrentShowView;
    UIView *_currentTopCardView;
    
    CGPoint _beginPt;//开始触摸的点
    CGPoint _currentTopCardViewCenter;//顶部卡片的中心点
    CGPoint _topCardBeginCenter;//顶部卡片初始位置的中心点
    NSInteger _currentShowIndex;//当前展示卡片的index值
    NSMutableArray *_bottomCardViewArr;//顶部卡片下边的卡片数组
    CGPoint _velocityPoint;//移动速度Point
    BOOL _touchesOnTop;//触摸在上半部分
    
    BOOL _didCallReloadFunc;
}
@end
@implementation LikeTanTanCardView
- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initCardViewToDo];
    }
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initCardViewToDo];
    }
    return self;
}
- (void)initCardViewToDo
{
    self.backgroundColor = [UIColor clearColor];
    _cardToCardSpace = 10;
    _standOutOrientation = CardStandOutOrientationBottom;
    _cardMoveSensitive = kDefaultMoveSensitive;
    _cardCannotMove = NO;
    _cardOnlyHorizontalLeftAndRightMoveOut = NO;
    _cardShowCardContentNeedAlphaAnimation = YES;
    _currentShowIndex = 0;
    _bottomCardViewArr = [NSMutableArray array];
}
- (void)showLikeTanTanCardViewWithPoint:(CGPoint)cardPoint
{
    if ([self.delegate respondsToSelector:@selector(cardViewCardToCardSpace:)]) {
        _cardToCardSpace = [self.delegate cardViewCardToCardSpace:self];
    }
    if ([self.delegate respondsToSelector:@selector(cardViewCardStandOutOrientation:)]) {
        _standOutOrientation = [self.delegate cardViewCardStandOutOrientation:self];
    }
    if ([self.delegate respondsToSelector:@selector(cardViewSensitiveForMove:)]) {
        _cardMoveSensitive = [self.delegate cardViewSensitiveForMove:self];
        if (_cardMoveSensitive <= 0 || _cardMoveSensitive >= 1) {
            _cardMoveSensitive = kDefaultMoveSensitive;
        }
    }
    if ([self.delegate respondsToSelector:@selector(cardViewShowAnimationViewCount:)]) {
        _animationCardCount = [self.delegate cardViewShowAnimationViewCount:self];
    }
    if ([self.delegate respondsToSelector:@selector(cardViewCardCornerRadius:)]) {
        _cardCornerRadius = [self.delegate cardViewCardCornerRadius:self];
        _cardCornerRadius = _cardCornerRadius < 0 ? 0 : _cardCornerRadius;
    }
    if ([self.delegate respondsToSelector:@selector(cardViewCardShowSize:)]) {
        _cardSize = [self.delegate cardViewCardShowSize:self];
    }
    
    NSInteger spaceViewCount = _animationCardCount - 1;//之所以要减1是因为最上边有一个展示的
    CGRect tantanCardFrame = self.frame;
    tantanCardFrame.origin = cardPoint;
    CGFloat tantanCardWidth = 0;
    CGFloat tantanCardHeight = 0;
    if (_standOutOrientation == CardStandOutOrientationLeft || _standOutOrientation == CardStandOutOrientationRight) {
        tantanCardWidth = _cardSize.width + _cardToCardSpace * spaceViewCount;
    } else {
        tantanCardWidth = _cardSize.width;
    }
    if (_standOutOrientation == CardStandOutOrientationTop || _standOutOrientation == CardStandOutOrientationBottom) {
        tantanCardHeight = _cardSize.height + _cardToCardSpace * spaceViewCount;
    } else {
        tantanCardHeight = _cardSize.height;
    }
    tantanCardFrame.size = CGSizeMake(tantanCardWidth, tantanCardHeight);
    self.frame = tantanCardFrame;
}
- (void)reloadDataWithCurrentShowIndex:(NSInteger)currentIndex
{
    _didCallReloadFunc = YES;
    
    for (UIView *subView in self.subviews) {
        [subView removeFromSuperview];
    }
    [_bottomCardViewArr removeAllObjects];
    
    _currentShowIndex = currentIndex;
    NSInteger willShowTotalCount = [self getWillShowCardTotalCount];
    NSInteger judgeCount = currentIndex <= 0 ? willShowTotalCount : willShowTotalCount - currentIndex;
    NSInteger willAnimationCardCount = judgeCount < _animationCardCount ? judgeCount : _animationCardCount;
    for (int i = 0; i < willAnimationCardCount; i++) {
        CGFloat viewX = 0;
        CGFloat viewWidth = 0;
        CGFloat viewHeight = 0;
        CGFloat viewY = 0;
        if (_standOutOrientation == CardStandOutOrientationTop || _standOutOrientation == CardStandOutOrientationBottom) {
            viewX = _cardToCardSpace * i;
            viewWidth = self.frame.size.width - viewX * 2;
            viewHeight = viewWidth * _cardSize.height / _cardSize.width * 1.0;
            if (_standOutOrientation == CardStandOutOrientationBottom) {
                viewY = _cardSize.height + viewX - viewHeight;
            } else {
                viewY = _cardToCardSpace * (_animationCardCount - 1 - i);
            }
        } else {
            viewY = _cardToCardSpace * i;
            viewHeight = self.frame.size.height - viewY * 2;
            viewWidth = _cardSize.width * viewHeight / _cardSize.height * 1.0;
            if (_standOutOrientation == CardStandOutOrientationLeft) {
                viewX = _cardToCardSpace * (_animationCardCount - 1 - i);
            } else {
                viewX = _cardSize.width + viewY - viewWidth;
            }
        }
        
        
        UIView *animationView = [[UIView alloc] initWithFrame:CGRectMake(viewX, viewY, viewWidth, viewHeight)];
        animationView.backgroundColor = [UIColor whiteColor];
        animationView.layer.cornerRadius = _cardCornerRadius;
        [self insertSubview:animationView atIndex:0];
        if (i == 0) {
            _currentTopCardView = animationView;
            _currentTopCardViewCenter = _currentTopCardView.center;
            _topCardBeginCenter = _currentTopCardViewCenter;
        }
        if (i == _animationCardCount - 1) {
            animationView.alpha = 0;
        }
        [self addShadowForView:animationView];
        if (i > 0) {
            [_bottomCardViewArr addObject:animationView];
        }
    }
    
    [self addCardViewShowView];
    
    _didCallReloadFunc = NO;
}

- (void)addCardViewShowView
{
    if (_didCallReloadFunc && _currentShowIndex > 0 && _topCardCurrentShowView) {
        _topCardCurrentShowView.frame = _currentTopCardView.bounds;
        [_currentTopCardView addSubview:_topCardCurrentShowView];
    } else {
        if ([self.delegate respondsToSelector:@selector(cardView:topCardShowViewWithIndex:)]) {
            _topCardShowView = [self.delegate cardView:self topCardShowViewWithIndex:_currentShowIndex];
        }
        _topCardCurrentShowView = _topCardShowView;
        _topCardShowView.frame = _currentTopCardView.bounds;
        [_currentTopCardView addSubview:_topCardShowView];
    }
    
    __unsafe_unretained LikeTanTanCardView *weakSelf = self;
    if ([self.delegate respondsToSelector:@selector(cardViewShowCardContentViewNeedAlphaAnimation:)]) {
        _cardShowCardContentNeedAlphaAnimation = [self.delegate cardViewShowCardContentViewNeedAlphaAnimation:self];
    }
    if (_didCallReloadFunc && _currentShowIndex > 0) {
        _topCardShowView.alpha = 1;
    } else {
        if (_cardShowCardContentNeedAlphaAnimation) {
            _topCardShowView.alpha = 0;
            [UIView animateWithDuration:0.25 animations:^{
                weakSelf->_topCardShowView.alpha = 1;
            }];
        } else {
            _topCardShowView.alpha = 1;
        }
    }
   
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(currentTopCardPanAction:)];
    [_currentTopCardView addGestureRecognizer:pan];
}
//手动移除卡片，是否是从左侧，YES为左侧，NO为右侧
- (void)removeCardWithDirectionIsLeft:(BOOL)isLeft
{
    CGRect cardWindowFrame = [self convertRect:_currentTopCardView.frame toView:[UIApplication sharedApplication].keyWindow];
    CGRect topCardFrame = _currentTopCardView.frame;
    if (isLeft) {
        topCardFrame.origin.x = topCardFrame.origin.x - CGRectGetMaxX(cardWindowFrame);
        
    } else {
        topCardFrame.origin.x = topCardFrame.origin.x + kCardViewShowScreenWidth - CGRectGetMinX(cardWindowFrame);
    }
    [UIView animateWithDuration:0.5 animations:^{
        self->_currentTopCardView.frame = topCardFrame;
        if (![self isOnlyHorizontalLeftAndRightMoveOut]) {
            //顶部卡片旋转
            if (isLeft) {
                self->_currentTopCardView.transform = CGAffineTransformMakeRotation(-M_PI_4 / 5.0);
            } else {
                self->_currentTopCardView.transform = CGAffineTransformMakeRotation(M_PI_4 / 5.0);
            }
        }
        self->_currentTopCardView.alpha = 0;
        //底部卡片恢复原状
        [self bottomCardAnimationedWithMoveAlpha:1];
    } completion:^(BOOL finished) {
        [self afterRemoveTopCardToDoSomethingWithIsLeftMove:isLeft];
    }];
}
- (void)cardViewRefreshFrameWithCardFrame:(CGRect)cardFrame animationSetFrameBlock:(void (^)(CGRect))animationSetFrameBlock animationFinishedBlock:(void (^)(void))animationFinishedBlock
{
    _cardSize = cardFrame.size;
    NSInteger spaceViewCount = _animationCardCount - 1;//之所以要减1是因为最上边有一个展示的
    CGRect tantanCardFrame = self.frame;
    tantanCardFrame.origin = cardFrame.origin;
    CGFloat tantanCardWidth = 0;
    CGFloat tantanCardHeight = 0;
    if (_standOutOrientation == CardStandOutOrientationLeft || _standOutOrientation == CardStandOutOrientationRight) {
        tantanCardWidth = cardFrame.size.width + _cardToCardSpace * spaceViewCount;
    } else {
        tantanCardWidth = cardFrame.size.width;
    }
    if (_standOutOrientation == CardStandOutOrientationTop || _standOutOrientation == CardStandOutOrientationBottom) {
        tantanCardHeight = cardFrame.size.height + _cardToCardSpace * spaceViewCount;
    } else {
        tantanCardHeight = cardFrame.size.height;
    }
    tantanCardFrame.size = CGSizeMake(tantanCardWidth, tantanCardHeight);
    [UIView animateWithDuration:0.25 animations:^{
        self.frame = tantanCardFrame;
        if (animationSetFrameBlock) {
            animationSetFrameBlock(tantanCardFrame);
        }
    } completion:^(BOOL finished) {
        if (animationFinishedBlock) {
            animationFinishedBlock();
        }
    }];
    
    for (NSInteger i = 0; i < self.subviews.count; i++) {
        UIView *subView = self.subviews[i];
        CGRect frame = subView.frame;
        CGFloat viewWidth = 0;
        CGFloat viewHeight = 0;
        CGFloat viewX = 0;
        CGFloat viewY = 0;
        if (_standOutOrientation == CardStandOutOrientationTop || _standOutOrientation == CardStandOutOrientationBottom) {
            viewX = _cardToCardSpace * (self.subviews.count - 1 - i);
            viewWidth = tantanCardWidth - viewX * 2;
            viewHeight = viewWidth * cardFrame.size.height / cardFrame.size.width * 1.0;
//            if (_standOutOrientation == CardStandOutOrientationBottom) {
//                viewY = cardFrame.size.height + viewX - viewHeight;
//            } else {
//                viewY = _cardToCardSpace * (_animationCardCount - 1 - i);
//            }
        } else {
            viewY = _cardToCardSpace * (self.subviews.count - 1 - i);
            viewHeight = tantanCardHeight - viewY * 2;
            viewWidth = cardFrame.size.width * viewHeight / cardFrame.size.height * 1.0;
//            if (_standOutOrientation == CardStandOutOrientationLeft) {
//                viewX = _cardToCardSpace * (_animationCardCount - 1 - i);
//            } else {
//                viewX = cardFrame.size.width + viewY - viewWidth;
//            }
        }
        frame.size.width = viewWidth;
        frame.size.height = viewHeight;

        [UIView animateWithDuration:0.25 animations:^{
            subView.frame = frame;
            [self addShadowForView:subView];
        } completion:^(BOOL finished) {
            
        }];
    }
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC));
    dispatch_after(popTime,dispatch_get_main_queue(),^(void){
        self->_currentTopCardViewCenter = self->_currentTopCardView.center;
        self->_topCardBeginCenter = self->_currentTopCardViewCenter;
        self->_topCardShowView.frame = self->_currentTopCardView.bounds;
    });
}
#pragma mark - PanGesture 互动
- (void)currentTopCardPanAction:(UIPanGestureRecognizer *)pan
{
    if ([self.delegate respondsToSelector:@selector(cardViewCannotMove:)]) {
        _cardCannotMove = [self.delegate cardViewCannotMove:self];
    }
    if (_cardCannotMove) return;
    if (pan.state == UIGestureRecognizerStateBegan) {
        [self panGestureBegin:pan];
    }
    if (pan.state == UIGestureRecognizerStateChanged) {
        [self panGestureChanged:pan];
    }
    if (pan.state == UIGestureRecognizerStateEnded) {
        [self panGestureEnded:pan];
    }
}

- (void)panGestureBegin:(UIPanGestureRecognizer *)pan
{
    _beginPt = [pan locationInView:_currentTopCardView];
    _touchesOnTop = _beginPt.y <= _currentTopCardViewCenter.y;
}
- (void)panGestureChanged:(UIPanGestureRecognizer *)pan
{
    BOOL isTouchesOutSide = [self isTouchesOutOfCard];
    if (isTouchesOutSide) return;
    CGPoint pt = [pan locationInView:_currentTopCardView];
    CGFloat x = pt.x - _beginPt.x;
    CGFloat y = pt.y - _beginPt.y;
    
    if ([self isOnlyHorizontalLeftAndRightMoveOut]) {
        _currentTopCardView.center = CGPointMake(_currentTopCardViewCenter.x + x, _currentTopCardViewCenter.y);
    } else {
        _currentTopCardView.center = CGPointMake(_currentTopCardViewCenter.x + x, _currentTopCardViewCenter.y + y);
    }
    
    _currentTopCardViewCenter = _currentTopCardView.center;
    CGFloat moveX = _currentTopCardViewCenter.x - _topCardBeginCenter.x;
    
    CGFloat jueDuiMoveX = fabs(moveX);
    CGFloat moveAlpha = 1 - (_cardSize.width / 2.0 - jueDuiMoveX) / (_cardSize.width / 2.0) * 1.0;
    if (moveX < 0) {
        moveAlpha = -1.0 * moveAlpha;
    }
    if (moveAlpha < -1) {
        moveAlpha = -1;
    }
    if (moveAlpha > 1) {
        moveAlpha = 1;
    }
    if ([self.delegate respondsToSelector:@selector(cardView:movingWithIndex:movingAlpha:)]) {
        [self.delegate cardView:self movingWithIndex:_currentShowIndex movingAlpha:moveAlpha];
    }
    NSLog(@"moveAlpha=====%f",moveAlpha);
    //顶部卡片旋转
    CGFloat cardAngle = fabs(moveAlpha) * M_PI_4 / 5.0;
    if ((moveX < 0 && _touchesOnTop) || (moveX > 0 && !_touchesOnTop)) {
        cardAngle = -1.0 * cardAngle;
    }
    if (![self isOnlyHorizontalLeftAndRightMoveOut]) {
        _currentTopCardView.transform = CGAffineTransformMakeRotation(cardAngle);
    }
    //底下卡片逐渐变成顶部卡片大小
    CGFloat jueDuiMoveAlpha = fabs(moveAlpha);
    [self bottomCardAnimationedWithMoveAlpha:jueDuiMoveAlpha];
}
- (void)panGestureEnded:(UIPanGestureRecognizer *)pan
{
    __unsafe_unretained LikeTanTanCardView *weakSelf = self;
    BOOL isTouchesOutSide = [self isTouchesOutOfCard];
    if (isTouchesOutSide) return;
    CGFloat moveXRange = _cardSize.width / 2.0  * _cardMoveSensitive;
    CGPoint velocity = [pan velocityInView:_currentTopCardView];//手指离开时x和y方向速度，单位是points/second
    NSLog(@"SpeedX======%f,SpeedY======%f",velocity.x,velocity.y);
    
    BOOL isInLeft = _currentTopCardViewCenter.x <= _topCardBeginCenter.x;
    BOOL isInTop = _currentTopCardViewCenter.y <= _topCardBeginCenter.y;
    
    if (_currentTopCardViewCenter.x < _topCardBeginCenter.x - moveXRange || _currentTopCardViewCenter.x > _topCardBeginCenter.x + moveXRange) {//超出了拖动范围，松手后移除顶部卡片
        
        BOOL isLeftMove = NO;
        
        CGRect cardWindowFrame = [self convertRect:_currentTopCardView.frame toView:[UIApplication sharedApplication].keyWindow];
        CGRect topCardFrame = _currentTopCardView.frame;
        
        if ([self isOnlyHorizontalLeftAndRightMoveOut]) {
            if (velocity.x == 0 && velocity.y == 0) {
                if (isInLeft) {
                    topCardFrame.origin.x = topCardFrame.origin.x - CGRectGetMaxX(cardWindowFrame);
                    isLeftMove = YES;
                } else {
                    topCardFrame.origin.x = topCardFrame.origin.x + kCardViewShowScreenWidth - CGRectGetMinX(cardWindowFrame);
                    isLeftMove = NO;
                }
            } else {
                if (velocity.x != 0 && velocity.y == 0) {
                    if (velocity.x > 0) {//水平向右
                        topCardFrame.origin.x = topCardFrame.origin.x + kCardViewShowScreenWidth - CGRectGetMinX(cardWindowFrame);
                        isLeftMove = NO;
                    } else {//水平向左
                        topCardFrame.origin.x = topCardFrame.origin.x - CGRectGetMaxX(cardWindowFrame);
                        isLeftMove = YES;
                    }
                } else {//都不为0
                    CGFloat velocityXYProportion = fabs(velocity.x) / fabs(velocity.y) * 1.0;//x和y速度比例
                    if (velocityXYProportion < 0.2) {//近似于垂直
                        if (velocity.y > 0) {//垂直向上
                            if (isInLeft) {
                                topCardFrame.origin.x = topCardFrame.origin.x - CGRectGetMaxX(cardWindowFrame);
                                isLeftMove = YES;
                            } else {
                                topCardFrame.origin.x = topCardFrame.origin.x + kCardViewShowScreenWidth - CGRectGetMinX(cardWindowFrame);
                                isLeftMove = NO;
                            }
                        } else {//垂直向下
                            if (isInLeft) {
                                topCardFrame.origin.x = topCardFrame.origin.x - CGRectGetMaxX(cardWindowFrame);
                                isLeftMove = YES;
                            } else {
                                topCardFrame.origin.x = topCardFrame.origin.x + kCardViewShowScreenWidth - CGRectGetMinX(cardWindowFrame);
                                isLeftMove = NO;
                            }
                        }
                    } else {
                        if (velocity.x < 0 && velocity.y < 0) {//左上
                            topCardFrame.origin.x = topCardFrame.origin.x - CGRectGetMaxX(cardWindowFrame);
                            isLeftMove = YES;
                        } else if (velocity.x < 0 && velocity.y > 0) {//左下
                            topCardFrame.origin.x = topCardFrame.origin.x - CGRectGetMaxX(cardWindowFrame);
                            isLeftMove = YES;
                        } else if (velocity.x > 0 && velocity.y < 0) {//右上
                            CGFloat willMoveRight = kCardViewShowScreenWidth - CGRectGetMinX(cardWindowFrame);
                            topCardFrame.origin.x = topCardFrame.origin.x + willMoveRight;
                            isLeftMove = NO;
                        } else if (velocity.x > 0 && velocity.y > 0) {//右下
                            CGFloat willMoveRight = kCardViewShowScreenWidth - CGRectGetMinX(cardWindowFrame);
                            topCardFrame.origin.x = topCardFrame.origin.x + willMoveRight;
                            isLeftMove = NO;
                        }
                    }
                }
            }
        } else {
            if (velocity.x == 0 && velocity.y == 0) {
                if (isInLeft && isInTop) {//左上
                    topCardFrame.origin.x = topCardFrame.origin.x - CGRectGetMaxX(cardWindowFrame);
                    topCardFrame.origin.y = topCardFrame.origin.y - CGRectGetMaxY(cardWindowFrame);
                    isLeftMove = YES;
                } else if (!isInLeft && isInTop) {//右上
                    topCardFrame.origin.x = topCardFrame.origin.x + kCardViewShowScreenWidth - CGRectGetMinX(cardWindowFrame);
                    topCardFrame.origin.y = topCardFrame.origin.y - CGRectGetMaxY(cardWindowFrame);
                    isLeftMove = NO;
                } else if (isInLeft && !isInTop) {//左下
                    topCardFrame.origin.x = topCardFrame.origin.x - CGRectGetMaxX(cardWindowFrame);
                    topCardFrame.origin.y = topCardFrame.origin.y + kCardViewShowScreenHeight - CGRectGetMinY(cardWindowFrame);
                    isLeftMove = YES;
                } else if (!isInLeft && !isInTop) {//右下
                    topCardFrame.origin.x = topCardFrame.origin.x + kCardViewShowScreenWidth - CGRectGetMinX(cardWindowFrame);
                    topCardFrame.origin.y = topCardFrame.origin.y + kCardViewShowScreenHeight - CGRectGetMinY(cardWindowFrame);
                    isLeftMove = NO;
                }
            } else {
                if (velocity.x != 0 && velocity.y == 0) {
                    if (velocity.x > 0) {//水平向右
                        topCardFrame.origin.x = topCardFrame.origin.x + kCardViewShowScreenWidth - CGRectGetMinX(cardWindowFrame);
                        isLeftMove = NO;
                    } else {//水平向左
                        topCardFrame.origin.x = topCardFrame.origin.x - CGRectGetMaxX(cardWindowFrame);
                        isLeftMove = YES;
                    }
                } else if (velocity.x == 0 && velocity.y != 0) {
                    if (velocity.y > 0) {//垂直向上
                        if (isInLeft) {
                            topCardFrame.origin.x = topCardFrame.origin.x - CGRectGetMaxX(cardWindowFrame);
                            topCardFrame.origin.y = topCardFrame.origin.y - CGRectGetMaxY(cardWindowFrame);
                            isLeftMove = YES;
                        } else {
                            topCardFrame.origin.x = topCardFrame.origin.x + kCardViewShowScreenWidth - CGRectGetMinX(cardWindowFrame);
                            topCardFrame.origin.y = topCardFrame.origin.y - CGRectGetMaxY(cardWindowFrame);
                            isLeftMove = NO;
                        }
                    } else {//垂直向下
                        if (isInLeft) {
                            topCardFrame.origin.x = topCardFrame.origin.x - CGRectGetMaxX(cardWindowFrame);
                            topCardFrame.origin.y = topCardFrame.origin.y + kCardViewShowScreenHeight - CGRectGetMinY(cardWindowFrame);
                            isLeftMove = YES;
                        } else {
                            topCardFrame.origin.x = topCardFrame.origin.x + kCardViewShowScreenWidth - CGRectGetMinX(cardWindowFrame);
                            topCardFrame.origin.y = topCardFrame.origin.y + kCardViewShowScreenHeight - CGRectGetMinY(cardWindowFrame);
                            isLeftMove = NO;
                        }
                    }
                } else {//都不为0
                    CGFloat velocityXYProportion = fabs(velocity.x) / fabs(velocity.y) * 1.0;//x和y速度比例
                    if (velocityXYProportion < 0.2) {//近似于垂直
                        if (velocity.y > 0) {//垂直向上
                            if (isInLeft) {
                                topCardFrame.origin.x = topCardFrame.origin.x - CGRectGetMaxX(cardWindowFrame);
                                topCardFrame.origin.y = topCardFrame.origin.y - CGRectGetMaxY(cardWindowFrame);
                                isLeftMove = YES;
                            } else {
                                topCardFrame.origin.x = topCardFrame.origin.x + kCardViewShowScreenWidth - CGRectGetMinX(cardWindowFrame);
                                topCardFrame.origin.y = topCardFrame.origin.y - CGRectGetMaxY(cardWindowFrame);
                                isLeftMove = NO;
                            }
                        } else {//垂直向下
                            if (isInLeft) {
                                topCardFrame.origin.x = topCardFrame.origin.x - CGRectGetMaxX(cardWindowFrame);
                                topCardFrame.origin.y = topCardFrame.origin.y + kCardViewShowScreenHeight - CGRectGetMinY(cardWindowFrame);
                                isLeftMove = YES;
                            } else {
                                topCardFrame.origin.x = topCardFrame.origin.x + kCardViewShowScreenWidth - CGRectGetMinX(cardWindowFrame);
                                topCardFrame.origin.y = topCardFrame.origin.y + kCardViewShowScreenHeight - CGRectGetMinY(cardWindowFrame);
                                isLeftMove = NO;
                            }
                        }
                    } else {
                        if (velocity.x < 0 && velocity.y < 0) {//左上
                            CGFloat willMoveLeft = CGRectGetMaxX(cardWindowFrame);
                            CGFloat wlllMoveTop = willMoveLeft / velocityXYProportion * 1.0;
                            topCardFrame.origin.x = topCardFrame.origin.x - CGRectGetMaxX(cardWindowFrame);
                            topCardFrame.origin.y = topCardFrame.origin.y - wlllMoveTop;
                            isLeftMove = YES;
                        } else if (velocity.x < 0 && velocity.y > 0) {//左下
                            CGFloat willMoveLeft = CGRectGetMaxX(cardWindowFrame);
                            CGFloat wlllMoveTop = willMoveLeft / velocityXYProportion * 1.0;
                            topCardFrame.origin.x = topCardFrame.origin.x - CGRectGetMaxX(cardWindowFrame);
                            topCardFrame.origin.y = topCardFrame.origin.y + wlllMoveTop;
                            isLeftMove = YES;
                        } else if (velocity.x > 0 && velocity.y < 0) {//右上
                            CGFloat willMoveRight = kCardViewShowScreenWidth - CGRectGetMinX(cardWindowFrame);
                            CGFloat willMoveTop = willMoveRight / velocityXYProportion * 1.0;
                            topCardFrame.origin.x = topCardFrame.origin.x + willMoveRight;
                            topCardFrame.origin.y = topCardFrame.origin.y - willMoveTop;
                            isLeftMove = NO;
                        } else if (velocity.x > 0 && velocity.y > 0) {//右下
                            CGFloat willMoveRight = kCardViewShowScreenWidth - CGRectGetMinX(cardWindowFrame);
                            CGFloat willMoveTop = willMoveRight / velocityXYProportion * 1.0;
                            topCardFrame.origin.x = topCardFrame.origin.x + willMoveRight;
                            topCardFrame.origin.y = topCardFrame.origin.y + willMoveTop;
                            isLeftMove = NO;
                        }
                    }
                }
            }
        }
        
        [UIView animateWithDuration:0.25 animations:^{
            weakSelf->_currentTopCardView.frame = topCardFrame;
            weakSelf->_currentTopCardView.alpha = 0;
            
            //底部卡片恢复原状
            [weakSelf bottomCardAnimationedWithMoveAlpha:1];
            
        } completion:^(BOOL finished) {
            [weakSelf afterRemoveTopCardToDoSomethingWithIsLeftMove:isLeftMove];
        }];
        
    } else {
        
        //还在拖动范围内，松手后将卡片恢复初始位置
        [UIView animateWithDuration:0.25 animations:^{
            CGPoint firstAnimationEndPoint = weakSelf->_topCardBeginCenter;
            if (isInLeft && isInTop) {
                firstAnimationEndPoint = CGPointMake(weakSelf->_topCardBeginCenter.x + 5, weakSelf->_topCardBeginCenter.y + 5);
            } else if (isInLeft && !isInTop) {
                firstAnimationEndPoint = CGPointMake(weakSelf->_topCardBeginCenter.x + 5, weakSelf->_topCardBeginCenter.y - 5);
            } else if (!isInLeft && isInTop) {
                firstAnimationEndPoint = CGPointMake(weakSelf->_topCardBeginCenter.x - 5, weakSelf->_topCardBeginCenter.y + 5);
            } else if (!isInLeft && !isInTop) {
                firstAnimationEndPoint = CGPointMake(weakSelf->_topCardBeginCenter.x - 5, weakSelf->_topCardBeginCenter.y - 5);
            }
            weakSelf->_currentTopCardView.center = firstAnimationEndPoint;
            //顶部卡片旋转
            weakSelf->_currentTopCardView.transform = CGAffineTransformMakeRotation(0);
            
            //底部卡片恢复原状
            [weakSelf bottomCardAnimationedWithMoveAlpha:0];
            
            if ([weakSelf.delegate respondsToSelector:@selector(cardView:movingWithIndex:movingAlpha:)]) {
                [weakSelf.delegate cardView:self movingWithIndex:weakSelf->_currentShowIndex movingAlpha:0];
            }
            
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.25 animations:^{
                weakSelf->_currentTopCardView.center = weakSelf->_topCardBeginCenter;
            } completion:^(BOOL finished) {
                weakSelf->_currentTopCardViewCenter = weakSelf->_currentTopCardView.center;
            }];
        }];
    }
}

- (void)afterRemoveTopCardToDoSomethingWithIsLeftMove:(BOOL)isLeftMove
{
    //顶部卡片旋转
    _currentTopCardView.transform = CGAffineTransformMakeRotation(0);
    
    for (UIView *topCardSubView in _currentTopCardView.subviews) {
        [topCardSubView removeFromSuperview];
    }
    [_currentTopCardView removeFromSuperview];
    
    //移除完毕调用代理方法
    if ([self.delegate respondsToSelector:@selector(cardView:moveEndWithIndex:moveToLeft:)]) {
        [self.delegate cardView:self moveEndWithIndex:_currentShowIndex moveToLeft:isLeftMove];
    }
    
    NSInteger leavingCount = [self getCurrentShowCardLeavingCount];
    if (leavingCount >= _animationCardCount) {
        CGFloat viewX = _cardToCardSpace * (_animationCardCount - 1);
        CGFloat viewWidth = self.frame.size.width - viewX * 2;
        CGFloat viewHeight = viewWidth * _cardSize.height / _cardSize.width * 1.0;
        CGFloat viewY = _cardSize.height + viewX - viewHeight;
        _currentTopCardView.frame = CGRectMake(viewX, viewY, viewWidth, viewHeight);
        [self insertSubview:_currentTopCardView atIndex:0];
        [_bottomCardViewArr addObject:_currentTopCardView];
    }
    
    if (_bottomCardViewArr.count > 0) {
        UIView *topCardView = _bottomCardViewArr[0];
        _currentTopCardView = topCardView;
        [_bottomCardViewArr removeObjectAtIndex:0];
    }
    
    _currentTopCardViewCenter = _currentTopCardView.center;
    _topCardBeginCenter = _currentTopCardViewCenter;
    
    _currentShowIndex++;
    
    if (leavingCount > 0) {
        [self addCardViewShowView];
    }
}
#pragma mark - other
- (void)bottomCardAnimationedWithMoveAlpha:(CGFloat)moveAlpha
{
    for (int i = 0; i < _bottomCardViewArr.count; i++) {
        UIView *bottomCardView = _bottomCardViewArr[i];
        CGFloat viewWidth = 0;
        CGFloat viewHeight = 0;
        CGFloat viewX = 0;
        CGFloat viewY = 0;
        if (_standOutOrientation == CardStandOutOrientationTop || _standOutOrientation == CardStandOutOrientationBottom) {
            viewWidth = _cardSize.width - _cardToCardSpace * 2 * (i + 1) + (_cardToCardSpace * 2 * moveAlpha);
            viewHeight = viewWidth * _cardSize.height / _cardSize.width * 1.0;
            viewX = (_cardSize.width - viewWidth) / 2.0;
            if (_standOutOrientation == CardStandOutOrientationBottom) {
                viewY = _cardSize.height + viewX - viewHeight;
            } else {
                viewY = _cardToCardSpace * (_bottomCardViewArr.count - 1 - i) + _cardToCardSpace * moveAlpha;
            }
        } else {
            viewHeight = _cardSize.height - _cardToCardSpace * 2 * (i + 1) + (_cardToCardSpace * 2 * moveAlpha);
            viewWidth = _cardSize.width * viewHeight / _cardSize.height * 1.0;
            viewY = (_cardSize.height - viewHeight) / 2.0;
            if (_standOutOrientation == CardStandOutOrientationRight) {
                viewX = _cardSize.width + viewY - viewWidth;
            } else {
                viewX = _cardToCardSpace * (_bottomCardViewArr.count - 1 - i) + _cardToCardSpace * moveAlpha;
            }
        }
        
        bottomCardView.frame = CGRectMake(viewX, viewY, viewWidth, viewHeight);
        [self addShadowForView:bottomCardView];
        if (i == _bottomCardViewArr.count - 1) {
            bottomCardView.alpha = 1 * moveAlpha;
        }
    }
}
- (void)addShadowForView:(UIView *)shadowView
{
    UIColor *shadowColor = [UIColor blackColor];
    if ([self.delegate respondsToSelector:@selector(cardViewShadowColor:)]) {
        shadowColor = [self.delegate cardViewShadowColor:self];
    }
    
    CGSize shadowOffset = CGSizeMake(0,0);
    if ([self.delegate respondsToSelector:@selector(cardViewShadowOffset:)]) {
        shadowOffset = [self.delegate cardViewShadowOffset:self];
    }
    
    float shadowOpacity = 0.15;
    if ([self.delegate respondsToSelector:@selector(cardViewShadowOpacity:)]) {
        shadowOpacity = [self.delegate cardViewShadowOpacity:self];
    }
    
    CGFloat shadowRadius = 8;
    if ([self.delegate respondsToSelector:@selector(cardViewShadowRadius:)]) {
        shadowRadius = [self.delegate cardViewShadowRadius:self];
    }
    
    shadowView.layer.shadowColor = shadowColor.CGColor;//shadowColor阴影颜色
    shadowView.layer.shadowOffset = shadowOffset;//shadowOffset阴影偏移，默认(0, -3),这个跟shadowRadius配合使用
    shadowView.layer.shadowOpacity = shadowOpacity;//阴影透明度，默认0
    shadowView.layer.shadowRadius = shadowRadius;//阴影半径，默认3
    
    //路径阴影
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    float width = shadowView.bounds.size.width;
    float height = shadowView.bounds.size.height;
    float x = shadowView.bounds.origin.x;
    float y = shadowView.bounds.origin.y;
    float addWH = 0;
    
    CGPoint topLeft      = shadowView.bounds.origin;
    CGPoint topMiddle = CGPointMake(x+(width/2),y-addWH);
    CGPoint topRight     = CGPointMake(x+width,y);
    
    CGPoint rightMiddle = CGPointMake(x+width+addWH,y+(height/2));
    
    CGPoint bottomRight  = CGPointMake(x+width,y+height);
    CGPoint bottomMiddle = CGPointMake(x+(width/2),y+height+addWH);
    CGPoint bottomLeft   = CGPointMake(x,y+height);
    
    
    CGPoint leftMiddle = CGPointMake(x-addWH,y+(height/2));
    
    [path moveToPoint:topLeft];
    //添加四个二元曲线
    [path addQuadCurveToPoint:topRight
                 controlPoint:topMiddle];
    [path addQuadCurveToPoint:bottomRight
                 controlPoint:rightMiddle];
    [path addQuadCurveToPoint:bottomLeft
                 controlPoint:bottomMiddle];
    [path addQuadCurveToPoint:topLeft
                 controlPoint:leftMiddle];
    
    UIBezierPath *shadowPath = path;
    if ([self.delegate respondsToSelector:@selector(cardViewShadowPath:)]) {
        shadowPath = [self.delegate cardViewShadowPath:self];
    }
    
    //设置阴影路径
    shadowView.layer.shadowPath = shadowPath.CGPath;
}

- (BOOL)isTouchesOutOfCard
{
    NSInteger leavingCount = [self getCurrentShowCardLeavingCount];
    if (_beginPt.x < 0 || _beginPt.y < 0 || _beginPt.x > self.frame.size.width || _beginPt.y > _cardSize.height || leavingCount < 0) {
        return YES;
    }
    return NO;
}
//获取将要展示的剩下的数量
- (NSInteger)getCurrentShowCardLeavingCount
{
    NSInteger leavingCount = [self getWillShowCardTotalCount] - (_currentShowIndex + 1);
    return leavingCount;
}
- (NSInteger)getWillShowCardTotalCount
{
    NSInteger totalCount = 0;
    if ([self.delegate respondsToSelector:@selector(cardViewWillShowCardTotalCount:)]) {
        totalCount = [self.delegate cardViewWillShowCardTotalCount:self];
    }
    return totalCount;
}

- (BOOL)isOnlyHorizontalLeftAndRightMoveOut
{
    if ([self.delegate respondsToSelector:@selector(cardViewOnlyHorizontalLeftAndRightMoveOut:)]) {
        _cardOnlyHorizontalLeftAndRightMoveOut = [self.delegate cardViewOnlyHorizontalLeftAndRightMoveOut:self];
    }
    return _cardOnlyHorizontalLeftAndRightMoveOut;
}

@end
