//
//  LBBannerView.m
//
//  Created by Liubo on 2025/1/10.
//

#import "LBBannerView.h"
#import <objc/runtime.h>
#import "LBBannerViewScrollView.h"
#import "LBBannerViewExecuteTool.h"
#import "LBBannerViewCGRectObject.h"
#import "LBBannerViewDisplayLinkTool.h"
#import "LBBannerViewIndicatorView.h"

#pragma mark - 内部类

#pragma mark UIView+LBBannerView
@interface UIView (LBBannerView)
@property (nonatomic,strong) NSObject *bannerViewItemObj;
@property (nonatomic, strong) LBBannerViewCGRectObject *bannerViewItemRectObj;
@end
@implementation UIView (LBBannerView)

- (void)setBannerViewItemObj:(NSObject *)bannerViewItemObj {
    objc_setAssociatedObject(self, @selector(bannerViewItemObj), bannerViewItemObj, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSObject *)bannerViewItemObj {
    return objc_getAssociatedObject(self, @selector(bannerViewItemObj));
}

- (void)setBannerViewItemRectObj:(LBBannerViewCGRectObject *)bannerViewItemRectObj {
    objc_setAssociatedObject(self, @selector(bannerViewItemRectObj), bannerViewItemRectObj, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (LBBannerViewCGRectObject *)bannerViewItemRectObj {
    return objc_getAssociatedObject(self, @selector(bannerViewItemRectObj));
}

@end

#pragma mark NSObject+LBBannerView
@interface NSObject (LBBannerView)
@property (nonatomic,assign) NSNumber *bannerViewItemIndexNum;
@end
@implementation NSObject (LBBannerView)
- (void)setBannerViewItemIndexNum:(NSNumber *)bannerViewItemIndexNum {
    objc_setAssociatedObject(self, @selector(bannerViewItemIndexNum), bannerViewItemIndexNum, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSNumber *)bannerViewItemIndexNum {
    return objc_getAssociatedObject(self, @selector(bannerViewItemIndexNum));
}

@end


#pragma mark - 本类 - LBBannerView
@interface LBBannerView()<UIScrollViewDelegate,LBBannerViewIndicatorViewDelegate>
{
    LBBannerViewDataShowType _showType;
    
    LBBannerViewRunLoopOrientation _runLoopOrientation;
    
    BOOL _needExecuteRunLoop;
    
    UIView *_leftOrTopShowView;
    UIView *_currentShowView;
    UIView *_rightOrBottomShowView;
    
    NSNumber *_beginScrollXNum;
    NSNumber *_beginScrollYNum;
    
    NSInteger _alphaCurrentShowObjIndex;
    NSInteger _alphaNextShowObjIndex;
    UIView *_alphaCurrentShowView;
    UIView *_alphaNextShowView;
    
    NSArray *_runLoopObjArr;
    NSArray *_alphaObjArr;
}
@property (nonatomic, strong) LBBannerViewScrollView *scrollView;
@property (nonatomic, strong) LBBannerViewExecuteTool *runLoopExecuteTool;
@property (nonatomic, strong) LBBannerViewExecuteTool *alphaExecuteTool;

@property (nonatomic, strong) LBBannerViewDisplayLinkTool *alphaDisplayLinkTool;

@property (nonatomic, strong) LBBannerViewIndicatorView *indicatorView;
@end

@implementation LBBannerView
- (instancetype)init
{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        
    }
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        _runLoopOrientation = LBBannerViewRunLoopOrientationNone;
        
        self.layer.masksToBounds = YES;
    }
    return self;
}

- (LBBannerViewScrollView *)scrollView
{
    if (!_scrollView) {
        _scrollView = [[LBBannerViewScrollView alloc] init];
        _scrollView.backgroundColor = [UIColor clearColor];
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.pagingEnabled = YES;
        _scrollView.delegate = self;
    }
    return _scrollView;
}

- (LBBannerViewExecuteTool *)runLoopExecuteTool
{
    if (!_runLoopExecuteTool) {
        _runLoopExecuteTool = [[LBBannerViewExecuteTool alloc] init];
    }
    return _runLoopExecuteTool;
}
- (LBBannerViewExecuteTool *)alphaExecuteTool
{
    if (!_alphaExecuteTool) {
        _alphaExecuteTool = [[LBBannerViewExecuteTool alloc] init];
    }
    return _alphaExecuteTool;
}
- (LBBannerViewDisplayLinkTool *)alphaDisplayLinkTool
{
    if (!_alphaDisplayLinkTool) {
        _alphaDisplayLinkTool = [[LBBannerViewDisplayLinkTool alloc] init];
    }
    return _alphaDisplayLinkTool;
}

#pragma mark 获取LBBannerViewRunLoopDelegate数据
- (BOOL)runLoopGetNeedRunLoop
{
    LBBannerViewRunLoopType runLoopType = [self runLoopGetRunLoopType];
    return runLoopType == LBBannerViewRunLoopTypeAuto || runLoopType == LBBannerViewRunLoopTypeByHand;
}
- (LBBannerViewRunLoopType)runLoopGetRunLoopType
{
    LBBannerViewRunLoopType runLoopType = LBBannerViewRunLoopTypeAuto;
    if ([_runloopDelegate respondsToSelector:@selector(bannerViewRunLoopType:)]) {
        runLoopType = [_runloopDelegate bannerViewRunLoopType:self];
    }
    return runLoopType;
}
- (LBBannerViewRunLoopOrientation)runLoopGetRunLoopOrientation
{
    LBBannerViewRunLoopOrientation orientation = LBBannerViewRunLoopOrientationNone;
    if ([_runloopDelegate respondsToSelector:@selector(bannerViewRunLoopOrientation:)]) {
        orientation = [_runloopDelegate bannerViewRunLoopOrientation:self];
    }
    return orientation;
}
- (BOOL)runLoopGetNeedExecuteRunLoopWithObjArr:(NSArray *)objArr
{
    BOOL result = NO;
    BOOL need = [self runLoopGetNeedRunLoop];
    if (need && (objArr && [objArr isKindOfClass:[NSArray class]] && objArr.count > 1)) {
        result = YES;
    }
    _needExecuteRunLoop = result;
    return result;
}
- (BOOL)runLoopGetSizeNeedAuto
{
    BOOL result = NO;
    if ([_runloopDelegate respondsToSelector:@selector(bannerViewSizeNeedAuto:)]) {
        result = [_runloopDelegate bannerViewSizeNeedAuto:self];
    }
    return result;
}
- (NSArray *)runLoopGetShowViewDataObjectList
{
    NSArray *objArr = nil;
    if ([_runloopDelegate respondsToSelector:@selector(bannerViewShowViewDataObjectList:)]) {
        objArr = [_runloopDelegate bannerViewShowViewDataObjectList:self];
    }
    _runLoopObjArr = objArr;
    return objArr;
}
- (UIView *)runLoopGetViewForObj:(NSObject *)obj
{
    UIView *showView = nil;
    if ([_runloopDelegate respondsToSelector:@selector(bannerView:getViewForObject:)]) {
        showView = [_runloopDelegate bannerView:self getViewForObject:obj];
    }
    return showView;
}
- (CGFloat)runLoopGetChangeDelayTime
{
    CGFloat defaultTime = 5;
    CGFloat delay = defaultTime;
    if ([_runloopDelegate respondsToSelector:@selector(bannerViewChangeDelayTime:)]) {
        delay = [_runloopDelegate bannerViewChangeDelayTime:self];
    }
    if (delay <= 0) {
        delay = defaultTime;
    }
    return delay;
}
- (CGFloat)runLoopGetChangeAnimationTime
{
    CGFloat defaultTime = 0.25;
    CGFloat animationTime = defaultTime;
    if ([_runloopDelegate respondsToSelector:@selector(bannerViewChangeAnimationTime:)]) {
        animationTime = [_runloopDelegate bannerViewChangeAnimationTime:self];
    }
    if (animationTime <= 0) {
        animationTime = defaultTime;
    }
    return animationTime;
}
- (void)runLoopSetBannerViewFrameDidChanged
{
    if ([_runloopDelegate respondsToSelector:@selector(bannerViewFrameDidChanged:)]) {
        [_runloopDelegate bannerViewFrameDidChanged:self];
    }
}
- (void)runLoopSetScrollViewEndDeceleratingWithShowDataIndexNum:(NSNumber *__nonnull)showDataIndexNum showView:(UIView *_Nonnull)showView
{
    if ([_runloopDelegate respondsToSelector:@selector(bannerView:scrollViewEndDeceleratingWithShowDataIndexNum:showView:)]) {
        [_runloopDelegate bannerView:self scrollViewEndDeceleratingWithShowDataIndexNum:showDataIndexNum showView:showView];
    }
    
    BOOL indicatorChangedOnWillShowView = [self getIndicatorChangedOnWillShowView];
    if (!indicatorChangedOnWillShowView) {
        [self setIndicatorViewShowIndex:[showDataIndexNum integerValue]];
    }
}
- (void)runLoopSetScrollViewDidScrollWithDidScrollStatus:(LBBannerViewRunLoopDidScrollStatus)didScrollStatus scrollPercent:(CGFloat)scrollPercent bannerViewSize:(CGSize)bannerViewSize willShowDataIndexNum:(NSNumber *__nullable)willShowDataIndexNum willShowView:(UIView *__nullable)willShowView
{
    if ([_runloopDelegate respondsToSelector:@selector(bannerView:scrollViewDidScrollWithScrollView:didScrollStatus:scrollPercent:bannerViewSize:willShowDataIndexNum:willShowView:)]) {
        [_runloopDelegate bannerView:self scrollViewDidScrollWithScrollView:self.scrollView didScrollStatus:didScrollStatus scrollPercent:scrollPercent bannerViewSize:bannerViewSize willShowDataIndexNum:willShowDataIndexNum willShowView:willShowView];
    }
    
    if (didScrollStatus != LBBannerViewRunLoopDidScrollStatusNone) {
        BOOL indicatorChangedOnWillShowView = [self getIndicatorChangedOnWillShowView];
        if (indicatorChangedOnWillShowView) {
            if (scrollPercent > 0.5) {
                [self setIndicatorViewShowIndex:[willShowDataIndexNum integerValue]];
            }
        }
    }
}
#pragma mark 获取LBBannerViewRunLoopDelegate数据
- (NSArray *)alphaGetShowViewDataObjectList
{
    NSArray *objArr = nil;
    if ([_alphaDelegate respondsToSelector:@selector(bannerViewAlphaShowViewDataObjectList:)]) {
        objArr = [_alphaDelegate bannerViewAlphaShowViewDataObjectList:self];
    }
    return objArr;
}
- (UIView *)alphaGetViewForObj:(NSObject *)obj
{
    UIView *showView = nil;
    if ([_alphaDelegate respondsToSelector:@selector(bannerView:getViewAlphaForObject:)]) {
        showView = [_alphaDelegate bannerView:self getViewAlphaForObject:obj];
    }
    return showView;
}
- (LBBannerViewAlphaAutoSizeType)alphaGetAlphaAutoSizeType
{
    LBBannerViewAlphaAutoSizeType autoSizeType = LBBannerViewAlphaAutoSizeTypeNone;
    if ([_alphaDelegate respondsToSelector:@selector(bannerViewAlphaAutoSizeType:)]) {
        autoSizeType = [_alphaDelegate bannerViewAlphaAutoSizeType:self];
    }
    return autoSizeType;
}
- (CGFloat)alphaGetChangeDelayTime
{
    CGFloat defaultTime = 5;
    CGFloat delay = defaultTime;
    if ([_alphaDelegate respondsToSelector:@selector(bannerViewAlphaChangeDelayTime:)]) {
        delay = [_alphaDelegate bannerViewAlphaChangeDelayTime:self];
    }
    if (delay <= 0) {
        delay = defaultTime;
    }
    return delay;
}
- (CGFloat)alphaGetChangeAnimationTime
{
    CGFloat defaultTime = 0.25;
    CGFloat animationTime = defaultTime;
    if ([_alphaDelegate respondsToSelector:@selector(bannerViewAlphaChangeAnimationTime:)]) {
        animationTime = [_alphaDelegate bannerViewAlphaChangeAnimationTime:self];
    }
    if (animationTime <= 0) {
        animationTime = defaultTime;
    }
    return animationTime;
}
- (void)alphaSetBannerViewFrameDidChanged
{
    if ([_alphaDelegate respondsToSelector:@selector(bannerViewAlphaFrameDidChanged:)]) {
        [_alphaDelegate bannerViewAlphaFrameDidChanged:self];
    }
}
- (void)alphaSetAlphaAnimationWillExecuteWithWillShowDataIndexNum:(NSNumber *_Nonnull)willShowDataIndexNum willShowView:(UIView *__nullable)willShowView
{
    if ([_alphaDelegate respondsToSelector:@selector(bannerView:alphaAnimationWillExecuteWithWillShowDataIndexNum:willShowView:)]) {
        [_alphaDelegate bannerView:self alphaAnimationWillExecuteWithWillShowDataIndexNum:willShowDataIndexNum willShowView:willShowView];
    }
}
- (void)alphaSetAlphaAnimationExecutingWithBannerViewSize:(CGSize)bannerViewSize changePercent:(CGFloat)changePercent willShowDataIndexNum:(NSNumber *_Nonnull)willShowDataIndexNum willShowView:(UIView *__nullable)willShowView
{
    if ([_alphaDelegate respondsToSelector:@selector(bannerView:bannerViewSize:alphaAnimationExecutingWithChangePercent:willShowDataIndexNum:willShowView:)]) {
        [_alphaDelegate bannerView:self bannerViewSize:bannerViewSize alphaAnimationExecutingWithChangePercent:changePercent willShowDataIndexNum:willShowDataIndexNum willShowView:willShowView];
    }
    
    BOOL indicatorChangedOnWillShowView = [self getIndicatorChangedOnWillShowView];
    if (indicatorChangedOnWillShowView) {
        if (changePercent > 0.5) {
            [self setIndicatorViewShowIndex:[willShowDataIndexNum integerValue]];
        }
    }
}
- (void)alphaSetAlphaAnimationDidEndWithDidShowDataIndexNum:(NSNumber *_Nonnull)didShowDataIndexNum didShowView:(UIView *__nullable)didShowView
{
    if ([_alphaDelegate respondsToSelector:@selector(bannerView:alphaAnimationDidEndWithDidShowDataIndexNum:didShowView:)]) {
        [_alphaDelegate bannerView:self alphaAnimationDidEndWithDidShowDataIndexNum:didShowDataIndexNum didShowView:didShowView];
    }
    
    BOOL indicatorChangedOnWillShowView = [self getIndicatorChangedOnWillShowView];
    if (!indicatorChangedOnWillShowView) {
        [self setIndicatorViewShowIndex:[didShowDataIndexNum integerValue]];
    }
}
#pragma mark 获取LBBannerViewIndicatorDelegate数据
- (UIView *)getIndicatorNormalView
{
    UIView *view = nil;
    if ([_indicatorDelegate respondsToSelector:@selector(bannerViewIndicatorNormalView:)]) {
        view = [_indicatorDelegate bannerViewIndicatorNormalView:self];
    }
    return view;
}
- (UIView *)getIndicatorSelectedView
{
    UIView *view = nil;
    if ([_indicatorDelegate respondsToSelector:@selector(bannerViewIndicatorSelectedView:)]) {
        view = [_indicatorDelegate bannerViewIndicatorSelectedView:self];
    }
    return view;
}
- (BOOL)getIndicatorCanClick
{
    BOOL result = YES;
    if ([_indicatorDelegate respondsToSelector:@selector(bannerViewIndicatorCanClick:)]) {
        result = [_indicatorDelegate bannerViewIndicatorCanClick:self];
    }
    return result;
}
- (BOOL)getIndicatorChangedOnWillShowView
{
    BOOL result = YES;
    if ([_indicatorDelegate respondsToSelector:@selector(bannerViewIndicatorChangedOnWillShowView:)]) {
        result = [_indicatorDelegate bannerViewIndicatorChangedOnWillShowView:self];
    }
    return result;
}
- (CGFloat)getIndicatorItemToItemSpace
{
    CGFloat defaultSpace = 0;
    CGFloat space = defaultSpace;
    if ([_indicatorDelegate respondsToSelector:@selector(bannerViewIndicatorItemToItemSpace:)]) {
        space = [_indicatorDelegate bannerViewIndicatorItemToItemSpace:self];
    }
    if (space < 0) {
        space = defaultSpace;
    }
    return space;
}
- (BOOL)getIndicatorIsCenter
{
    BOOL result = YES;
    if ([_indicatorDelegate respondsToSelector:@selector(bannerViewIndicatorIsCenter:)]) {
        result = [_indicatorDelegate bannerViewIndicatorIsCenter:self];
    }
    return result;
}
- (CGFloat)getIndicatorBottomOrRightSpace
{
    CGFloat space = 0;
    if ([_indicatorDelegate respondsToSelector:@selector(bannerViewIndicatorBottomOrRightSpace:)]) {
        space = [_indicatorDelegate bannerViewIndicatorBottomOrRightSpace:self];
    }
    return space;
}
- (CGFloat)getIndicatorLeftOrTopSpace
{
    CGFloat space = 0;
    if ([_indicatorDelegate respondsToSelector:@selector(bannerViewIndicatorLeftOrTopSpace:)]) {
        space = [_indicatorDelegate bannerViewIndicatorLeftOrTopSpace:self];
    }
    return space;
}
#pragma mark 展示所有数据
- (void)showBannerViewAllDatasWithShowType:(LBBannerViewDataShowType)showType
{
    _showType = showType;
    
    if (showType == LBBannerViewDataShowTypeRunLoop) {
        [self showBannerViewForRunLoop];
    } else if (showType == LBBannerViewDataShowTypeAlphaAnimation) {
        [self showBannerViewForAlphaAnimation];
    }
}
#pragma mark - 数据展示逻辑--轮询逻辑
- (void)showBannerViewForRunLoop
{
    
    [self cleanAllDatas];
    
    if (_runloopDelegate) {
        BOOL needShowDatas = NO;
        
        NSArray *objArr = [self runLoopGetShowViewDataObjectList];
        if (objArr && [objArr isKindOfClass:[NSArray class]] && objArr.count > 0) {
            needShowDatas = YES;
        }
        if (needShowDatas) {
            
            _runLoopOrientation = [self runLoopGetRunLoopOrientation];
            
            if (!self.scrollView.superview) {
                self.scrollView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
                [self addSubview:self.scrollView];
            }
            
            NSMutableArray *newObjArr = [NSMutableArray array];
            for (int i = 0; i < objArr.count; i++) {
                NSObject *obj = objArr[i];
                obj.bannerViewItemIndexNum = [NSNumber numberWithInt:i];
                [newObjArr addObject:obj];
            }
            
            if (_runLoopOrientation == LBBannerViewRunLoopOrientationNone) {
                [self scrollViewOrientationNoneToDoWithObjArr:newObjArr];
            } else if (_runLoopOrientation == LBBannerViewRunLoopOrientationHorizontalLeft) {
                BOOL needExecuteRunLoop = [self runLoopGetNeedExecuteRunLoopWithObjArr:objArr];
                if (needExecuteRunLoop) {
                    [self scrollViewOrientationHorizontalLeftToDoWithObjArr:newObjArr];
                } else {
                    [self scrollViewOrientationHorizontalToDoWithObjArr:newObjArr];
                }
                [self showIndicatorViewToDo];
            } else if (_runLoopOrientation == LBBannerViewRunLoopOrientationHorizontalRight) {
                BOOL needExecuteRunLoop = [self runLoopGetNeedExecuteRunLoopWithObjArr:objArr];
                if (needExecuteRunLoop) {
                    [self scrollViewOrientationHorizontalRightToDoWithObjArr:newObjArr];
                } else {
                    [self scrollViewOrientationHorizontalToDoWithObjArr:newObjArr];
                }
                [self showIndicatorViewToDo];
            } else if (_runLoopOrientation == LBBannerViewRunLoopOrientationVerticalTop) {
                BOOL needExecuteRunLoop = [self runLoopGetNeedExecuteRunLoopWithObjArr:objArr];
                if (needExecuteRunLoop) {
                    [self scrollViewOrientationVerticalTopToDoWithObjArr:newObjArr];
                } else {
                    [self scrollViewOrientationVerticalToDoWithObjArr:newObjArr];
                }
                [self showIndicatorViewToDo];
            } else if (_runLoopOrientation == LBBannerViewRunLoopOrientationVerticalBottom) {
                BOOL needExecuteRunLoop = [self runLoopGetNeedExecuteRunLoopWithObjArr:objArr];
                if (needExecuteRunLoop) {
                    [self scrollViewOrientationVerticalBottomToDoWithObjArr:newObjArr];
                } else {
                    [self scrollViewOrientationVerticalToDoWithObjArr:newObjArr];
                }
                [self showIndicatorViewToDo];
            }
        }
    }
    
}

- (void)scrollViewOrientationNoneToDoWithObjArr:(NSArray *)objArr
{
    UIView *lastObjView = nil;
    for (NSObject *obj in objArr) {
        UIView *objView = [self runLoopGetViewForObj:obj];
        if (objView && [objView isKindOfClass:[UIView class]]) {
            if (!lastObjView) {
                objView.frame = CGRectMake(0, 0, self.scrollView.frame.size.width, objView.frame.size.height);
            } else {
                objView.frame = CGRectMake(0, CGRectGetMaxY(lastObjView.frame), self.scrollView.frame.size.width, objView.frame.size.height);
            }
            
            objView.bannerViewItemObj = obj;
            
            [self setItemViewRectObjWithItemView:objView frame:objView.frame];
            
            [self.scrollView addSubview:objView];
            
            lastObjView = objView;
            
            [objView addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];
        }
    }
    if (lastObjView) {
        self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, CGRectGetMaxY(lastObjView.frame));
        
        CGRect scrollViewFrame = self.scrollView.frame;
        scrollViewFrame.size.height = CGRectGetMaxY(lastObjView.frame);
        self.scrollView.frame = scrollViewFrame;
        
        [self updateBannerViewSize];
    }
}

- (void)scrollViewOrientationHorizontalToDoWithObjArr:(NSArray *)objArr
{
    NSMutableArray *showObjArr = [NSMutableArray arrayWithArray:objArr];
    
    //向scrollView中添加数据
    UIView *firstShowObjView = nil;
    UIView *lastObjView = nil;
    for (int i = 0; i < showObjArr.count; i++) {
        NSObject *obj = showObjArr[i];
        
        UIView *objView = [self runLoopGetViewForObj:obj];
        if (objView && [objView isKindOfClass:[UIView class]]) {
            if (!lastObjView) {
                objView.frame = CGRectMake(0, 0, self.scrollView.frame.size.width, objView.frame.size.height);
            } else {
                objView.frame = CGRectMake(CGRectGetMaxX(lastObjView.frame), 0, self.scrollView.frame.size.width, objView.frame.size.height);
            }
            
            objView.bannerViewItemObj = obj;
            
            [self setItemViewRectObjWithItemView:objView frame:objView.frame];
            
            [self.scrollView addSubview:objView];
            lastObjView = objView;
            
            if (!firstShowObjView) {
                if (i == 0) {
                    firstShowObjView = objView;
                }
            }
            
            if (i == 0) {
                _leftOrTopShowView = nil;
            } else if (i == 1) {
                _rightOrBottomShowView = objView;
            }
            
            [objView addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];
        }
    }
    
    _currentShowView = firstShowObjView;
    
    //设置自适应size需要的数据
    BOOL autoSize = [self runLoopGetSizeNeedAuto];
    
    //显示第一个要显示的view
    self.scrollView.contentSize = CGSizeMake(CGRectGetMaxX(lastObjView.frame), autoSize ? CGRectGetHeight(firstShowObjView.frame) : self.scrollView.frame.size.height);
    
    self.scrollView.contentOffset = CGPointMake(0, 0);
    
    if (autoSize) {
        CGRect scrollViewFrame = self.scrollView.frame;
        scrollViewFrame.size.height = firstShowObjView.frame.size.height;
        self.scrollView.frame = scrollViewFrame;
        
        [self updateBannerViewSize];
    }
    
    //回调给delegate第一个view显示了
    NSObject *firstShowObjViewObj = firstShowObjView.bannerViewItemObj;
    NSNumber *firstShowObjViewObjIndexNum = firstShowObjViewObj.bannerViewItemIndexNum;
    [self runLoopSetScrollViewEndDeceleratingWithShowDataIndexNum:firstShowObjViewObjIndexNum showView:firstShowObjView];
}

- (void)scrollViewOrientationVerticalToDoWithObjArr:(NSArray *)objArr
{
    NSMutableArray *showObjArr = [NSMutableArray arrayWithArray:objArr];
    
    //向scrollView中添加数据
    UIView *firstShowObjView = nil;
    UIView *lastObjView = nil;
    for (int i = 0; i < showObjArr.count; i++) {
        NSObject *obj = showObjArr[i];
        
        UIView *objView = [self runLoopGetViewForObj:obj];
        if (objView && [objView isKindOfClass:[UIView class]]) {
            if (!lastObjView) {
                objView.frame = CGRectMake(0, 0, objView.frame.size.width ,self.scrollView.frame.size.height);
            } else {
                objView.frame = CGRectMake(0, CGRectGetMaxY(lastObjView.frame), objView.frame.size.width ,self.scrollView.frame.size.height);
            }
            
            objView.bannerViewItemObj = obj;
            
            [self setItemViewRectObjWithItemView:objView frame:objView.frame];
            
            [self.scrollView addSubview:objView];
            lastObjView = objView;
            
            if (!firstShowObjView) {
                if (i == 0) {
                    firstShowObjView = objView;
                }
            }
            
            if (i == 0) {
                _leftOrTopShowView = nil;
            } else if (i == 1) {
                _rightOrBottomShowView = objView;
            }
            
            [objView addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];
        }
    }
    
    _currentShowView = firstShowObjView;
    
    //设置自适应size需要的数据
    BOOL autoSize = [self runLoopGetSizeNeedAuto];
    
    //显示第一个要显示的view
    self.scrollView.contentSize = CGSizeMake(autoSize ? CGRectGetWidth(firstShowObjView.frame) : self.scrollView.frame.size.width, CGRectGetMaxY(lastObjView.frame));
    
    self.scrollView.contentOffset = CGPointMake(0, 0);
    
    if (autoSize) {
        CGRect scrollViewFrame = self.scrollView.frame;
        scrollViewFrame.size.width = firstShowObjView.frame.size.width;
        self.scrollView.frame = scrollViewFrame;
        
        [self updateBannerViewSize];
    }
    
    //回调给delegate第一个view显示了
    NSObject *firstShowObjViewObj = firstShowObjView.bannerViewItemObj;
    NSNumber *firstShowObjViewObjIndexNum = firstShowObjViewObj.bannerViewItemIndexNum;
    [self runLoopSetScrollViewEndDeceleratingWithShowDataIndexNum:firstShowObjViewObjIndexNum showView:firstShowObjView];
}

- (void)scrollViewOrientationHorizontalLeftToDoWithObjArr:(NSArray *)objArr
{
    NSMutableArray *showObjArr = [NSMutableArray arrayWithArray:objArr];
    
    //整合数据
    NSObject *firstObj = objArr.firstObject;
    NSObject *lastObj = objArr.lastObject;
    [showObjArr insertObject:lastObj atIndex:0];
    [showObjArr addObject:firstObj];
    
    //向scrollView中添加数据
    UIView *firstShowObjView = nil;
    UIView *lastObjView = nil;
    for (int i = 0; i < showObjArr.count; i++) {
        NSObject *obj = showObjArr[i];
        
        UIView *objView = [self runLoopGetViewForObj:obj];
        if (objView && [objView isKindOfClass:[UIView class]]) {
            if (!lastObjView) {
                objView.frame = CGRectMake(0, 0, self.scrollView.frame.size.width, objView.frame.size.height);
            } else {
                objView.frame = CGRectMake(CGRectGetMaxX(lastObjView.frame), 0, self.scrollView.frame.size.width, objView.frame.size.height);
            }
            
            objView.bannerViewItemObj = obj;
            
            [self setItemViewRectObjWithItemView:objView frame:objView.frame];
            
            [self.scrollView addSubview:objView];
            lastObjView = objView;
            
            if (!firstShowObjView) {
                if (i == 1) {
                    firstShowObjView = objView;
                }
            }
            
            if (i == 0) {
                _leftOrTopShowView = objView;
            } else if (i == 2) {
                _rightOrBottomShowView = objView;
            }
            
            [objView addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];
        }
    }
    
    _currentShowView = firstShowObjView;
    
    //设置自适应size需要的数据
    BOOL autoSize = [self runLoopGetSizeNeedAuto];
    
    //显示第一个要显示的view
    self.scrollView.contentSize = CGSizeMake(CGRectGetMaxX(lastObjView.frame), autoSize ? CGRectGetHeight(firstShowObjView.frame) : self.scrollView.frame.size.height);
    
    self.scrollView.contentOffset = CGPointMake(self.scrollView.frame.size.width, 0);
    
    if (autoSize) {
        CGRect scrollViewFrame = self.scrollView.frame;
        scrollViewFrame.size.height = firstShowObjView.frame.size.height;
        self.scrollView.frame = scrollViewFrame;
        
        [self updateBannerViewSize];
    }
    
    //回调给delegate第一个view显示了
    NSObject *firstShowObjViewObj = firstShowObjView.bannerViewItemObj;
    NSNumber *firstShowObjViewObjIndexNum = firstShowObjViewObj.bannerViewItemIndexNum;
    [self runLoopSetScrollViewEndDeceleratingWithShowDataIndexNum:firstShowObjViewObjIndexNum showView:firstShowObjView];
    
    //开始执行轮询
    [self beginExecuteRunLoop];
}

- (void)scrollViewOrientationHorizontalRightToDoWithObjArr:(NSArray *)objArr
{
    NSMutableArray *showObjArr = [NSMutableArray array];
    for (int i = (int)objArr.count - 1; i>= 0; i--) {
        NSObject *obj = objArr[i];
        [showObjArr addObject:obj];
    }
    
    //整合数据
    NSObject *firstObj = objArr.firstObject;
    NSObject *lastObj = objArr.lastObject;
    [showObjArr insertObject:firstObj atIndex:0];
    [showObjArr addObject:lastObj];
    
    //向scrollView中添加数据
    UIView *firstShowObjView = nil;
    UIView *lastObjView = nil;
    for (int i = 0; i < showObjArr.count; i++) {
        NSObject *obj = showObjArr[i];
        
        UIView *objView = [self runLoopGetViewForObj:obj];
        if (objView && [objView isKindOfClass:[UIView class]]) {
            if (!lastObjView) {
                objView.frame = CGRectMake(0, 0, self.scrollView.frame.size.width, objView.frame.size.height);
            } else {
                objView.frame = CGRectMake(CGRectGetMaxX(lastObjView.frame), 0, self.scrollView.frame.size.width, objView.frame.size.height);
            }
            
            objView.bannerViewItemObj = obj;
            
            [self setItemViewRectObjWithItemView:objView frame:objView.frame];
            
            [self.scrollView addSubview:objView];
            lastObjView = objView;
            
            if (!firstShowObjView) {
                if (i == showObjArr.count - 2) {
                    firstShowObjView = objView;
                }
            }
            
            if (i == showObjArr.count - 3) {
                _leftOrTopShowView = objView;
            } else if (i == showObjArr.count - 1) {
                _rightOrBottomShowView = objView;
            }
            
            [objView addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];
        }
    }
    
    _currentShowView = firstShowObjView;
    
    //设置自适应size需要的数据
    BOOL autoSize = [self runLoopGetSizeNeedAuto];
    
    //显示第一个要显示的view
    self.scrollView.contentSize = CGSizeMake(CGRectGetMaxX(lastObjView.frame), autoSize ? CGRectGetHeight(firstShowObjView.frame) : self.scrollView.frame.size.height);
    
    self.scrollView.contentOffset = CGPointMake(self.scrollView.contentSize.width - self.scrollView.frame.size.width * 2, 0);
    
    if (autoSize) {
        CGRect scrollViewFrame = self.scrollView.frame;
        scrollViewFrame.size.height = firstShowObjView.frame.size.height;
        self.scrollView.frame = scrollViewFrame;
        
        [self updateBannerViewSize];
    }
    
    //回调给delegate第一个view显示了
    NSObject *firstShowObjViewObj = firstShowObjView.bannerViewItemObj;
    NSNumber *firstShowObjViewObjIndexNum = firstShowObjViewObj.bannerViewItemIndexNum;
    [self runLoopSetScrollViewEndDeceleratingWithShowDataIndexNum:firstShowObjViewObjIndexNum showView:firstShowObjView];
    
    //开始执行轮询
    [self beginExecuteRunLoop];
}

- (void)scrollViewOrientationVerticalTopToDoWithObjArr:(NSArray *)objArr
{
    NSMutableArray *showObjArr = [NSMutableArray arrayWithArray:objArr];
    
    //整合数据
    NSObject *firstObj = objArr.firstObject;
    NSObject *lastObj = objArr.lastObject;
    [showObjArr insertObject:lastObj atIndex:0];
    [showObjArr addObject:firstObj];
    
    //向scrollView中添加数据
    UIView *firstShowObjView = nil;
    UIView *lastObjView = nil;
    for (int i = 0; i < showObjArr.count; i++) {
        NSObject *obj = showObjArr[i];
        
        UIView *objView = [self runLoopGetViewForObj:obj];
        if (objView && [objView isKindOfClass:[UIView class]]) {
            if (!lastObjView) {
                objView.frame = CGRectMake(0, 0, objView.frame.size.width ,self.scrollView.frame.size.height);
            } else {
                objView.frame = CGRectMake(0, CGRectGetMaxY(lastObjView.frame), objView.frame.size.width ,self.scrollView.frame.size.height);
            }
            
            objView.bannerViewItemObj = obj;
            
            [self setItemViewRectObjWithItemView:objView frame:objView.frame];
            
            [self.scrollView addSubview:objView];
            lastObjView = objView;
            
            if (!firstShowObjView) {
                if (i == 1) {
                    firstShowObjView = objView;
                }
            }
            
            if (i == 0) {
                _leftOrTopShowView = objView;
            } else if (i == 2) {
                _rightOrBottomShowView = objView;
            }
            
            [objView addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];
        }
    }
    
    _currentShowView = firstShowObjView;
    
    //设置自适应size需要的数据
    BOOL autoSize = [self runLoopGetSizeNeedAuto];
    
    //显示第一个要显示的view
    self.scrollView.contentSize = CGSizeMake(autoSize ? CGRectGetWidth(firstShowObjView.frame) : self.scrollView.frame.size.width, CGRectGetMaxY(lastObjView.frame));
    
    self.scrollView.contentOffset = CGPointMake(0, self.scrollView.frame.size.height);
    
    if (autoSize) {
        CGRect scrollViewFrame = self.scrollView.frame;
        scrollViewFrame.size.width = firstShowObjView.frame.size.width;
        self.scrollView.frame = scrollViewFrame;
        
        [self updateBannerViewSize];
    }
    
    //回调给delegate第一个view显示了
    NSObject *firstShowObjViewObj = firstShowObjView.bannerViewItemObj;
    NSNumber *firstShowObjViewObjIndexNum = firstShowObjViewObj.bannerViewItemIndexNum;
    [self runLoopSetScrollViewEndDeceleratingWithShowDataIndexNum:firstShowObjViewObjIndexNum showView:firstShowObjView];
    
    //开始执行轮询
    [self beginExecuteRunLoop];
}

- (void)scrollViewOrientationVerticalBottomToDoWithObjArr:(NSArray *)objArr
{
    NSMutableArray *showObjArr = [NSMutableArray array];
    for (int i = (int)objArr.count - 1; i >= 0; i--) {
        NSObject *obj = objArr[i];
        [showObjArr addObject:obj];
    }
    
    //整合数据
    NSObject *firstObj = objArr.firstObject;
    NSObject *lastObj = objArr.lastObject;
    [showObjArr insertObject:firstObj atIndex:0];
    [showObjArr addObject:lastObj];
    
    //向scrollView中添加数据
    UIView *firstShowObjView = nil;
    UIView *lastObjView = nil;
    for (int i = 0; i < showObjArr.count; i++) {
        NSObject *obj = showObjArr[i];
        
        UIView *objView = [self runLoopGetViewForObj:obj];
        if (objView && [objView isKindOfClass:[UIView class]]) {
            if (!lastObjView) {
                objView.frame = CGRectMake(0, 0, objView.frame.size.width, self.scrollView.frame.size.height);
            } else {
                objView.frame = CGRectMake(0, CGRectGetMaxY(lastObjView.frame), objView.frame.size.width, self.scrollView.frame.size.height);
            }
            
            objView.bannerViewItemObj = obj;
            
            [self setItemViewRectObjWithItemView:objView frame:objView.frame];
            
            [self.scrollView addSubview:objView];
            lastObjView = objView;
            
            if (!firstShowObjView) {
                if (i == showObjArr.count - 2) {
                    firstShowObjView = objView;
                }
            }
            
            if (i == showObjArr.count - 3) {
                _leftOrTopShowView = objView;
            } else if (i == showObjArr.count - 1) {
                _rightOrBottomShowView = objView;
            }
            
            [objView addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];
        }
    }
    
    _currentShowView = firstShowObjView;
    
    //设置自适应size需要的数据
    BOOL autoSize = [self runLoopGetSizeNeedAuto];
    
    //显示第一个要显示的view
    self.scrollView.contentSize = CGSizeMake(autoSize ? CGRectGetWidth(firstShowObjView.frame) : self.scrollView.frame.size.width, CGRectGetMaxY(lastObjView.frame));
    
    self.scrollView.contentOffset = CGPointMake(0, self.scrollView.contentSize.height - self.scrollView.frame.size.height * 2);
    
    if (autoSize) {
        CGRect scrollViewFrame = self.scrollView.frame;
        scrollViewFrame.size.width = firstShowObjView.frame.size.width;
        self.scrollView.frame = scrollViewFrame;
        
        [self updateBannerViewSize];
    }
    
    //回调给delegate第一个view显示了
    NSObject *firstShowObjViewObj = firstShowObjView.bannerViewItemObj;
    NSNumber *firstShowObjViewObjIndexNum = firstShowObjViewObj.bannerViewItemIndexNum;
    [self runLoopSetScrollViewEndDeceleratingWithShowDataIndexNum:firstShowObjViewObjIndexNum showView:firstShowObjView];
    
    //开始执行轮询
    [self beginExecuteRunLoop];
}

#pragma mark 轮询逻辑
- (void)beginExecuteRunLoop
{
    LBBannerViewRunLoopType runLoopType = [self runLoopGetRunLoopType];
    if (runLoopType == LBBannerViewRunLoopTypeAuto) {
        CGFloat delayTime = [self runLoopGetChangeDelayTime];
        __weak typeof(self) wself = self;
        [self.runLoopExecuteTool executeSomethingAfterDelay:delayTime repeat:YES afterDelay:^{
            __strong typeof(wself) sself = wself;
            [sself executeRunLoopToDo];
        }];
    }
}

- (void)executeRunLoopToDo
{
    if (_runLoopOrientation == LBBannerViewRunLoopOrientationHorizontalLeft) {
        [self runLoopToLeftToDo];
    } else if (_runLoopOrientation == LBBannerViewRunLoopOrientationHorizontalRight) {
        [self runLoopToRightToDo];
    } else if (_runLoopOrientation == LBBannerViewRunLoopOrientationVerticalTop) {
        [self runLoopToTopToDo];
    } else if (_runLoopOrientation == LBBannerViewRunLoopOrientationVerticalBottom) {
        [self runLoopToBottomToDo];
    }
}

- (void)stopRunLoopExecuteTool
{
    if (_runLoopExecuteTool) {
        [_runLoopExecuteTool cancleExecuteBlockWithCompleteBlock:^{
                    
        }];
        _runLoopExecuteTool = nil;
    }
}

- (void)runLoopToLeftToDo
{
    CGFloat animationTime = [self runLoopGetChangeAnimationTime];
    
    __weak typeof(self) wself = self;
    [self.scrollView setContentOffset:CGPointMake(self.scrollView.contentOffset.x + self.scrollView.frame.size.width, 0) withDuration:animationTime completion:^(UIScrollView *currentScrollView,BOOL isFinished) {
        __strong typeof(wself) sself = wself;
        NSLog(@"lbbannerview--customDidScroll--toLeft--isFinished:%d",isFinished);
        if (isFinished) {
            [sself scrollViewEndDeceleratingToDo:currentScrollView];
        }
    } progressHandler:^(UIScrollView *currentScrollView) {
        __strong typeof(wself) sself = wself;
        NSLog(@"lbbannerview--customDidScroll--toLeft--offsetX:%f--offsetY:%f",currentScrollView.contentOffset.x,currentScrollView.contentOffset.y);
        [sself scrollViewDidScrollToDo:currentScrollView];
    }];
}

- (void)runLoopToRightToDo
{
    CGFloat animationTime = [self runLoopGetChangeAnimationTime];
    
    __weak typeof(self) wself = self;
    [self.scrollView setContentOffset:CGPointMake(self.scrollView.contentOffset.x - self.scrollView.frame.size.width, 0) withDuration:animationTime completion:^(UIScrollView *currentScrollView,BOOL isFinished) {
        __strong typeof(wself) sself = wself;
        NSLog(@"lbbannerview--customDidScroll--toRight--isFinished:%d",isFinished);
        if (isFinished) {
            [sself scrollViewEndDeceleratingToDo:currentScrollView];
        }
    } progressHandler:^(UIScrollView *currentScrollView) {
        __strong typeof(wself) sself = wself;
        NSLog(@"lbbannerview--customDidScroll--toRight--offsetX:%f--offsetY:%f",currentScrollView.contentOffset.x,currentScrollView.contentOffset.y);
        [sself scrollViewDidScrollToDo:currentScrollView];
    }];
}

- (void)runLoopToTopToDo
{
    CGFloat animationTime = [self runLoopGetChangeAnimationTime];
    
    __weak typeof(self) wself = self;
    [self.scrollView setContentOffset:CGPointMake(0, self.scrollView.contentOffset.y + self.scrollView.frame.size.height) withDuration:animationTime completion:^(UIScrollView *currentScrollView,BOOL isFinished) {
        __strong typeof(wself) sself = wself;
        NSLog(@"lbbannerview--customDidScroll--toTop--isFinished:%d",isFinished);
        if (isFinished) {
            [sself scrollViewEndDeceleratingToDo:currentScrollView];
        }
    } progressHandler:^(UIScrollView *currentScrollView) {
        __strong typeof(wself) sself = wself;
        NSLog(@"lbbannerview--customDidScroll--toTop--offsetX:%f--offsetY:%f",currentScrollView.contentOffset.x,currentScrollView.contentOffset.y);
        [sself scrollViewDidScrollToDo:currentScrollView];
    }];
}

- (void)runLoopToBottomToDo
{
    CGFloat animationTime = [self runLoopGetChangeAnimationTime];
    
    __weak typeof(self) wself = self;
    [self.scrollView setContentOffset:CGPointMake(0, self.scrollView.contentOffset.y - self.scrollView.frame.size.height) withDuration:animationTime completion:^(UIScrollView *currentScrollView,BOOL isFinished) {
        __strong typeof(wself) sself = wself;
        NSLog(@"lbbannerview--customDidScroll--toBottom--isFinished:%d",isFinished);
        if (isFinished) {
            [sself scrollViewEndDeceleratingToDo:currentScrollView];
        }
    } progressHandler:^(UIScrollView *currentScrollView) {
        __strong typeof(wself) sself = wself;
        NSLog(@"lbbannerview--customDidScroll--toBottom--offsetX:%f--offsetY:%f",currentScrollView.contentOffset.x,currentScrollView.contentOffset.y);
        [sself scrollViewDidScrollToDo:currentScrollView];
    }];
}

#pragma mark UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSLog(@"lbbannerview--DidScroll--offsetX:%f--offsetY:%f",scrollView.contentOffset.x,scrollView.contentOffset.y);
    
    [self scrollViewDidScrollToDo:scrollView];
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate) {
        //在这里写停止要执行的代码
        [self scrollViewEndDeceleratingToDo:scrollView];
    }
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self scrollViewEndDeceleratingToDo:scrollView];
}

