//
//  LBBannerViewExecuteTool.h
//
//  Created by Liubo on 2025/1/24.
//  Copyright © 2025 All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LBBannerViewExecuteTool : NSObject
- (void)executeSomethingAfterDelay:(CGFloat)delay repeat:(BOOL)repeat afterDelay:(void(^)(void))afterDelay;
- (void)cancleExecuteBlockWithCompleteBlock:(void (^)(void))completeBlock;
@end

NS_ASSUME_NONNULL_END
