//
//  TextViewForSuperLinkTool.m
//
//  Created by Liubo on 2024/3/28.
//

#import "TextViewForSuperLinkTool.h"
#import "NSObject+Category.h"

@interface TextViewForSuperLinkTool()<UITextViewDelegate>
{
    UITextView *_textView;
    NSMutableAttributedString *_mutAttrStr;
}
@property (nonatomic, copy) void(^clickLinkBlock)(NSString *clickUrl);
@end

@implementation TextViewForSuperLinkTool
- (UITextView *)showTextViewWithDiffrentColorArr:(NSArray *)colorArr diffrentFountArr:(NSArray *)fontArr diffrentTextArr:(NSArray *)diffrentTextArr underLineStyleArr:(NSArray *)underLineStyleArr linkArr:(NSArray *)linkArr withAllLabelText:(NSString *)allLabelText allLabelTextColor:(UIColor *)allColor allLabelTextFont:(UIFont *)allFont lineSpace:(CGFloat)lineSpace textAlignment:(NSTextAlignment)textAlignment lineBreakMode:(NSLineBreakMode)lineBreakMode clickLinkBlock:(void (^)(NSString * _Nonnull))clickLinkBlock
{
    _clickLinkBlock = clickLinkBlock;
    
    NSString *str = [NSString stringWithFormat:@"%@",allLabelText];
    NSMutableAttributedString *mutAttrStr = [[NSMutableAttributedString alloc]  initWithString:[self getShowStringWithItem:str]];
    [mutAttrStr addAttribute:NSForegroundColorAttributeName value:allColor range:NSMakeRange(0, str.length)];
    [mutAttrStr addAttribute:NSFontAttributeName value:allFont range:NSMakeRange(0, str.length)];
    
    NSString *currentLoc = @"";
    NSString *currentLen = @"";
    
    for (int i = 0; i < diffrentTextArr.count; i++) {
        NSString *diffrentText = [self getShowStringWithItem:diffrentTextArr[i]];
        if (![diffrentText isEqualToString:@""]) {
            NSRange redRange = NSMakeRange(0, 0);
            if ([currentLoc isEqualToString:@""] && [currentLen isEqualToString:@""]) {
                redRange = NSMakeRange([str rangeOfString:diffrentText].location, [str rangeOfString:diffrentText].length);
            } else {
                NSUInteger currentLocInt = [currentLoc integerValue];
                NSUInteger currentLenInt = [currentLen integerValue];
                
                NSString *subStr = [str substringWithRange:NSMakeRange(currentLocInt + currentLenInt, str.length - (currentLocInt + currentLenInt))];
                NSRange subRange = NSMakeRange([subStr rangeOfString:diffrentText].location, [subStr rangeOfString:diffrentText].length);
                redRange = NSMakeRange(currentLocInt + currentLenInt + subRange.location, [str rangeOfString:diffrentText].length);
            }
            currentLoc = [NSString stringWithFormat:@"%lu",(unsigned long)redRange.location];
            currentLen = [NSString stringWithFormat:@"%lu",(unsigned long)redRange.length];
            
            if (i < colorArr.count) {
                UIColor *color = colorArr[i];
                [mutAttrStr addAttribute:NSForegroundColorAttributeName value:color range:redRange];
            } else if (colorArr.count > 0) {
                UIColor *color = colorArr[0];
                [mutAttrStr addAttribute:NSForegroundColorAttributeName value:color range:redRange];
            } else {
                [mutAttrStr addAttribute:NSForegroundColorAttributeName value:allColor range:redRange];
            }
            
            if (i < fontArr.count) {
                UIFont *font = fontArr[i];
                [mutAttrStr addAttribute:NSFontAttributeName value:font range:redRange];
            } else if (fontArr.count > 0) {
                UIFont *font = fontArr[0];
                [mutAttrStr addAttribute:NSFontAttributeName value:font range:redRange];
            } else {
                [mutAttrStr addAttribute:NSFontAttributeName value:allFont range:redRange];
            }
            
            if (i < underLineStyleArr.count) {
                NSNumber *underLineNum = underLineStyleArr[i];
                [mutAttrStr addAttribute:NSUnderlineStyleAttributeName value:underLineNum range:redRange];
            } else if (fontArr.count > 0) {
                NSNumber *underLineNum = underLineStyleArr[0];
                [mutAttrStr addAttribute:NSUnderlineStyleAttributeName value:underLineNum range:redRange];
            } else {
                [mutAttrStr addAttribute:NSUnderlineStyleAttributeName value:@(NSUnderlineStyleNone) range:redRange];
            }
            
            if (i < linkArr.count) {
                NSString *linkStr = [self getShowStringWithItem:linkArr[i]];
                [mutAttrStr addAttribute:NSLinkAttributeName value:[NSURL URLWithString:linkStr] range:redRange];
            } else if (linkArr.count > 0) {
                NSString *linkStr = [self getShowStringWithItem:linkArr[0]];
                [mutAttrStr addAttribute:NSLinkAttributeName value:[NSURL URLWithString:linkStr] range:redRange];
            } else {
                [mutAttrStr addAttribute:NSLinkAttributeName value:[NSURL URLWithString:@""] range:redRange];
            }
        }
    }
    NSMutableParagraphStyle * paragraphStyle1 = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle1 setLineSpacing:lineSpace];
    [paragraphStyle1 setAlignment:textAlignment];
    [paragraphStyle1 setLineBreakMode:lineBreakMode];
    [mutAttrStr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle1 range:NSMakeRange(0, [str length])];
    
    
    if (!_textView) {
        _textView = [[UITextView alloc] initWithFrame:CGRectZero];
        _textView.backgroundColor = [UIColor clearColor];
        _textView.linkTextAttributes = @{};
        _textView.editable = NO;
        _textView.delegate = self;
        
        _textView.textContainerInset = UIEdgeInsetsZero;
        //设置文本内容的左右间距为0
        _textView.textContainer.lineFragmentPadding = 0;
        _textView.contentInset = UIEdgeInsetsZero;
        
        //禁止长按和双击选中
        UILongPressGestureRecognizer *ges = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressToDo)];
        [_textView addGestureRecognizer:ges];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToDo)];
        tap.numberOfTapsRequired = 2;
        [_textView addGestureRecognizer:tap];
    }
    _textView.attributedText = mutAttrStr;
    _mutAttrStr = mutAttrStr;
    return _textView;
}

