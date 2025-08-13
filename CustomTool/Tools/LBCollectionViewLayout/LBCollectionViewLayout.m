//
//  LBCollectionViewLayout.m
//
//  Created by Liubo on 2025/5/19.
//

#import "LBCollectionViewLayout.h"

@interface LBCollectionViewLayout ()

@property (nonatomic, strong) NSMutableArray<UICollectionViewLayoutAttributes *> *itemAttributes;
@property (nonatomic, strong) NSMutableDictionary<NSIndexPath *, UICollectionViewLayoutAttributes *> *headerAttributes;
@property (nonatomic, strong) NSMutableDictionary<NSIndexPath *, UICollectionViewLayoutAttributes *> *footerAttributes;
@property (nonatomic, assign) CGSize contentSize;
@property (nonatomic, assign) BOOL isHorizontal;

@end

@implementation LBCollectionViewLayout

- (void)prepareLayout {
    [super prepareLayout];

    self.itemAttributes = [NSMutableArray array];
    self.headerAttributes = [NSMutableDictionary dictionary];
    self.footerAttributes = [NSMutableDictionary dictionary];

    NSInteger sectionCount = [self.collectionView numberOfSections];
    self.isHorizontal = (self.delegate && [self.delegate respondsToSelector:@selector(layoutIsScrollHorizontal:)] &&
                         [self.delegate layoutIsScrollHorizontal:self]);

    UIEdgeInsets edgeInsets = UIEdgeInsetsZero;
    if (self.delegate && [self.delegate respondsToSelector:@selector(layoutEdgeInsets:)]) {
        edgeInsets = [self.delegate layoutEdgeInsets:self];
    }

    CGSize collectionSize = self.collectionView.bounds.size;
    CGFloat collectionWidth = collectionSize.width - edgeInsets.left - edgeInsets.right;
    CGFloat collectionHeight = collectionSize.height - edgeInsets.top - edgeInsets.bottom;

    CGFloat offset = self.isHorizontal ? edgeInsets.left : edgeInsets.top;

    for (NSInteger section = 0; section < sectionCount; section++) {
        NSInteger spanCount = 1;
        if (self.delegate && [self.delegate respondsToSelector:@selector(collectionViewLayout:spanCountForSection:)]) {
            spanCount = [self.delegate collectionViewLayout:self spanCountForSection:section];
        }
        spanCount = MAX(spanCount, 1);
        
        CGFloat xAxisSpace = 0;
        if (self.delegate && [self.delegate respondsToSelector:@selector(collectionViewLayout:xAxisSpaceForSection:)]) {
            xAxisSpace = [self.delegate collectionViewLayout:self xAxisSpaceForSection:section];
        }

        CGFloat yAxisSpace = 0;
        if (self.delegate && [self.delegate respondsToSelector:@selector(collectionViewLayout:yAxisSpaceForSection:)]) {
            yAxisSpace = [self.delegate collectionViewLayout:self yAxisSpaceForSection:section];
        }
        
        UIEdgeInsets headerInsets = UIEdgeInsetsZero;
        if (self.delegate && [self.delegate respondsToSelector:@selector(collectionViewLayout:headerEdgeInsetsForSection:)]) {
            headerInsets = [self.delegate collectionViewLayout:self headerEdgeInsetsForSection:section];
        }
        
        UIEdgeInsets footerInsets = UIEdgeInsetsZero;
        if (self.delegate && [self.delegate respondsToSelector:@selector(collectionViewLayout:footerEdgeInsetsForSection:)]) {
            footerInsets = [self.delegate collectionViewLayout:self footerEdgeInsetsForSection:section];
        }
        
        BOOL isSticky = NO;
        if (self.delegate && [self.delegate respondsToSelector:@selector(collectionViewLayout:shouldStickHeaderForSection:)]) {
            isSticky = [self.delegate collectionViewLayout:self shouldStickHeaderForSection:section];
        }
        
        NSMutableArray<NSNumber *> *spanOffsets = [NSMutableArray arrayWithCapacity:spanCount];
        for (NSInteger i = 0; i < spanCount; i++) {
            [spanOffsets addObject:@(offset)];
        }

        NSIndexPath *headerIndexPath = [NSIndexPath indexPathForItem:0 inSection:section];
        CGFloat headerLength = 0;
        if (self.delegate && [self.delegate respondsToSelector:@selector(collectionViewLayout:headerLengthForSection:)]) {
            headerLength = [self.delegate collectionViewLayout:self headerLengthForSection:section];
        }
        headerLength = MAX(headerLength, 0);
        
        if (headerLength > 0) {
            UICollectionViewLayoutAttributes *attr = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader withIndexPath:headerIndexPath];
            CGFloat maxOffset = [[spanOffsets valueForKeyPath:@"@max.self"] floatValue];
            CGRect frame;
            if (self.isHorizontal) {
                CGFloat x = maxOffset + headerInsets.left;
                CGFloat y = headerInsets.top;
                CGFloat width = headerLength;
                CGFloat height = collectionSize.height - headerInsets.top - headerInsets.bottom;
                frame = CGRectMake(x, y, width, height);
            } else {
                CGFloat x = headerInsets.left;
                CGFloat y = maxOffset + headerInsets.top;
                CGFloat width = collectionSize.width - headerInsets.left - headerInsets.right;
                CGFloat height = headerLength;
                frame = CGRectMake(x, y, width, height);
            }
            attr.frame = frame;
            attr.zIndex = isSticky ? 2048 : 1024;
            self.headerAttributes[headerIndexPath] = attr;

            CGFloat newOffset = self.isHorizontal ? CGRectGetMaxX(frame) + headerInsets.right : CGRectGetMaxY(frame) + headerInsets.bottom;
            for (NSInteger i = 0; i < spanCount; i++) {
                spanOffsets[i] = @(newOffset);
            }
        }

        NSInteger itemCount = [self.collectionView numberOfItemsInSection:section];
        for (NSInteger item = 0; item < itemCount; item++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item inSection:section];
            CGFloat itemLength = 0;
            if (self.delegate && [self.delegate respondsToSelector:@selector(collectionViewLayout:itemLengthForIndexPath:)]) {
                itemLength = [self.delegate collectionViewLayout:self itemLengthForIndexPath:indexPath];
            }
            itemLength = MAX(itemLength, 0);

            BOOL isFullSpan = NO;
            if (self.delegate && [self.delegate respondsToSelector:@selector(collectionViewLayout:itemIsFullSpanForIndexPath:)]) {
                isFullSpan = [self.delegate collectionViewLayout:self itemIsFullSpanForIndexPath:indexPath];
            }

            NSInteger targetSpan = 0;
            CGFloat minOffset = CGFLOAT_MAX;
            for (NSInteger i = 0; i < spanCount; i++) {
                CGFloat offset = [spanOffsets[i] floatValue];
                if (offset < minOffset) {
                    minOffset = offset;
                    targetSpan = i;
                }
            }

            UICollectionViewLayoutAttributes *attr = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
            CGRect frame = CGRectZero;

            if (isFullSpan) {
                CGFloat maxOffset = [[spanOffsets valueForKeyPath:@"@max.self"] floatValue];
                frame = self.isHorizontal ?
                CGRectMake(maxOffset, edgeInsets.top, itemLength, collectionHeight) :
                CGRectMake(edgeInsets.left, maxOffset, collectionWidth, itemLength);
                CGFloat newOffset = self.isHorizontal ? CGRectGetMaxX(frame) + xAxisSpace : CGRectGetMaxY(frame) + yAxisSpace;
                for (NSInteger i = 0; i < spanCount; i++) {
                    spanOffsets[i] = @(newOffset);
                }
            } else {
                CGFloat spanWidth = self.isHorizontal ?
                (collectionHeight - (spanCount - 1) * yAxisSpace) / spanCount :
                (collectionWidth - (spanCount - 1) * xAxisSpace) / spanCount;
                CGFloat x, y, width, height;
                if (self.isHorizontal) {
                    x = [spanOffsets[targetSpan] floatValue];
                    y = edgeInsets.top + targetSpan * (spanWidth + yAxisSpace);
                    width = itemLength;
                    height = spanWidth;
                } else {
                    x = edgeInsets.left + targetSpan * (spanWidth + xAxisSpace);
                    y = [spanOffsets[targetSpan] floatValue];
                    width = spanWidth;
                    height = itemLength;
                }
                frame = CGRectMake(x, y, width, height);
                CGFloat newOffset = self.isHorizontal ? CGRectGetMaxX(frame) + xAxisSpace : CGRectGetMaxY(frame) + yAxisSpace;
                spanOffsets[targetSpan] = @(newOffset);
            }

            attr.frame = frame;
            [self.itemAttributes addObject:attr];
        }

        NSIndexPath *footerIndexPath = [NSIndexPath indexPathForItem:0 inSection:section];
        CGFloat footerLength = 0;
        if (self.delegate && [self.delegate respondsToSelector:@selector(collectionViewLayout:footerLengthForSection:)]) {
            footerLength = [self.delegate collectionViewLayout:self footerLengthForSection:section];
        }
        footerLength = MAX(footerLength, 0);
        
        if (footerLength > 0) {
            UICollectionViewLayoutAttributes *attr = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionFooter withIndexPath:footerIndexPath];
            CGFloat maxOffset = [[spanOffsets valueForKeyPath:@"@max.self"] floatValue];
            CGRect frame = self.isHorizontal ?
            CGRectMake(maxOffset, footerInsets.top, footerLength, collectionSize.height - footerInsets.top - footerInsets.bottom) :
            CGRectMake(footerInsets.left, maxOffset, collectionSize.width - footerInsets.left - footerInsets.right, footerLength);
            attr.frame = frame;
            attr.zIndex = 1024;
            self.footerAttributes[footerIndexPath] = attr;
            CGFloat newOffset = self.isHorizontal ? CGRectGetMaxX(frame) + footerInsets.right : CGRectGetMaxY(frame) + footerInsets.bottom;
            for (NSInteger i = 0; i < spanCount; i++) {
                spanOffsets[i] = @(newOffset);
            }
        }

        offset = [[spanOffsets valueForKeyPath:@"@max.self"] floatValue];
    }

    if (self.isHorizontal) {
        self.contentSize = CGSizeMake(offset + edgeInsets.right, self.collectionView.bounds.size.height);
    } else {
        self.contentSize = CGSizeMake(self.collectionView.bounds.size.width, offset + edgeInsets.bottom);
    }
}

