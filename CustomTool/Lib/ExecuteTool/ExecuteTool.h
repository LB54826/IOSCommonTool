//
//  ExecuteTool.h
//
//  Created by lb on 2016/9/14.
//  Copyright © 2016年. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ExecuteTool : NSObject
#pragma mark - 对象方法
- (void)executeSomethingAfterDelay:(CGFloat)delay repeat:(BOOL)repeat afterDelay:(void(^)(void))afterDelay;
- (void)cancleExecuteBlockWithCompleteBlock:(void(^)(void))completeBlock;
#pragma mark - 静态方法
+ (void)executeSomethingAfterDelay:(CGFloat)delay afterDelay:(void(^)(void))afterDelay;
@end