#pragma mark UIScrollViewDelegate 方法的执行方法
- (void)scrollViewDidScrollToDo:(UIScrollView *)scrollView
{
    if (_runLoopOrientation == LBBannerViewRunLoopOrientationHorizontalLeft || _runLoopOrientation == LBBannerViewRunLoopOrientationHorizontalRight) {
        LBBannerViewRunLoopType runLoopType = [self runLoopGetRunLoopType];
        if (runLoopType == LBBannerViewRunLoopTypeNone) {
            if (scrollView.contentOffset.x >= 0 && scrollView.contentOffset.x <= scrollView.contentSize.width - self.scrollView.frame.size.width) {
                [self scrollViewDidScrollHorizontal:scrollView];
            }
        } else {
            [self scrollViewDidScrollHorizontal:scrollView];
        }
        
    } else if (_runLoopOrientation == LBBannerViewRunLoopOrientationVerticalTop || _runLoopOrientation == LBBannerViewRunLoopOrientationVerticalBottom) {
        LBBannerViewRunLoopType runLoopType = [self runLoopGetRunLoopType];
        if (runLoopType == LBBannerViewRunLoopTypeNone) {
            if (scrollView.contentOffset.y >= 0 && scrollView.contentOffset.y <= scrollView.contentSize.height - self.scrollView.frame.size.height) {
                [self scrollViewDidScrollVertical:scrollView];
            }
        } else {
            [self scrollViewDidScrollVertical:scrollView];
        }
    }
}
- (void)scrollViewEndDeceleratingToDo:(UIScrollView *)scrollView
{
    if (_runLoopOrientation == LBBannerViewRunLoopOrientationHorizontalLeft || _runLoopOrientation == LBBannerViewRunLoopOrientationHorizontalRight) {
        [self scrollViewEndDeceleratingHorizontal:scrollView];
    } else if (_runLoopOrientation == LBBannerViewRunLoopOrientationVerticalTop || _runLoopOrientation == LBBannerViewRunLoopOrientationVerticalBottom) {
        [self scrollViewEndDeceleratingVertical:scrollView];
    }
    
    _beginScrollXNum = nil;
    _beginScrollYNum = nil;
}
- (void)scrollViewDidScrollHorizontal:(UIScrollView *)scrollView
{
    NSNumber *endXNum = nil;
    if (!_beginScrollXNum) {
        _beginScrollXNum = [NSNumber numberWithFloat:scrollView.contentOffset.x];
    }
    
    LBBannerViewRunLoopDidScrollStatus didScrollStatus = LBBannerViewRunLoopDidScrollStatusNone;
    
    CGFloat scrollPercent = 0;
    CGFloat currentHeight = 0;
    if (scrollView.contentOffset.x < [_beginScrollXNum floatValue]) {
        //向右滚动
        if (!endXNum) {
            endXNum = [NSNumber numberWithFloat:([_beginScrollXNum floatValue] - self.scrollView.frame.size.width)];
        }
        scrollPercent = 1 - (scrollView.contentOffset.x - [endXNum floatValue]) / self.scrollView.frame.size.width;
        
        if (_leftOrTopShowView) {
            CGFloat changeHeight = _leftOrTopShowView.frame.size.height - _currentShowView.frame.size.height;
            
            currentHeight = _currentShowView.frame.size.height + changeHeight * scrollPercent;
        } else {
            scrollPercent = 1;
        }
        
        didScrollStatus = LBBannerViewRunLoopDidScrollStatusHorizontalRight;
        
    } else if (scrollView.contentOffset.x > [_beginScrollXNum floatValue]) {
        //向左滚动
        if (!endXNum) {
            endXNum = [NSNumber numberWithFloat:([_beginScrollXNum floatValue] + self.scrollView.frame.size.width)];
        }
        scrollPercent = 1 - ([endXNum floatValue] - scrollView.contentOffset.x) / self.scrollView.frame.size.width;
        
        if (_rightOrBottomShowView) {
            CGFloat changeHeight = _rightOrBottomShowView.frame.size.height - _currentShowView.frame.size.height;
            NSLog(@"lbbannerview--DidScrollHorizontal--changeHeight:%f",changeHeight);
            
            currentHeight = _currentShowView.frame.size.height + changeHeight * scrollPercent;
        } else {
            scrollPercent = 1;
        }
        
        didScrollStatus = LBBannerViewRunLoopDidScrollStatusHorizontalLeft;
        
    } else {
        //没有滚动
        scrollPercent = 0;
        currentHeight = _currentShowView.frame.size.height;
    }
    
    if (scrollPercent < 0) {
        scrollPercent = 0;
    } else if (scrollPercent > 1) {
        scrollPercent = 1;
    }
    
    NSLog(@"lbbannerview--DidScrollHorizontal--scrollPercent:%f--currentHeight:%f--currentShowViewHeight:%f",scrollPercent,currentHeight,_currentShowView.frame.size.height);
    
    BOOL autoSize = [self runLoopGetSizeNeedAuto];
    if (autoSize && currentHeight > 0) {
        CGSize contentSize = self.scrollView.contentSize;
        contentSize.height = currentHeight;
        self.scrollView.contentSize = contentSize;
        
        CGRect scrollViewFrame = self.scrollView.frame;
        scrollViewFrame.size.height = currentHeight;
        self.scrollView.frame = scrollViewFrame;
        
        [self updateBannerViewSize];
    }
    
    UIView *willShowView = _currentShowView;
    if (didScrollStatus == LBBannerViewRunLoopDidScrollStatusHorizontalLeft) {
        if (_rightOrBottomShowView) {
            if (scrollPercent >= 0.5) {
                willShowView = _rightOrBottomShowView;
            } else {
                willShowView = _currentShowView;
            }
        }
    } else if (didScrollStatus == LBBannerViewRunLoopDidScrollStatusHorizontalRight) {
        if (_leftOrTopShowView) {
            if (scrollPercent >= 0.5) {
                willShowView = _leftOrTopShowView;
            } else {
                willShowView = _currentShowView;
            }
        }
    }
    NSNumber *willShowDataIndexNum = willShowView.bannerViewItemObj.bannerViewItemIndexNum;
    
    [self runLoopSetScrollViewDidScrollWithDidScrollStatus:didScrollStatus scrollPercent:scrollPercent bannerViewSize:self.frame.size willShowDataIndexNum:willShowDataIndexNum willShowView:willShowView];
}
- (void)scrollViewDidScrollVertical:(UIScrollView *)scrollView
{
    NSNumber *endYNum = nil;
    if (!_beginScrollYNum) {
        _beginScrollYNum = [NSNumber numberWithFloat:scrollView.contentOffset.y];
    }
    
    LBBannerViewRunLoopDidScrollStatus didScrollStatus = LBBannerViewRunLoopDidScrollStatusNone;
    
    CGFloat scrollPercent = 0;
    CGFloat currentWidth = 0;
    if (scrollView.contentOffset.y < [_beginScrollYNum floatValue]) {
        //向下滚动
        if (!endYNum) {
            endYNum = [NSNumber numberWithFloat:([_beginScrollYNum floatValue] - self.scrollView.frame.size.height)];
        }
        scrollPercent = 1 - (scrollView.contentOffset.y - [endYNum floatValue]) / self.scrollView.frame.size.height;
        
        if (_leftOrTopShowView) {
            CGFloat changeWidth = _leftOrTopShowView.frame.size.width - _currentShowView.frame.size.width;
            
            currentWidth = _currentShowView.frame.size.width + changeWidth * scrollPercent;
        } else {
            scrollPercent = 1;
        }
        
        didScrollStatus = LBBannerViewRunLoopDidScrollStatusVerticalBottom;
        
    } else if (scrollView.contentOffset.y > [_beginScrollYNum floatValue]) {
        //向上滚动
        if (!endYNum) {
            endYNum = [NSNumber numberWithFloat:([_beginScrollYNum floatValue] + self.scrollView.frame.size.height)];
        }
        scrollPercent = 1 - ([endYNum floatValue] - scrollView.contentOffset.y) / self.scrollView.frame.size.height;
        
        if (_rightOrBottomShowView) {
            CGFloat changeWidth = _rightOrBottomShowView.frame.size.width - _currentShowView.frame.size.width;
            
            currentWidth = _currentShowView.frame.size.width + changeWidth * scrollPercent;
        } else {
            scrollPercent = 1;
        }
        
        didScrollStatus = LBBannerViewRunLoopDidScrollStatusVerticalTop;
        
    } else {
        //没有滚动
        scrollPercent = 0;
        currentWidth = _currentShowView.frame.size.width;
    }
    
    if (scrollPercent < 0) {
        scrollPercent = 0;
    } else if (scrollPercent > 1) {
        scrollPercent = 1;
    }
    
    NSLog(@"lbbannerview--DidScrollVertical--scrollPercent:%f--currentWidth:%f",scrollPercent,currentWidth);
    
    BOOL autoSize = [self runLoopGetSizeNeedAuto];
    if (autoSize && currentWidth > 0) {
        CGSize contentSize = self.scrollView.contentSize;
        contentSize.width = currentWidth;
        self.scrollView.contentSize = contentSize;
        
        CGRect scrollViewFrame = self.scrollView.frame;
        scrollViewFrame.size.width = currentWidth;
        self.scrollView.frame = scrollViewFrame;
        
        [self updateBannerViewSize];
    }
    
    UIView *willShowView = _currentShowView;
    if (didScrollStatus == LBBannerViewRunLoopDidScrollStatusVerticalTop) {
        if (_rightOrBottomShowView) {
            if (scrollPercent >= 0.5) {
                willShowView = _rightOrBottomShowView;
            } else {
                willShowView = _currentShowView;
            }
        }
    } else if (didScrollStatus == LBBannerViewRunLoopDidScrollStatusVerticalBottom) {
        if (_leftOrTopShowView) {
            if (scrollPercent >= 0.5) {
                willShowView = _leftOrTopShowView;
            } else {
                willShowView = _currentShowView;
            }
        }
    }
    NSNumber *willShowDataIndexNum = willShowView.bannerViewItemObj.bannerViewItemIndexNum;
    
    [self runLoopSetScrollViewDidScrollWithDidScrollStatus:didScrollStatus scrollPercent:scrollPercent bannerViewSize:self.frame.size willShowDataIndexNum:willShowDataIndexNum willShowView:willShowView];
}

