//
//  TextViewForSuperLinkTool.h
//
//  Created by Liubo on 2024/3/28.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TextViewForSuperLinkTool : NSObject
//设置不同颜色、不同字体
/*
 colorArr、fontArr、diffrentTextArr、underLineStyleArr、linkArr 数组元素数量必须一致；否则diffrentTextArr中的字体按照colorArr和fontArr和underLineStyleArr中的第一项设置，linkArr中的第一项链接点击；如果fontArr或者colorArr或者underLineStyleArr或者linkArr没有值，则按照对应的allFont或者allColor或者NSUnderlineStyleNone设置，点击链接则为空字符串
 */
- (UITextView *)showTextViewWithDiffrentColorArr:(NSArray *__nullable)colorArr diffrentFountArr:(NSArray *__nullable)fontArr diffrentTextArr:(NSArray *__nullable)diffrentTextArr underLineStyleArr:(NSArray *__nullable)underLineStyleArr linkArr:(NSArray *__nullable)linkArr withAllLabelText:(NSString *__nonnull)allLabelText allLabelTextColor:(UIColor *__nonnull)allColor allLabelTextFont:(UIFont *__nonnull)allFont lineSpace:(CGFloat)lineSpace textAlignment:(NSTextAlignment)textAlignment lineBreakMode:(NSLineBreakMode)lineBreakMode clickLinkBlock:(void(^__nullable)(NSString *clickUrl))clickLinkBlock;

//获取内容的尺寸
- (CGSize)getContentSizeWithWantSize:(CGSize)wantSize;
@end

NS_ASSUME_NONNULL_END