- (CGSize)collectionViewContentSize {
    return self.contentSize;
}

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSMutableArray *allAttributes = [NSMutableArray arrayWithArray:self.itemAttributes];

    [self.headerAttributes enumerateKeysAndObjectsUsingBlock:^(NSIndexPath *indexPath, UICollectionViewLayoutAttributes *attr, BOOL *stop) {
        BOOL stickHeader = NO;
        if (self.delegate && [self.delegate respondsToSelector:@selector(collectionViewLayout:shouldStickHeaderForSection:)]) {
            stickHeader = [self.delegate collectionViewLayout:self shouldStickHeaderForSection:indexPath.section];
        }
        if (stickHeader) {
            UICollectionViewLayoutAttributes *copy = [attr copy];
            CGRect frame = copy.frame;
            if (self.isHorizontal) {
                CGFloat offsetX = self.collectionView.contentOffset.x;
                CGFloat nextHeaderOriginX = CGFLOAT_MAX;
                for (NSIndexPath *otherIndexPath in self.headerAttributes) {
                    if (otherIndexPath.section > indexPath.section) {
                        UICollectionViewLayoutAttributes *nextAttr = self.headerAttributes[otherIndexPath];
                        nextHeaderOriginX = MIN(nextHeaderOriginX, CGRectGetMinX(nextAttr.frame));
                    }
                }
                frame.origin.x = MIN(MAX(offsetX, frame.origin.x), nextHeaderOriginX - frame.size.width);
            } else {
                CGFloat offsetY = self.collectionView.contentOffset.y;
                CGFloat nextHeaderOriginY = CGFLOAT_MAX;
                for (NSIndexPath *otherIndexPath in self.headerAttributes) {
                    if (otherIndexPath.section > indexPath.section) {
                        UICollectionViewLayoutAttributes *nextAttr = self.headerAttributes[otherIndexPath];
                        nextHeaderOriginY = MIN(nextHeaderOriginY, CGRectGetMinY(nextAttr.frame));
                    }
                }
                frame.origin.y = MIN(MAX(offsetY, frame.origin.y), nextHeaderOriginY - frame.size.height);
            }
            copy.frame = frame;
            copy.zIndex = 2048;
            [allAttributes addObject:copy];
        } else if (CGRectIntersectsRect(attr.frame, rect)) {
            [allAttributes addObject:attr];
        }
    }];

    [self.footerAttributes enumerateKeysAndObjectsUsingBlock:^(NSIndexPath *key, UICollectionViewLayoutAttributes *attr, BOOL *stop) {
        if (CGRectIntersectsRect(attr.frame, rect)) {
            [allAttributes addObject:attr];
        }
    }];

    return allAttributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    for (UICollectionViewLayoutAttributes *attr in self.itemAttributes) {
        if ([attr.indexPath isEqual:indexPath]) {
            return attr;
        }
    }
    return nil;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        return self.headerAttributes[indexPath];
    } else if ([kind isEqualToString:UICollectionElementKindSectionFooter]) {
        return self.footerAttributes[indexPath];
    }
    return nil;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    return YES;
}

@end