- (void)scrollViewEndDeceleratingHorizontal:(UIScrollView *)scrollView
{
    NSInteger index = scrollView.contentOffset.x / self.scrollView.frame.size.width;
    NSLog(@"lbbannerview--EndDeceleratingHorizontal--index:%ld",(long)index);
    if (_needExecuteRunLoop) {
        if (index == 0) {
            self.scrollView.contentOffset = CGPointMake(self.scrollView.contentSize.width - self.scrollView.frame.size.width * 2, 0);
        } else if (index == self.scrollView.subviews.count - 1) {
            self.scrollView.contentOffset = CGPointMake(self.scrollView.frame.size.width, 0);
        }
    }
    
    NSInteger newIndex = self.scrollView.contentOffset.x / self.scrollView.frame.size.width;
    NSLog(@"lbbannerview--EndDeceleratingHorizontal--newIndex:%ld",(long)newIndex);
    
    [self setShowViewAfterScrollViewEndDeceleratingWithNewIndex:newIndex];
    
    [self resetSizeAfterScrollViewEndDeceleratingWithNewIndex:newIndex isHorizontal:YES];
}

- (void)scrollViewEndDeceleratingVertical:(UIScrollView *)scrollView
{
    NSInteger index = scrollView.contentOffset.y / self.scrollView.frame.size.height;
    NSLog(@"lbbannerview--EndDeceleratingVertical--index:%ld",(long)index);
    if (_needExecuteRunLoop) {
        if (index == 0) {
            self.scrollView.contentOffset = CGPointMake(0, self.scrollView.contentSize.height - self.scrollView.frame.size.height * 2);
        } else if (index == self.scrollView.subviews.count - 1) {
            self.scrollView.contentOffset = CGPointMake(0, self.scrollView.frame.size.height);
        }
    }
    
    NSInteger newIndex = self.scrollView.contentOffset.y / self.scrollView.frame.size.height;
    NSLog(@"lbbannerview--EndDeceleratingVertical--newIndex:%ld",(long)newIndex);
    
    [self setShowViewAfterScrollViewEndDeceleratingWithNewIndex:newIndex];
    
    [self resetSizeAfterScrollViewEndDeceleratingWithNewIndex:newIndex isHorizontal:NO];
}