- (void)longPressToDo
{
    
}
- (void)tapToDo
{
    
}

- (CGSize)getContentSizeWithWantSize:(CGSize)wantSize
{
    /*
     1.使用boundingRectWithSize:计算高度时传入的属性要和Label保持一致
     2.计算得出的高度类型为CGFloat类型在使用时可能存在四舍五入等情况的误差，请使用ceil()函数取整
     3.如果文本中包含\n\r等字符时会被当做普通字符计算，而到了UITextView等空间中会被换行等操作要注意处理
     4.当使用该方法计算富文本高度时，若富文本包含中文且设置了行高，当文字只有一行时获得的高度是已加上行高的。若只有英文不会出现该情况。
     5.当使用该方法计算富文本高度时，若段落设置中lineBreakMode设置成 NSLineBreakByTruncatingTail | NSLineBreakByTruncatingHead | NSLineBreakByTruncatingMiddle在计算高度的时候会被系统默认成单行。所以若需要文本是其中截断是情况，计算时使用另外的截断模式计算。
     6.如果富文本设置了截断模式，大概率控件已经设置了固定的size，所以基本上也不会使用该方法再来计算size了
     */
    CGSize size = [_mutAttrStr boundingRectWithSize:wantSize options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil].size;
    return size;
}

#pragma mark - UITextViewDelegate
- (BOOL)textView:(UITextView*)textView shouldInteractWithURL:(NSURL*)URL inRange:(NSRange)characterRange interaction:(UITextItemInteraction)interaction {
 
    NSString *urlStr = URL ? URL.absoluteString : @"";
    if (urlStr.length > 0) {
        if (_clickLinkBlock) {
            _clickLinkBlock(urlStr);
        }
        return NO;
    }
 
    return YES;
 
}
@end
