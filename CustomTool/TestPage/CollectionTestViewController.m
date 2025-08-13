//
//  CollectionTestViewController.m
//  CustomTool
//
//  Created by Liubo on 2025/8/13.
//
#define kItemLengthKey @"kItemLengthKey"
#define kItemIsFullSpanKey @"kItemIsFullSpanKey"

#define kItemListKey @"kItemListKey"

#define kHeaderLengthKey @"kItemHeaderLengthKey"
#define kFooterLengthKey @"kItemFooterLengthKey"
#define kStickHeaderKey @"kStickHeaderKey"

#import "CollectionTestViewController.h"
#import "LBCollectionViewLayout.h"
#import "NSObject+Category.h"

@interface CollectionTestViewController ()<LBCollectionViewLayoutDelegate,UICollectionViewDataSource,UICollectionViewDelegate>
{
    NSMutableArray *_allDatas;
}
@property (weak, nonatomic) IBOutlet UICollectionView *collectionVIew;

@end

@implementation CollectionTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _allDatas = [NSMutableArray array];
    
    self.collectionVIew.dataSource = self;
    self.collectionVIew.delegate = self;
    
//    self.collectionVIew.contentInset = UIEdgeInsetsMake(5, 5, 5, 5);
    
    [self.collectionVIew registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    [self.collectionVIew registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderIdentifier"];
    [self.collectionVIew registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"FooterIdentifier"];

    
    LBCollectionViewLayout *layout = [[LBCollectionViewLayout alloc] init];
    layout.delegate = self;
    self.collectionVIew.collectionViewLayout = layout;
    
    [_allDatas addObjectsFromArray:[self getShowDatas]];
    
    [self.collectionVIew reloadData];
    
}

- (NSArray *)getShowDatas
{
    NSMutableArray *itemArr = [NSMutableArray array];
    for (int i = 0;i < 50;i++) {
        NSInteger itemLength = arc4random_uniform(71) + 30;
        NSMutableDictionary *itemDict = [NSMutableDictionary dictionary];
        [itemDict setObject:@(itemLength) forKey:kItemLengthKey];
        BOOL isFullSpan = i == 3 ? YES : NO;
        [itemDict setObject:@(isFullSpan) forKey:kItemIsFullSpanKey];
        
        [itemArr addObject:itemDict];
    }
    
    NSMutableArray *sectionArr = [NSMutableArray array];
    for (int i = 0; i < 5; i++) {
        NSMutableDictionary *sectionDict = [NSMutableDictionary dictionary];
        [sectionDict setObject:itemArr forKey:kItemListKey];
        NSInteger headerLength = arc4random_uniform(11) + 20;
        [sectionDict setObject:@(i == 1 ? 0 : headerLength) forKey:kHeaderLengthKey];
        NSInteger footerLength = arc4random_uniform(11) + 20;
        [sectionDict setObject:@(i == 3 || i == 0 ? 0 : footerLength) forKey:kFooterLengthKey];
        
        BOOL stickHeader = i % 2 == 0 ? YES : NO;
        [sectionDict setObject:@(stickHeader) forKey:kStickHeaderKey];
        
        [sectionArr addObject:sectionDict];
    }
    
    return sectionArr;
}

- (NSDictionary *)sectionDictWithSection:(NSInteger)section
{
    NSDictionary *sectionDict = _allDatas[section];
    return sectionDict;
}

- (NSDictionary *)itemDictWithIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *sectionDict = [self sectionDictWithSection:indexPath.section];
    
    NSArray *itemList = sectionDict[kItemListKey];
    NSInteger row = indexPath.row;
    NSDictionary *itemDict = itemList[row];
    return itemDict;
}

#pragma mark - LBCollectionViewLayoutDelegate
//是否是横向滚动（默认设置成NO，YES-是横向滚动，NO-竖向滚动）
- (BOOL)layoutIsScrollHorizontal:(LBCollectionViewLayout *_Nonnull)layout
{
    return NO;
}