- (void)setShowViewAfterScrollViewEndDeceleratingWithNewIndex:(NSInteger)newIndex
{
    if (newIndex < self.scrollView.subviews.count) {
        UIView *currentShowView = self.scrollView.subviews[newIndex];
        _currentShowView = currentShowView;
        
        if (newIndex - 1 < 0) {
            _leftOrTopShowView = nil;
        } else {
            if (newIndex - 1 < self.scrollView.subviews.count) {
                UIView *leftOrTopView = self.scrollView.subviews[newIndex - 1];
                _leftOrTopShowView = leftOrTopView;
            }
        }
        
        if (newIndex + 1 >= self.scrollView.subviews.count) {
            _rightOrBottomShowView = nil;
        } else {
            if (newIndex + 1 < self.scrollView.subviews.count) {
                UIView *rightOrBottomView = self.scrollView.subviews[newIndex + 1];
                _rightOrBottomShowView = rightOrBottomView;
            }
        }
        
        NSObject *currentShowViewObj = currentShowView.bannerViewItemObj;
        NSNumber *currentShowViewObjIndexNum = currentShowViewObj.bannerViewItemIndexNum;
        [self runLoopSetScrollViewEndDeceleratingWithShowDataIndexNum:currentShowViewObjIndexNum showView:currentShowView];
    }
}

