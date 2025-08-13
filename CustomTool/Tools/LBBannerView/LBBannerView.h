//
//  LBBannerView.h
//
//  Created by Liubo on 2025/1/10.
//

#import <UIKit/UIKit.h>

typedef enum {
    //不展示
    LBBannerViewDataShowTypeNone,
    //轮播，需要实现LBBannerViewRunLoopDelegate
    LBBannerViewDataShowTypeRunLoop,
    //渐变动效，需要实现LBBannerViewAlphaDelegate
    LBBannerViewDataShowTypeAlphaAnimation
}LBBannerViewDataShowType;//bannerView中数据展示方式

/**
 轮播逻辑enum
 */
typedef enum {
    //不轮询，则控件按照从左到右或者从上到下的顺序排列
    LBBannerViewRunLoopTypeNone,
    
    //自动轮播（默认），设置此值并且bannerViewShowViewDataObjectList返回的数组数量大于1时，才会真正自动轮播
    LBBannerViewRunLoopTypeAuto,
    
    //手动轮播，设置此值并且bannerViewShowViewDataObjectList返回的数组数量大于1时，才可以滑动时轮播
    LBBannerViewRunLoopTypeByHand
}LBBannerViewRunLoopType;//轮询方式（轮询逻辑中使用）

typedef enum {
    LBBannerViewRunLoopOrientationNone,//不滚动，竖向显示出所有内容，宽度按照bannerView的宽度设置
    LBBannerViewRunLoopOrientationHorizontalLeft,//横向向左
    LBBannerViewRunLoopOrientationHorizontalRight,//横向向右
    LBBannerViewRunLoopOrientationVerticalTop,//竖向向上
    LBBannerViewRunLoopOrientationVerticalBottom//竖向向下
}LBBannerViewRunLoopOrientation;//滚动方向（轮询逻辑中使用）

typedef enum {
    LBBannerViewRunLoopDidScrollStatusNone,//没有滚动
    LBBannerViewRunLoopDidScrollStatusHorizontalLeft,//横向向左滚动
    LBBannerViewRunLoopDidScrollStatusHorizontalRight,//横向向右滚动
    LBBannerViewRunLoopDidScrollStatusVerticalTop,//竖向向上滚动
    LBBannerViewRunLoopDidScrollStatusVerticalBottom//竖向向下滚动
}LBBannerViewRunLoopDidScrollStatus;//正在滚动的方向（轮询逻辑中使用）


/**
 渐变动效逻辑enum
 */
typedef enum {
    LBBannerViewAlphaAutoSizeTypeNone,//不自适应size，则按照bannerView的宽高来显示itemView
    LBBannerViewAlphaAutoSizeTypeWidth,//自适应宽度
    LBBannerViewAlphaAutoSizeTypeHeight //自适应高度
}LBBannerViewAlphaAutoSizeType;//渐变动效尺寸变化方式（渐变动画切换逻辑中使用）

@class LBBannerView;

@protocol LBBannerViewRunLoopDelegate <NSObject>
/**
 轮播的方式
 */
- (LBBannerViewRunLoopType)bannerViewRunLoopType:(LBBannerView *_Nonnull)bannerView;

/**
 轮播方向
 */
- (LBBannerViewRunLoopOrientation)bannerViewRunLoopOrientation:(LBBannerView *_Nonnull)bannerView;

/**
 是否自适应高或宽，默认为NO(按照设置的bannerView的size显示)；
 为YES时，则自适应当前显示的view的高或宽，横向滚动时，为自适应高度，竖向滚动时，为自适应宽度
 */
- (BOOL)bannerViewSizeNeedAuto:(LBBannerView *_Nonnull)bannerView;

/**
 banner的数据数组
 */
- (NSArray *_Nullable)bannerViewShowViewDataObjectList:(LBBannerView *_Nonnull)bannerView;

/**
 根据每一个数据obj组装view并返回，其中宽度会自动更改为bannerView的宽度
 */
