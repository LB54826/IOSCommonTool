//
//  BannerViewController.m
//  CustomTool
//
//  Created by Liubo on 2025/8/13.
//

#import "BannerViewController.h"
#import "LBBannerView.h"
#import "LBBannerItemView.h"

#import "Masonry.h"

@interface BannerViewController ()<LBBannerViewRunLoopDelegate,LBBannerViewAlphaDelegate,LBBannerViewIndicatorDelegate>
@property (nonatomic, strong) LBBannerView *bannerView;
@end

@implementation BannerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.bannerView];
    [self.bannerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@40);
        make.top.equalTo(@300);
        make.width.equalTo(@300);
        make.height.equalTo(@100);
    }];
    
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectZero];
    bottomView.backgroundColor = [UIColor orangeColor];
    [self.view addSubview:bottomView];
    
    [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@10);
        make.right.equalTo(@(-10));
        make.height.equalTo(@40);
        make.top.equalTo(self.bannerView.mas_bottom).offset(5);
    }];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.bannerView cleanAllDatas];
    [self.bannerView showBannerViewAllDatasWithShowType:LBBannerViewDataShowTypeRunLoop];
}

- (LBBannerView *)bannerView
{
    if (!_bannerView) {
        _bannerView = [[LBBannerView alloc] initWithFrame:CGRectZero];
        _bannerView.runloopDelegate = self;
        _bannerView.alphaDelegate = self;
        _bannerView.indicatorDelegate = self;
        _bannerView.backgroundColor = [UIColor yellowColor];
    }
    return _bannerView;
}

#pragma mark - LBBannerViewRunLoopDelegate
//是否需要轮播（默认YES），只有此方法返回YES，并且bannerViewShowViewDataObjectList返回的数组数量大于1时，才会真正可以轮播，返回NO时，子view按照从左到右或者从上到下的顺序排列
- (LBBannerViewRunLoopType)bannerViewRunLoopType:(LBBannerView *)bannerView
{
    return LBBannerViewRunLoopTypeAuto;
}

/**
 轮播方向
 */
- (LBBannerViewRunLoopOrientation)bannerViewRunLoopOrientation:(LBBannerView *_Nonnull)bannerView
{
    return LBBannerViewRunLoopOrientationHorizontalLeft;
}

//是否自适应高或宽，默认为NO(按照设置的bannerView的size显示)；为YES时，则自适应当前显示的view的高或宽，横向滚动时，为自适应高度，竖向滚动时，为自适应宽度
- (BOOL)bannerViewSizeNeedAuto:(LBBannerView *_Nonnull)bannerView
{
    return YES;
}

//banner的数据数组
- (NSArray *_Nullable)bannerViewShowViewDataObjectList:(LBBannerView *_Nonnull)bannerView
{
    NSMutableArray *objArr = [NSMutableArray array];
    [objArr addObject:@"1"];
    [objArr addObject:@"2"];
    return objArr;
}

//根据每一个数据obj组装view并返回，其中宽度会自动更改为bannerView的宽度
- (UIView *_Nonnull)bannerView:(LBBannerView *_Nonnull)bannerView getViewForObject:(NSObject *_Nonnull)obj
{
    NSString *objStr = (NSString *)obj;
    LBBannerItemView *item = [[NSBundle mainBundle] loadNibNamed:@"LBBannerItemView" owner:self options:nil][0];
    [item showBannerItemWithString:objStr];
    if ([objStr isEqualToString:@"1"]) {
        CGRect frame = item.frame;
        frame.size.height = 300;
        item.frame = frame;
    } else {
        CGRect frame = item.frame;
        frame.size.height = 150;
        item.frame = frame;
    }
    return item;
}

//轮播动画间隔时间，默认5秒，返回<=0的值则设置成默认值
- (CGFloat)bannerViewChangeDelayTime:(LBBannerView *_Nonnull)bannerView
{
    return 2;
}

//轮播动画执行动画的时间，默认0.25秒，返回<=0的值则设置成默认值
- (CGFloat)bannerViewChangeAnimationTime:(LBBannerView *_Nonnull)bannerView
{
    return 0.25;
}