- (void)resetSizeAfterScrollViewEndDeceleratingWithNewIndex:(NSInteger)newIndex isHorizontal:(BOOL)isHorizontal
{
    if (newIndex < self.scrollView.subviews.count) {
        UIView *currentShowView = self.scrollView.subviews[newIndex];
        
        BOOL autoSize = [self runLoopGetSizeNeedAuto];
        if (autoSize) {
            if (isHorizontal) {
                CGSize contentSize = self.scrollView.contentSize;
                contentSize.height = currentShowView.frame.size.height;
                self.scrollView.contentSize = contentSize;
                
                CGRect scrollViewFrame = self.scrollView.frame;
                scrollViewFrame.size.height = currentShowView.frame.size.height;
                self.scrollView.frame = scrollViewFrame;
            } else {
                CGSize contentSize = self.scrollView.contentSize;
                contentSize.width = currentShowView.frame.size.width;
                self.scrollView.contentSize = contentSize;
                
                CGRect scrollViewFrame = self.scrollView.frame;
                scrollViewFrame.size.width = currentShowView.frame.size.width;
                self.scrollView.frame = scrollViewFrame;
            }
            
            [self updateBannerViewSize];
        }
        
        [self runLoopSetScrollViewDidScrollWithDidScrollStatus:LBBannerViewRunLoopDidScrollStatusNone scrollPercent:1.0 bannerViewSize:self.frame.size willShowDataIndexNum:nil willShowView:nil];
    }
}

