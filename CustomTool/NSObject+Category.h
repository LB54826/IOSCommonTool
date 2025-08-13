//
//  NSObject+Category.h
//  CustomTool
//
//  Created by Liubo on 2025/8/13.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (Category)
#pragma mark - 将返回的数据转换成字符串格式
- (NSString *)getShowStringWithItem:(id)showItem;
#pragma mark - 富文本相关
#pragma mark 获取不同颜色、字体等不同属性的富文本
/*
 colorArr、fontArr、diffrentTextArr、underLineStyleArr 数组元素数量必须一致，否则diffrentTextArr中的字体按照colorArr和fontArr和underLineStyleArr中的第一项设置，如果fontArr或者colorArr或者underLineStyleArr没有值，则按照对应的allFont或者allColor或者NSUnderlineStyleNone设置;
 lineBreakModel: 如果需要计算size，最好设置成NSLineBreakByWordWrapping
 */
- (NSMutableAttributedString *)getAttributedStringWithDiffrentColorArr:(NSArray *)colorArr diffrentFountArr:(NSArray *)fontArr diffrentTextArr:(NSArray *)diffrentTextArr underLineStyleArr:(NSArray *)underLineStyleArr withAllLabelText:(NSString *)allLabelText allLabelTextColor:(UIColor *)allColor allLabelTextFont:(UIFont *)allFont lineSpace:(CGFloat)lineSpace textAlignment:(NSTextAlignment)textAlignment lineBreakMode:(NSLineBreakMode)lineBreakMode;
#pragma mark 获取相同颜色、字体等属性的富文本
- (NSMutableAttributedString *)getAttributedStringWithTotalStr:(NSString *)totalStr textColor:(UIColor *)textColor textFont:(UIFont *)textFont lineSpace:(CGFloat)lineSpace textAlignment:(NSTextAlignment)textAlignment lineBreakMode:(NSLineBreakMode)lineBreakMode;
#pragma mark 根据富文本对象获取要显示的Size
- (CGSize)textSizeWithAttributesStr:(NSAttributedString *)attrStr wantSize:(CGSize)wantSize;
@end

NS_ASSUME_NONNULL_END
