//
//  LBBannerViewDisplayLinkTool.h
//
//  Created by Liubo on 2025/1/24.
//  Copyright © 2025 All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LBBannerViewDisplayLinkTool : NSObject
- (void)begeinUpdateDataWithDuration:(CGFloat)duration
                    beginUpdateBlock:(void(^__nullable)(void))beginUpdateBlock
                       updatingBlock:(void(^__nullable)(CGFloat progress))updatingBlock
                   finishUpdateBlock:(void(^__nullable)(void))finishUpdateBlock;
- (void)clearAllData;
@end

NS_ASSUME_NONNULL_END