#pragma mark - 数据展示逻辑--渐变动效逻辑
- (void)showBannerViewForAlphaAnimation
{
    [self cleanAllDatas];
    
    _alphaCurrentShowObjIndex = 0;
    
    if (_alphaDelegate) {
        BOOL needShowDatas = NO;
        
        NSArray *objArr = [self alphaGetShowViewDataObjectList];
        if (objArr && [objArr isKindOfClass:[NSArray class]] && objArr.count > 0) {
            needShowDatas = YES;
        }
        if (needShowDatas) {
            
            NSMutableArray *newObjArr = [NSMutableArray array];
            for (int i = 0; i < objArr.count; i++) {
                NSObject *obj = objArr[i];
                obj.bannerViewItemIndexNum = [NSNumber numberWithInt:i];
                [newObjArr addObject:obj];
            }
            
            _alphaObjArr = newObjArr;
            if (newObjArr.count > 1) {
                UIView *firstView = [self alphaAddObjViewWithObjArr:newObjArr index:_alphaCurrentShowObjIndex];
                _alphaCurrentShowView = firstView;
                
                CGRect bannerViewFrame = self.frame;
                bannerViewFrame.size = firstView.frame.size;
                self.frame = bannerViewFrame;
                
                [self updateBannerViewSize];
                
                NSInteger nextIndex = _alphaCurrentShowObjIndex + 1;
                if (nextIndex >= newObjArr.count) {
                    nextIndex = 0;
                }
                _alphaNextShowObjIndex = nextIndex;
                UIView *nextView = [self alphaAddObjViewWithObjArr:newObjArr index:nextIndex];
                nextView.alpha = 0;
                _alphaNextShowView = nextView;
                
                [self beginExecuteAlphaAnimation];
                
                [self showIndicatorViewToDo];
                
            } else {
                UIView *firstView = [self alphaAddObjViewWithObjArr:newObjArr index:0];
                
                CGRect bannerViewFrame = self.frame;
                bannerViewFrame.size = firstView.frame.size;
                self.frame = bannerViewFrame;
                
                [self updateBannerViewSize];
            }
        }
    }
}