- (UIView *_Nonnull)bannerView:(LBBannerView *_Nonnull)bannerView getViewForObject:(NSObject *_Nonnull)obj;

/**
 轮播动画间隔时间，默认5秒，返回<=0的值则设置成默认值
 */
- (CGFloat)bannerViewChangeDelayTime:(LBBannerView *_Nonnull)bannerView;

/**
 轮播动画执行动画的时间，默认0.25秒，返回<=0的值则设置成默认值
 */
- (CGFloat)bannerViewChangeAnimationTime:(LBBannerView *_Nonnull)bannerView;

/**
 bannerView的frame改变了，如果使用的约束来设置bannerView的size，可以在此回调方法中通过bannerView获取frame来更新bannerView的约束
 */
- (void)bannerViewFrameDidChanged:(LBBannerView *_Nonnull)bannerView;

/**
 bannerView中UIScrollView滚动时的回调
 
 didScrollStatus：滚动的状态，LBBannerViewDidScrollStatusNone时为停止滚动
 scrollPercent：滚动的百分比（0.0 ~ 1.0），从这一页到目标页，滚动的百分比
 bannerViewSize：bannerView在滚动时的size
 willShowDataIndexNum：将要显示的view对应的数据的index的NSNumber对象，didScrollStatus为LBBannerViewDidScrollStatusNone时会设置成nil
 willShowView：将要显示的view，didScrollStatus为LBBannerViewDidScrollStatusNone时会设置成nil
 */
- (void)bannerView:(LBBannerView *_Nonnull)bannerView scrollViewDidScrollWithScrollView:(UIScrollView *_Nonnull)scrollView didScrollStatus:(LBBannerViewRunLoopDidScrollStatus)didScrollStatus scrollPercent:(CGFloat)scrollPercent bannerViewSize:(CGSize)bannerViewSize willShowDataIndexNum:(NSNumber *_Nullable)willShowDataIndexNum willShowView:(UIView *__nullable)willShowView;

/**
 已经展示的数据index，和已经展示的view
 */
- (void)bannerView:(LBBannerView *_Nonnull)bannerView scrollViewEndDeceleratingWithShowDataIndexNum:(NSNumber *_Nonnull)showDataIndexNum showView:(UIView *_Nonnull)showView;

@end

@protocol LBBannerViewAlphaDelegate <NSObject>

/**
 banner的数据数组
 */
- (NSArray *_Nullable)bannerViewAlphaShowViewDataObjectList:(LBBannerView *_Nonnull)bannerView;

/**
 根据每一个数据obj组装view并返回，其中宽度会自动更改为bannerView的宽度
 */
- (UIView *_Nonnull)bannerView:(LBBannerView *_Nonnull)bannerView getViewAlphaForObject:(NSObject *_Nonnull)obj;

/**
 自适应size的方式，默认为LBBannerViewAlphaAutoSizeTypeNone；
 */
- (LBBannerViewAlphaAutoSizeType)bannerViewAlphaAutoSizeType:(LBBannerView *_Nonnull)bannerView;

/**
 渐变动画间隔时间，默认5秒，返回<=0的值则设置成默认值
 */
- (CGFloat)bannerViewAlphaChangeDelayTime:(LBBannerView *_Nonnull)bannerView;

/**
 渐变动画执行动画的时间，默认0.25秒，返回<=0的值则设置成默认值
 */
- (CGFloat)bannerViewAlphaChangeAnimationTime:(LBBannerView *_Nonnull)bannerView;

/**
 bannerView的frame改变了，如果使用的约束来设置bannerView的size，可以在此回调方法中通过bannerView获取frame来更新bannerView的约束
 */
- (void)bannerViewAlphaFrameDidChanged:(LBBannerView *_Nonnull)bannerView;

/**
 渐变动画将要执行
 */
- (void)bannerView:(LBBannerView *_Nonnull)bannerView alphaAnimationWillExecuteWithWillShowDataIndexNum:(NSNumber *_Nonnull)willShowDataIndexNum willShowView:(UIView *__nullable)willShowView;

/**
 渐变动画正在进行
 */