- (void)bannerViewFrameDidChanged:(LBBannerView *)bannerView
{
    [bannerView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(bannerView.frame.size.width));
        make.height.equalTo(@(bannerView.frame.size.height));
    }];
}

- (void)bannerView:(LBBannerView * _Nonnull)bannerView scrollViewEndDeceleratingWithShowDataIndexNum:(NSNumber * _Nonnull)showDataIndexNum showView:(UIView * _Nonnull)showView {
    
}

- (void)bannerView:(LBBannerView * _Nonnull)bannerView scrollViewDidScrollWithScrollView:(UIScrollView * _Nonnull)scrollView didScrollStatus:(LBBannerViewRunLoopDidScrollStatus)didScrollStatus scrollPercent:(CGFloat)scrollPercent bannerViewSize:(CGSize)bannerViewSize willShowDataIndexNum:(NSNumber * _Nullable)willShowDataIndexNum willShowView:(UIView * _Nullable)willShowView {
    NSLog(@"UseLBBannerView--didScroll--offsetX:%f--offsetY:%f--bannerSizeWidth:%f--bannerSizeHeight:%f--scrollPercent:%f--willShowDataIndex:%ld",scrollView.contentOffset.x,scrollView.contentOffset.y,bannerViewSize.width,bannerViewSize.height,scrollPercent,willShowDataIndexNum ? [willShowDataIndexNum integerValue] : -1);
}

#pragma mark - LBBannerViewAlphaDelegate
/**
 banner的数据数组
 */
- (NSArray *_Nullable)bannerViewAlphaShowViewDataObjectList:(LBBannerView *_Nonnull)bannerView
{
    NSMutableArray *objArr = [NSMutableArray array];
    [objArr addObject:@"1"];
    [objArr addObject:@"2"];
    return objArr;
}

/**
 根据每一个数据obj组装view并返回，其中宽度会自动更改为bannerView的宽度
 */
- (UIView *_Nonnull)bannerView:(LBBannerView *_Nonnull)bannerView getViewAlphaForObject:(NSObject *_Nonnull)obj
{
    NSString *objStr = (NSString *)obj;
    LBBannerItemView *item = [[NSBundle mainBundle] loadNibNamed:@"LBBannerItemView" owner:self options:nil][0];
    [item showBannerItemWithString:objStr];
    if ([objStr isEqualToString:@"1"]) {
        CGRect frame = item.frame;
        frame.size.height = 100;
        item.frame = frame;
    } else {
        CGRect frame = item.frame;
        frame.size.height = 100;
        item.frame = frame;
    }
    return item;
}

/**
 自适应size的方式，默认为LBBannerViewAlphaAutoSizeTypeNone；
 */
- (LBBannerViewAlphaAutoSizeType)bannerViewAlphaAutoSizeType:(LBBannerView *_Nonnull)bannerView
{
    return LBBannerViewAlphaAutoSizeTypeHeight;
}

/**
 渐变动画间隔时间，默认5秒，返回<=0的值则设置成默认值
 */
- (CGFloat)bannerViewAlphaChangeDelayTime:(LBBannerView *_Nonnull)bannerView
{
    return 2;
}

/**
 渐变动画执行动画的时间，默认0.25秒，返回<=0的值则设置成默认值
 */
- (CGFloat)bannerViewAlphaChangeAnimationTime:(LBBannerView *_Nonnull)bannerView
{
    return 0.5;
}

/**
 bannerView的frame改变了，如果使用的约束来设置bannerView的size，可以在此回调方法中通过bannerView获取frame来更新bannerView的约束
 */
- (void)bannerViewAlphaFrameDidChanged:(LBBannerView *_Nonnull)bannerView
{
    [bannerView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(bannerView.frame.size.width));
        make.height.equalTo(@(bannerView.frame.size.height));
    }];
}

/**
 渐变动画将要执行
 */
