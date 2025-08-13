//
//  LBCollectionViewLayout.h
//
//  Created by Liubo on 2025/5/19.
//

#import <UIKit/UIKit.h>
@class LBCollectionViewLayout;
@protocol LBCollectionViewLayoutDelegate <NSObject>

//是否是横向滚动（默认设置成NO，YES-是横向滚动，NO-竖向滚动）
- (BOOL)layoutIsScrollHorizontal:(LBCollectionViewLayout *_Nonnull)layout;

//整体内容的上下左右的边距
- (UIEdgeInsets)layoutEdgeInsets:(LBCollectionViewLayout *_Nonnull)layout;

// 不同 section 的 spanCount（默认 1）
- (NSInteger)collectionViewLayout:(LBCollectionViewLayout *_Nonnull)layout spanCountForSection:(NSInteger)section;

// 不同 section 的 xAxisSpace（item之间的X轴方向的间距，默认 0）
- (CGFloat)collectionViewLayout:(LBCollectionViewLayout *_Nonnull)layout xAxisSpaceForSection:(NSInteger)section;

// 不同 section 的 yAxisSpace（item之间的Y轴方向间距，默认 0）
- (CGFloat)collectionViewLayout:(LBCollectionViewLayout *_Nonnull)layout yAxisSpaceForSection:(NSInteger)section;

// 不同 section 的 headerEdgeInsets，默认 UIEdgeInsetsZero
- (UIEdgeInsets)collectionViewLayout:(LBCollectionViewLayout *_Nonnull)layout headerEdgeInsetsForSection:(NSInteger)section;

// 不同 section 的 footerEdgeInsets，默认 UIEdgeInsetsZero
- (UIEdgeInsets)collectionViewLayout:(LBCollectionViewLayout *_Nonnull)layout footerEdgeInsetsForSection:(NSInteger)section;

//item显示的长度（竖直滚动时，为item的高度；横向滚动时，为item的宽度）
- (CGFloat)collectionViewLayout:(LBCollectionViewLayout *_Nonnull)layout itemLengthForIndexPath:(NSIndexPath *_Nonnull)indexPath;

//item是否撑满跨度（默认为NO）
- (BOOL)collectionViewLayout:(LBCollectionViewLayout *_Nonnull)layout itemIsFullSpanForIndexPath:(NSIndexPath *_Nonnull)indexPath;

//header的长度（竖直滚动时，为header的高度；横向滚动时，为header的宽度）
- (CGFloat)collectionViewLayout:(LBCollectionViewLayout *_Nonnull)layout headerLengthForSection:(NSInteger)section;

// 是否开启 Header 悬浮（默认为NO）
- (BOOL)collectionViewLayout:(LBCollectionViewLayout *_Nonnull)layout shouldStickHeaderForSection:(NSInteger)section;

// footer的尺寸长度（竖直滚动时，为footer的高度；横向滚动时，为footer的宽度）
- (CGFloat)collectionViewLayout:(LBCollectionViewLayout *_Nonnull)layout footerLengthForSection:(NSInteger)section;
@end

NS_ASSUME_NONNULL_BEGIN

@interface LBCollectionViewLayout : UICollectionViewLayout
@property (nonatomic, assign) id<LBCollectionViewLayoutDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