- (UIView *)alphaAddObjViewWithObjArr:(NSArray *)objArr index:(NSInteger)index
{
    if (index >= objArr.count) {
        return nil;
    }
    NSObject *obj = objArr[index];
    UIView *objView = [self alphaGetViewForObj:obj];
    if (objView && [objView isKindOfClass:[UIView class]]) {
        LBBannerViewAlphaAutoSizeType autoSizeType = [self alphaGetAlphaAutoSizeType];
        if (autoSizeType == LBBannerViewAlphaAutoSizeTypeNone) {
            objView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        } else if (autoSizeType == LBBannerViewAlphaAutoSizeTypeWidth) {
            objView.frame = CGRectMake(0, 0, objView.frame.size.width, self.frame.size.height);
        } else if (autoSizeType == LBBannerViewAlphaAutoSizeTypeHeight) {
            objView.frame = CGRectMake(0, 0, self.frame.size.width, objView.frame.size.height);
        }
        
        objView.bannerViewItemObj = obj;
        
        [self setItemViewRectObjWithItemView:objView frame:objView.frame];
        
        [self insertSubview:objView atIndex:0];
        
        if (autoSizeType == LBBannerViewAlphaAutoSizeTypeWidth || autoSizeType == LBBannerViewAlphaAutoSizeTypeHeight) {
            [objView addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];
        }
        return objView;
    } else {
        return nil;
    }
}
    
#pragma mark 渐变逻辑
- (void)beginExecuteAlphaAnimation
{
    CGFloat delayTime = [self alphaGetChangeDelayTime];
    
    __weak typeof(self) wself = self;
    [self.alphaExecuteTool executeSomethingAfterDelay:delayTime repeat:YES afterDelay:^{
        __strong typeof(wself) sself = wself;
        [sself alphaAnimationToDo];
    }];
}

- (void)stopAlphaExecuteTool
{
    if (_alphaExecuteTool) {
        [_alphaExecuteTool cancleExecuteBlockWithCompleteBlock:^{
                    
        }];
        _alphaExecuteTool = nil;
    }
}

- (void)alphaAnimationToDo
{
    CGFloat animationTime = [self alphaGetChangeAnimationTime];
    
    __weak typeof(self) wself = self;
    [self.alphaDisplayLinkTool begeinUpdateDataWithDuration:animationTime beginUpdateBlock:^{
        __strong typeof(wself) sself = wself;
        [sself alphaSetAlphaAnimationWillExecuteWithWillShowDataIndexNum:@(sself->_alphaNextShowObjIndex) willShowView:sself->_alphaNextShowView];
    } updatingBlock:^(CGFloat progress) {
        __strong typeof(wself) sself = wself;
        sself->_alphaCurrentShowView.alpha = 1 - progress;
        sself->_alphaNextShowView.alpha = progress;
        
        LBBannerViewAlphaAutoSizeType autoSizeType = [self alphaGetAlphaAutoSizeType];
        
        CGRect bannerViewFrame = sself.frame;
        if (autoSizeType == LBBannerViewAlphaAutoSizeTypeWidth) {
            CGFloat changeWidth = sself->_alphaNextShowView.frame.size.width - sself->_alphaCurrentShowView.frame.size.width;
            bannerViewFrame.size.width = sself->_alphaCurrentShowView.frame.size.width + changeWidth * progress;
        } else if (autoSizeType == LBBannerViewAlphaAutoSizeTypeHeight) {
            CGFloat changeHeight = sself->_alphaNextShowView.frame.size.height - sself->_alphaCurrentShowView.frame.size.height;
            bannerViewFrame.size.height = sself->_alphaCurrentShowView.frame.size.height + changeHeight * progress;
        }
        sself.frame = bannerViewFrame;
        
        [sself alphaSetAlphaAnimationExecutingWithBannerViewSize:sself.frame.size changePercent:progress willShowDataIndexNum:@(sself->_alphaNextShowObjIndex) willShowView:sself->_alphaNextShowView];
        
        [sself updateBannerViewSize];
        
    } finishUpdateBlock:^{
        __strong typeof(wself) sself = wself;
        sself->_alphaCurrentShowView.alpha = 0;
        sself->_alphaNextShowView.alpha = 1;
        
        [sself->_alphaCurrentShowView removeFromSuperview];
        
        sself->_alphaCurrentShowView = sself->_alphaNextShowView;
        sself->_alphaCurrentShowObjIndex = sself->_alphaNextShowObjIndex;
        
        [sself alphaSetAlphaAnimationDidEndWithDidShowDataIndexNum:@(sself->_alphaCurrentShowObjIndex) didShowView:sself->_alphaCurrentShowView];
        
        NSInteger nextIndex = sself->_alphaCurrentShowObjIndex + 1;
        if (nextIndex >= sself->_alphaObjArr.count) {
            nextIndex = 0;
        }
        sself->_alphaNextShowObjIndex = nextIndex;
        UIView *nextView = [sself alphaAddObjViewWithObjArr:sself->_alphaObjArr index:nextIndex];
        nextView.alpha = 0;
        sself->_alphaNextShowView = nextView;
    }];
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"frame"]) {
        if ([object isKindOfClass:[UIView class]]) {
            UIView *itemView = (UIView *)object;
            if (itemView.bannerViewItemRectObj) {
                
                CGRect newFrame = [[change objectForKey:NSKeyValueChangeNewKey] CGRectValue];
                
                if (_showType == LBBannerViewDataShowTypeRunLoop) {
                    [self observeValueForRunLoopWithItemView:itemView newFrame:newFrame];
                } else if (_showType == LBBannerViewDataShowTypeAlphaAnimation) {
                    [self observeValueForAlphaAnimationWithItemView:itemView newFrame:newFrame];
                }
            }
        }
    }
}

- (void)observeValueForRunLoopWithItemView:(UIView *)itemView newFrame:(CGRect)newFrame
{
    CGRect oldFrame = itemView.bannerViewItemRectObj.frame;
    
    if (_runLoopOrientation == LBBannerViewRunLoopOrientationNone) {
        if (oldFrame.size.height != newFrame.size.height) {
            NSInteger itemViewIndex = [self.scrollView.subviews indexOfObject:itemView];
            if (itemViewIndex + 1 < self.scrollView.subviews.count) {
                UIView *lastSubView = nil;
                for (NSInteger i = itemViewIndex + 1; i < self.scrollView.subviews.count; i++) {
                    UIView *subView = self.scrollView.subviews[i];
                    if (lastSubView) {
                        CGRect subViewFrame = subView.frame;
                        subViewFrame.size.width = self.scrollView.frame.size.width;
                        subViewFrame.origin.y = CGRectGetMaxY(lastSubView.frame);
                        subView.frame = subViewFrame;
                    } else {
                        CGRect subViewFrame = subView.frame;
                        subViewFrame.size.width = self.scrollView.frame.size.width;
                        subViewFrame.origin.y = CGRectGetMaxY(itemView.frame);
                        subView.frame = subViewFrame;
                    }
                    
                    [self setItemViewRectObjWithItemView:subView frame:subView.frame];
                    
                    lastSubView = subView;
                }
                
                [self setItemViewRectObjWithItemView:itemView frame:newFrame];
                
                self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, CGRectGetMaxY(lastSubView.frame));
                
                CGRect scrollViewFrame = self.scrollView.frame;
                scrollViewFrame.size.height = CGRectGetMaxY(lastSubView.frame);
                self.scrollView.frame = scrollViewFrame;
                
                [self updateBannerViewSize];
            } else if (itemViewIndex == self.scrollView.subviews.count - 1) {
                
                [self setItemViewRectObjWithItemView:itemView frame:newFrame];
                
                self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, CGRectGetMaxY(itemView.frame));
                
                CGRect scrollViewFrame = self.scrollView.frame;
                scrollViewFrame.size.height = CGRectGetMaxY(itemView.frame);
                self.scrollView.frame = scrollViewFrame;
                
                [self updateBannerViewSize];
            }
            
        }
    } else {
        
        if (_currentShowView == itemView) {
            
            [self setItemViewRectObjWithItemView:itemView frame:newFrame];
            
            if (_runLoopOrientation == LBBannerViewRunLoopOrientationHorizontalLeft || _runLoopOrientation == LBBannerViewRunLoopOrientationHorizontalRight) {
                
                self.scrollView.contentSize = CGSizeMake(self.scrollView.contentSize.width, CGRectGetHeight(itemView.frame));
                
                CGRect scrollViewFrame = self.scrollView.frame;
                scrollViewFrame.size.height = CGRectGetHeight(itemView.frame);
                self.scrollView.frame = scrollViewFrame;
                
                [self updateBannerViewSize];
                
            } else if (_runLoopOrientation == LBBannerViewRunLoopOrientationVerticalTop || _runLoopOrientation == LBBannerViewRunLoopOrientationVerticalBottom) {
                
                self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(itemView.frame), self.scrollView.contentSize.height);
                
                CGRect scrollViewFrame = self.scrollView.frame;
                scrollViewFrame.size.width = CGRectGetWidth(itemView.frame);
                self.scrollView.frame = scrollViewFrame;
                
                [self updateBannerViewSize];
                
            }
        }
    }
}