- (void)bannerView:(LBBannerView *_Nonnull)bannerView alphaAnimationWillExecuteWithWillShowDataIndexNum:(NSNumber *_Nonnull)willShowDataIndexNum willShowView:(UIView *__nullable)willShowView
{
    
}

/**
 渐变动画正在进行
 */
- (void)bannerView:(LBBannerView *_Nonnull)bannerView bannerViewSize:(CGSize)bannerViewSize alphaAnimationExecutingWithChangePercent:(CGFloat)changePercent willShowDataIndexNum:(NSNumber *_Nonnull)willShowDataIndexNum willShowView:(UIView *__nullable)willShowView
{
    
}

/**
 渐变动画执行完毕
 */
- (void)bannerView:(LBBannerView *_Nonnull)bannerView alphaAnimationDidEndWithDidShowDataIndexNum:(NSNumber *_Nonnull)didShowDataIndexNum didShowView:(UIView *__nullable)didShowView
{
    
}

#pragma mark - LBBannerViewIndicatorDelegate
/**
 指示器未选中状态View，需要设置好宽高
 */
- (UIView *_Nonnull)bannerViewIndicatorNormalView:(LBBannerView *_Nonnull)bannerView
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 5)];
    view.backgroundColor = [UIColor blueColor];
    view.layer.cornerRadius = 2.5;
    view.layer.masksToBounds = YES;
    return view;
}

/**
 指示器选中状态View，需要设置好宽高
 */
- (UIView *_Nonnull)bannerViewIndicatorSelectedView:(LBBannerView *_Nonnull)bannerView
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 5)];
    view.backgroundColor = [UIColor orangeColor];
    view.layer.cornerRadius = 2.5;
    view.layer.masksToBounds = YES;
    return view;
}

/**
 指示器是否能点击（默认NO）
 YES时，则点一下就显示下一个
 NO时，点击到指示器处没反应
 */
- (BOOL)bannerViewIndicatorCanClick:(LBBannerView *_Nonnull)bannerView
{
    return YES;
}

/**
 指示器是否需要在将要展示view时来变更选中（默认YES）
 YES时，在将要展示view时执行变更选中
 NO时，在view展示完成后再变更选中
 */
- (BOOL)bannerViewIndicatorChangedOnWillShowView:(LBBannerView *_Nonnull)bannerView
{
    return YES;
}

/**
 指示器item之间的空隙，默认0，返回<0的值则设置成默认值
 */
- (CGFloat)bannerViewIndicatorItemToItemSpace:(LBBannerView *_Nonnull)bannerView
{
    return 5;
}

/**
 指示器是否居中，为YES时，距离左侧或距离顶部的空隙的设置 不起作用；为NO时，按照 距离左侧或距离顶部的空隙的设置 来显示
 */
- (BOOL)bannerViewIndicatorIsCenter:(LBBannerView *_Nonnull)bannerView
{
    return YES;
}

/**
 指示器距离底部或距离右侧的空隙，默认0;
 当LBBannerViewScrollOrientation为LBBannerViewScrollOrientationHorizontalLeft或LBBannerViewScrollOrientationHorizontalRight时为距离底部的空隙;
 当LBBannerViewScrollOrientation为LBBannerViewScrollOrientationHorizontalTop或LBBannerViewScrollOrientationHorizontalBottom时为距离右侧的空隙
 */
- (CGFloat)bannerViewIndicatorBottomOrRightSpace:(LBBannerView *_Nonnull)bannerView
{
    return 10;
}

/**
 指示器距离左侧或距离顶部的空隙，默认0；
 当LBBannerViewScrollOrientation为LBBannerViewScrollOrientationHorizontalLeft或LBBannerViewScrollOrientationHorizontalRight时为距离左侧的空隙；
 当LBBannerViewScrollOrientation为LBBannerViewScrollOrientationHorizontalTop或LBBannerViewScrollOrientationHorizontalBottom时为距离顶部的空隙
 */
- (CGFloat)bannerViewIndicatorLeftOrTopSpace:(LBBannerView *_Nonnull)bannerView
{
    return 20;
}

@end