//整体内容的上下左右的边距
- (UIEdgeInsets)layoutEdgeInsets:(LBCollectionViewLayout *_Nonnull)layout
{
    return UIEdgeInsetsMake(10, 30, 15, 5);
//    return UIEdgeInsetsZero;
}

// 不同 section 的 spanCount（默认 1）
- (NSInteger)collectionViewLayout:(LBCollectionViewLayout *_Nonnull)layout spanCountForSection:(NSInteger)section
{
    if (section == 1) {
        return 2;
    } else if (section == 2) {
        return 4;
    }
    return 3;
}

// 不同 section 的 xAxisSpace（item之间的X轴方向的间距，默认 0）
- (CGFloat)collectionViewLayout:(LBCollectionViewLayout *_Nonnull)layout xAxisSpaceForSection:(NSInteger)section
{
    if (section == 0) {
        return 40;
    }
    return 15;
}

// 不同 section 的 yAxisSpace（item之间的Y轴间距，默认 0）
- (CGFloat)collectionViewLayout:(LBCollectionViewLayout *_Nonnull)layout yAxisSpaceForSection:(NSInteger)section
{
    if (section == 0) {
        return 5;
    }
    return 10;
}

// 不同 section 的 headerEdgeInsets，默认 UIEdgeInsetsZero
- (UIEdgeInsets)collectionViewLayout:(LBCollectionViewLayout *_Nonnull)layout headerEdgeInsetsForSection:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 44, 55, 66);
}

// 不同 section 的 footerEdgeInsets，默认 UIEdgeInsetsZero
- (UIEdgeInsets)collectionViewLayout:(LBCollectionViewLayout *_Nonnull)layout footerEdgeInsetsForSection:(NSInteger)section
{
    return UIEdgeInsetsZero;
}

//item显示的长度（竖直滚动时，为item的高度；横向滚动时，为item的宽度）
- (CGFloat)collectionViewLayout:(LBCollectionViewLayout *_Nonnull)layout itemLengthForIndexPath:(NSIndexPath *_Nonnull)indexPath
{
    NSDictionary *itemDict = [self itemDictWithIndexPath:indexPath];
    CGFloat itemLength = [[self getShowStringWithItem:itemDict[kItemLengthKey]] floatValue];
    return itemLength;
}

//item是否撑满跨度（默认为NO）
- (BOOL)collectionViewLayout:(LBCollectionViewLayout *_Nonnull)layout itemIsFullSpanForIndexPath:(NSIndexPath *_Nonnull)indexPath
{
    NSDictionary *itemDict = [self itemDictWithIndexPath:indexPath];
    BOOL isFullSpan = [[self getShowStringWithItem:itemDict[kItemIsFullSpanKey]] boolValue];
    return isFullSpan;
}

//header的长度（竖直滚动时，为header的高度；横向滚动时，为header的宽度）
- (CGFloat)collectionViewLayout:(LBCollectionViewLayout *_Nonnull)layout headerLengthForSection:(NSInteger)section
{
    NSDictionary *sectionDict = [self sectionDictWithSection:section];
    CGFloat headerLength = [[self getShowStringWithItem:sectionDict[kHeaderLengthKey]] floatValue];
    return headerLength;
}

// 是否开启 Header 悬浮（默认为NO）
- (BOOL)collectionViewLayout:(LBCollectionViewLayout *_Nonnull)layout shouldStickHeaderForSection:(NSInteger)section
{
    NSDictionary *sectionDict = [self sectionDictWithSection:section];
    BOOL stickHeader = [[self getShowStringWithItem:sectionDict[kStickHeaderKey]] boolValue];
    return stickHeader;
}

