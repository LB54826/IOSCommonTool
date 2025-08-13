//
//  CardViewController.m
//  CustomTool
//
//  Created by Liubo on 2025/8/13.
//

#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height

#define kPageSize 6
#define kShowPageCount 1

#import "CardViewController.h"
#import "LikeTanTanCardView.h"

@interface CardViewController ()<LikeTanTanCardViewDelegate>
{
    NSMutableArray *_datasArr;
    NSInteger _currentPage;
    NSInteger _currentShowIndex;
}
@property (nonatomic, strong) LikeTanTanCardView *cardView;
@end

@implementation CardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _currentPage = 1;
    _datasArr = [NSMutableArray array];
    for (int i = 0; i < kPageSize; i++) {
        [_datasArr addObject:[NSString stringWithFormat:@"%d",i]];
    }
    
    [self.cardView showLikeTanTanCardViewWithPoint:CGPointMake(10, 130)];
    [self.cardView reloadDataWithCurrentShowIndex:_currentShowIndex];
    [self.view addSubview:self.cardView];
}

- (LikeTanTanCardView *)cardView
{
    if (!_cardView) {
        _cardView = [[LikeTanTanCardView alloc] init];
        _cardView.delegate = self;
    }
    return _cardView;
}

- (UIColor *)randomColor {
    static BOOL seeded = NO;
    if (!seeded) {
        seeded = YES;
        (time(NULL));
    }
    CGFloat red = (CGFloat)random() / (CGFloat)RAND_MAX;
    CGFloat green = (CGFloat)random() / (CGFloat)RAND_MAX;
    CGFloat blue = (CGFloat)random() / (CGFloat)RAND_MAX;
    return [UIColor colorWithRed:red green:green blue:blue alpha:1.0f];
}
#pragma mark - LikeTanTanCardViewDelegate
- (CGFloat)cardViewCardToCardSpace:(LikeTanTanCardView *)cardView //卡片和卡片之间的间隙（即左右缩进去的距离和底部露出的距离或者上部露出的距离）
{
    return 10;
}
- (CardStandOutOrientation)cardViewCardStandOutOrientation:(LikeTanTanCardView *)cardView//卡片突出的方向
{
    return CardStandOutOrientationTop;
}
- (CGFloat)cardViewCardCornerRadius:(LikeTanTanCardView *)cardView//卡片圆角
{
    return 5;
}
//movingAlpha:从左边缘到右边缘，值为-1~1，为正时是在右侧，为负时是在左侧
- (void)cardView:(LikeTanTanCardView *)cardView movingWithIndex:(NSInteger)index movingAlpha:(CGFloat)movingAlpha
{
    
}
- (BOOL)cardViewOnlyHorizontalLeftAndRightMoveOut:(LikeTanTanCardView *)cardView//卡片只支持水平向左或水平向右划走，默认为NO；为YES时，移动卡片时将没有旋转动效
{
    return NO;
}
- (BOOL)cardViewNeedShowLastOneEmptyCard:(LikeTanTanCardView *)cardView//是否需要显示最后一个空的卡片，默认为YES-显示
{
    return NO;
}
- (CGFloat)cardViewSensitiveForMove:(LikeTanTanCardView *)cardView//移动的灵敏度（卡片宽度一半的百分比，越小灵敏度越高，默认是 1.0 / 3.0）
{
    return 3;
}
- (void)cardView:(LikeTanTanCardView *)cardView moveEndWithIndex:(NSInteger)index moveToLeft:(BOOL)moveToLeft//卡片移除完毕，moveToLeft：YES-从左边移除，NO-从右边移除
{
    if (moveToLeft) {
        NSLog(@"左移除=========%ld",(long)index);
        if (_datasArr.count - (index + 1) == 3) {
            [self afterRemoveToDoSomething];
        }
    } else {
        NSLog(@"右移除=========%ld",(long)index);
        if (_datasArr.count - (index + 1) == 3) {
            [self afterRemoveToDoSomething];
        }
    }
}
- (NSInteger)cardViewShowAnimationViewCount:(LikeTanTanCardView *)cardView//要显示动画卡片的个数
{
    return 4;
}
- (NSInteger)cardViewWillShowCardTotalCount:(LikeTanTanCardView *)cardView//将要展示的卡片总数
{
    return _datasArr.count;
}
- (CGSize)cardViewCardShowSize:(LikeTanTanCardView *)cardView//卡片的宽高
{
    return CGSizeMake(kScreenWidth - 10 * 2.0, kScreenWidth - 10 * 2.0);
}
- (UIView *)cardView:(LikeTanTanCardView *)cardView topCardShowViewWithIndex:(NSInteger)index//顶层展示的View
{
    _currentShowIndex = index;
    UIView *showView = [[UIView alloc] init];
    showView.backgroundColor = [self randomColor];
    showView.layer.cornerRadius = 5;
    showView.layer.masksToBounds = YES;
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 70, 70)];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:44 weight:UIFontWeightSemibold];
    label.textColor = [UIColor blackColor];
    label.text = [NSString stringWithFormat:@"%@",_datasArr[index]];
    [showView addSubview:label];
    return showView;
}

#pragma mark - other
- (void)afterRemoveToDoSomething
{
    if (_currentPage == kShowPageCount) return;
    _currentPage++;
    NSInteger currentInt = _datasArr.count;
    for (NSInteger i = currentInt; i < currentInt + kPageSize; i++) {
        [_datasArr addObject:[NSString stringWithFormat:@"%ld",(long)i]];
    }
}

@end