- (void)bannerView:(LBBannerView *_Nonnull)bannerView bannerViewSize:(CGSize)bannerViewSize alphaAnimationExecutingWithChangePercent:(CGFloat)changePercent willShowDataIndexNum:(NSNumber *_Nonnull)willShowDataIndexNum willShowView:(UIView *__nullable)willShowView;

/**
 渐变动画执行完毕
 */
- (void)bannerView:(LBBannerView *_Nonnull)bannerView alphaAnimationDidEndWithDidShowDataIndexNum:(NSNumber *_Nonnull)didShowDataIndexNum didShowView:(UIView *__nullable)didShowView;

@end

@protocol LBBannerViewIndicatorDelegate <NSObject>
/**
 指示器未选中状态View，需要设置好宽高
 */
- (UIView *_Nonnull)bannerViewIndicatorNormalView:(LBBannerView *_Nonnull)bannerView;

/**
 指示器选中状态View，需要设置好宽高
 */
- (UIView *_Nonnull)bannerViewIndicatorSelectedView:(LBBannerView *_Nonnull)bannerView;

/**
 指示器是否能点击（默认NO）
 YES时，则点一下就显示下一个
 NO时，点击到指示器处没反应
 */
- (BOOL)bannerViewIndicatorCanClick:(LBBannerView *_Nonnull)bannerView;

/**
 指示器是否需要在将要展示view时来变更选中（默认YES）
 YES时，在将要展示view时执行变更选中
 NO时，在view展示完成后再变更选中
 */
- (BOOL)bannerViewIndicatorChangedOnWillShowView:(LBBannerView *_Nonnull)bannerView;

/**
 指示器item之间的空隙，默认0，返回<0的值则设置成默认值
 */
- (CGFloat)bannerViewIndicatorItemToItemSpace:(LBBannerView *_Nonnull)bannerView;

/**
 指示器是否居中，为YES时，距离左侧或距离顶部的空隙的设置 不起作用；为NO时，按照 距离左侧或距离顶部的空隙的设置 来显示
 */
- (BOOL)bannerViewIndicatorIsCenter:(LBBannerView *_Nonnull)bannerView;

/**
 指示器距离底部或距离右侧的空隙，默认0;
 当LBBannerViewScrollOrientation为LBBannerViewScrollOrientationHorizontalLeft或LBBannerViewScrollOrientationHorizontalRight时为距离底部的空隙;
 当LBBannerViewScrollOrientation为LBBannerViewScrollOrientationHorizontalTop或LBBannerViewScrollOrientationHorizontalBottom时为距离右侧的空隙
 */
- (CGFloat)bannerViewIndicatorBottomOrRightSpace:(LBBannerView *_Nonnull)bannerView;

/**
 指示器距离左侧或距离顶部的空隙，默认0；
 当LBBannerViewScrollOrientation为LBBannerViewScrollOrientationHorizontalLeft或LBBannerViewScrollOrientationHorizontalRight时为距离左侧的空隙；
 当LBBannerViewScrollOrientation为LBBannerViewScrollOrientationHorizontalTop或LBBannerViewScrollOrientationHorizontalBottom时为距离顶部的空隙
 */
- (CGFloat)bannerViewIndicatorLeftOrTopSpace:(LBBannerView *_Nonnull)bannerView;

@end

NS_ASSUME_NONNULL_BEGIN

@interface LBBannerView : UIView
@property (nonatomic,assign) id<LBBannerViewRunLoopDelegate> runloopDelegate;

@property (nonatomic,assign) id<LBBannerViewAlphaDelegate> alphaDelegate;

//实现了indicatorDelegate就会显示指示器
@property (nonatomic,assign) id<LBBannerViewIndicatorDelegate> indicatorDelegate;

- (void)showBannerViewAllDatasWithShowType:(LBBannerViewDataShowType)showType;

//清除所有数据，将清除scrollView以及scrollView内所有子view，并清除缓存数据
- (void)cleanAllDatas;
@end

NS_ASSUME_NONNULL_END