- (void)observeValueForAlphaAnimationWithItemView:(UIView *)itemView newFrame:(CGRect)newFrame
{
    if (itemView.alpha == 1) {
//        CGRect oldFrame = itemView.bannerViewItemRectObj.frame;
        
        [self setItemViewRectObjWithItemView:itemView frame:newFrame];
        
        LBBannerViewAlphaAutoSizeType autoSizeType = [self alphaGetAlphaAutoSizeType];
        if (autoSizeType == LBBannerViewAlphaAutoSizeTypeWidth) {
            CGRect bannerViewFrame = self.frame;
            bannerViewFrame.size.width = newFrame.size.width;
            self.frame = bannerViewFrame;
            
            [self updateBannerViewSize];
            
        } else if (autoSizeType == LBBannerViewAlphaAutoSizeTypeHeight) {
            CGRect bannerViewFrame = self.frame;
            bannerViewFrame.size.height = newFrame.size.height;
            self.frame = bannerViewFrame;
            
            [self updateBannerViewSize];
        }
    }
}

#pragma mark - 加载指示器
- (LBBannerViewIndicatorView *)indicatorView
{
    if (!_indicatorView) {
        _indicatorView = [[LBBannerViewIndicatorView alloc] initWithFrame:CGRectZero];
        _indicatorView.delegate = self;
    }
    return _indicatorView;
}
- (void)showIndicatorViewToDo
{
    if (_indicatorDelegate) {
        UIView *normalView = [self getIndicatorNormalView];
        UIView *selectedView = [self getIndicatorSelectedView];
        if ((normalView && [normalView isKindOfClass:[UIView class]]) && (selectedView && [selectedView isKindOfClass:[UIView class]])) {
            if (_indicatorView) {
                [_indicatorView removeFromSuperview];
                _indicatorView = nil;
            }
            if (_showType == LBBannerViewDataShowTypeRunLoop) {
                if (_runLoopObjArr.count > 1) {
                    [self.indicatorView indicatorViewShowDatasWithItemCount:_runLoopObjArr.count];
                    [self addSubview:self.indicatorView];
                }
            } else if (_showType == LBBannerViewDataShowTypeAlphaAnimation) {
                if (_alphaObjArr.count > 1) {
                    [self.indicatorView indicatorViewShowDatasWithItemCount:_alphaObjArr.count];
                    [self addSubview:self.indicatorView];
                }
            }
            
            [self setIndicatorViewShowIndex:0];
            
        }
    }
}

- (void)setIndicatorViewShowIndex:(NSInteger)showIndex
{
    if (_indicatorView) {
        [self.indicatorView indicatorViewShowIndex:showIndex];
        [self updateIndicatorViewPoint];
    }
}

- (void)updateIndicatorViewPoint
{
    if (_indicatorView) {
        BOOL indicatorIsCenter = [self getIndicatorIsCenter];
        CGFloat indicatorBottomOrRightSpace = [self getIndicatorBottomOrRightSpace];
        CGFloat indicatorLeftOrTopSpace = [self getIndicatorLeftOrTopSpace];
        
        BOOL indicatorIsHorizontalShow = [self.indicatorView getIsHorizontalShow];
        
        CGRect indicatorFrame = self.indicatorView.frame;
        if (indicatorIsHorizontalShow) {
            indicatorFrame.origin.y = self.frame.size.height - indicatorBottomOrRightSpace - indicatorFrame.size.height;
            if (indicatorIsCenter) {
                indicatorFrame.origin.x = (self.frame.size.width - indicatorFrame.size.width) / 2.0;
            } else {
                indicatorFrame.origin.x = indicatorLeftOrTopSpace;
            }
        } else {
            indicatorFrame.origin.x = self.frame.size.width - indicatorBottomOrRightSpace - indicatorFrame.size.width;
            if (indicatorIsCenter) {
                indicatorFrame.origin.y = (self.frame.size.height - indicatorFrame.size.height) / 2.0;
            } else {
                indicatorFrame.origin.y = indicatorLeftOrTopSpace;
            }
        }
        self.indicatorView.frame = indicatorFrame;
    }
}

#pragma mark LBBannerViewIndicatorViewDelegate
- (BOOL)indicatorViewIsHorizontalShow:(LBBannerViewIndicatorView *_Nonnull)indicatorView
{
    if (_showType == LBBannerViewDataShowTypeRunLoop) {
        if (_runLoopOrientation == LBBannerViewRunLoopOrientationHorizontalLeft || _runLoopOrientation == LBBannerViewRunLoopOrientationHorizontalRight) {
            return YES;
        } else if (_runLoopOrientation == LBBannerViewRunLoopOrientationVerticalTop || _runLoopOrientation == LBBannerViewRunLoopOrientationVerticalBottom) {
            return NO;
        }
    } else if (_showType == LBBannerViewDataShowTypeAlphaAnimation) {
        LBBannerViewAlphaAutoSizeType autoSizeType = [self alphaGetAlphaAutoSizeType];
        if (autoSizeType == LBBannerViewAlphaAutoSizeTypeHeight) {
            return YES;
        } else if (autoSizeType == LBBannerViewAlphaAutoSizeTypeWidth) {
            return NO;
        }
    }
    return YES;
}
- (UIView *_Nonnull)indicatorViewItemNormalView:(LBBannerViewIndicatorView *_Nonnull)indicatorView
{
    UIView *normalView = [self getIndicatorNormalView];
    return normalView;
}
- (UIView *_Nonnull)indicatorViewItemSelectedView:(LBBannerViewIndicatorView *_Nonnull)indicatorView
{
    UIView *selectedView = [self getIndicatorSelectedView];
    return selectedView;
}
- (CGFloat)indicatorViewItemToItemSpace:(LBBannerViewIndicatorView *_Nonnull)indicatorView
{
    CGFloat space = [self getIndicatorItemToItemSpace];
    return space;
}
- (BOOL)indicatorViewIndicatorViewCanClick:(LBBannerViewIndicatorView *_Nonnull)indicatorView
{
    BOOL canClick = [self getIndicatorCanClick];
    return canClick;
}
- (void)indicatorViewIndicatorViewClick:(LBBannerViewIndicatorView *_Nonnull)indicatorView
{
    if (_showType == LBBannerViewDataShowTypeRunLoop) {
        LBBannerViewRunLoopType runLoopType = [self runLoopGetRunLoopType];
        if (runLoopType == LBBannerViewRunLoopTypeNone) {
            if (_runLoopOrientation == LBBannerViewRunLoopOrientationHorizontalLeft || _runLoopOrientation == LBBannerViewRunLoopOrientationHorizontalRight) {
                if (self.scrollView.contentOffset.x != self.scrollView.contentSize.width - self.scrollView.frame.size.width) {
                    [self runLoopToLeftToDo];
                }
            } else if (_runLoopOrientation == LBBannerViewRunLoopOrientationVerticalTop || _runLoopOrientation == LBBannerViewRunLoopOrientationVerticalBottom) {
                if (self.scrollView.contentOffset.y != self.scrollView.contentSize.height - self.scrollView.frame.size.height) {
                    [self runLoopToTopToDo];
                }
            }
        } else if (runLoopType == LBBannerViewRunLoopTypeAuto || runLoopType == LBBannerViewRunLoopTypeByHand) {
            [self executeRunLoopToDo];
        }
    } else if (_showType == LBBannerViewDataShowTypeAlphaAnimation) {
        [self alphaAnimationToDo];
    }
}

#pragma mark - other
#pragma mark 设置bannerView的size
- (void)updateBannerViewSize
{
    if (_showType == LBBannerViewDataShowTypeRunLoop) {
        
        CGRect bannerViewFrame = self.frame;
        bannerViewFrame.size = self.scrollView.frame.size;
        self.frame = bannerViewFrame;
        
        [self runLoopSetBannerViewFrameDidChanged];
    } else if (_showType == LBBannerViewDataShowTypeAlphaAnimation) {
        [self alphaSetBannerViewFrameDidChanged];
    }
    
    [self updateIndicatorViewPoint];
}

#pragma mark 设置itemView的rectObj属性
- (void)setItemViewRectObjWithItemView:(UIView *)itemView frame:(CGRect)frame
{
    LBBannerViewCGRectObject *rectObj = [[LBBannerViewCGRectObject alloc] init];
    rectObj.frame = frame;
    itemView.bannerViewItemRectObj = rectObj;
}

#pragma mark 清除所有数据
//将清除scrollView以及scrollView内所有子view，并清除缓存数据
- (void)cleanAllDatas
{
    [self stopRunLoopExecuteTool];
    
    if (_scrollView) {
        
        for (UIView *subView in self.scrollView.subviews) {
            [subView removeObserver:self forKeyPath:@"frame"];
            [subView removeFromSuperview];
        }
        
        [self.scrollView removeFromSuperview];
        _scrollView = nil;
    }
    
    _needExecuteRunLoop = NO;
    
    _leftOrTopShowView = nil;
    _currentShowView = nil;
    _rightOrBottomShowView = nil;
    
    _beginScrollXNum = nil;
    _beginScrollYNum = nil;
    
    
    [self stopAlphaExecuteTool];
    
    _alphaCurrentShowObjIndex = 0;
    _alphaNextShowObjIndex = 0;
    _alphaCurrentShowView = nil;
    _alphaNextShowView = nil;
    
    if (_alphaDisplayLinkTool) {
        [_alphaDisplayLinkTool clearAllData];
        _alphaDisplayLinkTool = nil;
    }
    
    if (_indicatorView) {
        [self.indicatorView clearAllDatas];
        _indicatorView = nil;
    }
}
@end