// footer的尺寸长度（竖直滚动时，为footer的高度；横向滚动时，为footer的宽度）
- (CGFloat)collectionViewLayout:(LBCollectionViewLayout *_Nonnull)layout footerLengthForSection:(NSInteger)section
{
    NSDictionary *sectionDict = [self sectionDictWithSection:section];
    CGFloat footerLength = [[self getShowStringWithItem:sectionDict[kFooterLengthKey]] floatValue];
    return footerLength;
}

#pragma mark - UICollectionViewDataSource,UICollectionViewDelegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return _allDatas.count;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSDictionary *sectionDict = [self sectionDictWithSection:section];
    NSArray *itemList = sectionDict[kItemListKey];
    return itemList.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    NSInteger red = arc4random_uniform(256);
    NSInteger green = arc4random_uniform(256);
    NSInteger blue = arc4random_uniform(256);
    CGFloat redFloat = red / 255.0;
    CGFloat greenFloat = green / 255.0;
    CGFloat blueFloat = blue / 255.0;
    cell.backgroundColor = [UIColor colorWithRed:redFloat green:greenFloat blue:blueFloat alpha:1];
    
    for (UIView *subView in cell.contentView.subviews) {
        [subView removeFromSuperview];
    }
    
    UILabel *label = [[UILabel alloc] init];
    label.text = [NSString stringWithFormat:@"item--s:%ld,i:%ld",(long)indexPath.section,indexPath.row];
    label.textColor = [UIColor blackColor];
    label.font = [UIFont systemFontOfSize:10];
    label.textAlignment = NSTextAlignmentCenter;
    [cell.contentView addSubview:label];
    label.frame = cell.bounds;
    return cell;
}



- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
}



- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *itemDict = [self itemDictWithIndexPath:indexPath];
    CGFloat itemLength = [[self getShowStringWithItem:itemDict[kItemLengthKey]] floatValue];
    return CGSizeMake(itemLength, itemLength);
}


- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    
    
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    
    NSDictionary *sectionDict = [self sectionDictWithSection:section];
    CGFloat headerLength = [[self getShowStringWithItem:sectionDict[kHeaderLengthKey]] floatValue];
    return CGSizeMake(headerLength, headerLength);
}
 
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    NSDictionary *sectionDict = [self sectionDictWithSection:section];
    CGFloat footerLength = [[self getShowStringWithItem:sectionDict[kFooterLengthKey]] floatValue];
    return CGSizeMake(footerLength, footerLength);
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if (kind == UICollectionElementKindSectionHeader) {
        if (indexPath.section == 1) {
            return nil;
        }
        UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderIdentifier" forIndexPath:indexPath];
        headerView.backgroundColor = [UIColor darkGrayColor];
        // 配置headerView
        for (UIView *subView in headerView.subviews) {
            [subView removeFromSuperview];
        }
        
        UILabel *label = [[UILabel alloc] init];
        label.text = [NSString stringWithFormat:@"header--s:%ld",(long)indexPath.section];
        label.textColor = [UIColor blackColor];
        label.font = [UIFont systemFontOfSize:10];
        label.textAlignment = NSTextAlignmentCenter;
        [headerView addSubview:label];
        label.frame = headerView.bounds;
        
        return headerView;
    } else if (kind == UICollectionElementKindSectionFooter) {
        if (indexPath.section == 3 || indexPath.section == 0) {
            return nil;
        }
        UICollectionReusableView *footerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"FooterIdentifier" forIndexPath:indexPath];
        footerView.backgroundColor = [UIColor grayColor];
        // 配置footerView
        for (UIView *subView in footerView.subviews) {
            [subView removeFromSuperview];
        }
        
        UILabel *label = [[UILabel alloc] init];
        label.text = [NSString stringWithFormat:@"footer--s:%ld",(long)indexPath.section];
        label.textColor = [UIColor blackColor];
        label.font = [UIFont systemFontOfSize:10];
        label.textAlignment = NSTextAlignmentCenter;
        [footerView addSubview:label];
        
        label.frame = footerView.bounds;
        return footerView;
    }
    return nil;
}

@end
