//
//  LBBannerViewScrollView.h
//
//  Created by Liubo on 2025/1/24.
//  Copyright © 2025 All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LBBannerViewScrollView : UIScrollView
- (void)setContentOffset:(CGPoint)contentOffset
           withDuration:(NSTimeInterval)duration
              completion:(void (^)(UIScrollView *currentScrollView,BOOL isFinished))completion
         progressHandler:(void (^)(UIScrollView *currentScrollView))progressHandler;
@end

NS_ASSUME_NONNULL_END
