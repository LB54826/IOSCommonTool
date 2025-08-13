//
//  RichTextViewController.m
//  CustomTool
//
//  Created by Liubo on 2025/8/13.
//

#import "RichTextViewController.h"
#import "NSObject+Category.h"
#import "TextViewForSuperLinkTool.h"

@interface RichTextViewController ()
{
    TextViewForSuperLinkTool *_superLikTool;
}
@property (weak, nonatomic) IBOutlet UILabel *richTextLabel;

@end

@implementation RichTextViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    
    [self showRichText];
    
    _superLikTool = [[TextViewForSuperLinkTool alloc] init];
    [self showSuperLink];
    
}

- (void)showRichText
{
    NSString *otherStyleStr = @"哦啊哈是的哦很尬法搜等哈发哦is大佛艾萨";
    NSString *otherSecondStyleStr = @"打发斯蒂芬骄傲我饿激发";
    
    NSString *totalStr = [NSString stringWithFormat:@"哈哈哈哈哈哈哈 %@,%@",otherStyleStr,otherSecondStyleStr];
    
    NSMutableAttributedString *richText = [self getAttributedStringWithDiffrentColorArr:@[[UIColor redColor],[UIColor blueColor]] diffrentFountArr:@[[UIFont systemFontOfSize:12],[UIFont systemFontOfSize:15]] diffrentTextArr:@[otherStyleStr,otherSecondStyleStr] underLineStyleArr:@[@(NSUnderlineStyleNone),@(NSUnderlineStyleSingle)] withAllLabelText:totalStr allLabelTextColor:[UIColor greenColor] allLabelTextFont:[UIFont systemFontOfSize:18] lineSpace:10 textAlignment:NSTextAlignmentLeft lineBreakMode:NSLineBreakByWordWrapping];
    self.richTextLabel.attributedText = richText;
}

- (void)showSuperLink
{
    NSString *otherStyleStr = @"哦啊哈是的哦很尬法搜等哈发哦is大佛艾萨";
    NSString *otherSecondStyleStr = @"打发斯蒂芬骄傲我饿激发";
    
    NSString *totalStr = [NSString stringWithFormat:@"哈哈哈哈哈哈哈 %@,%@",otherStyleStr,otherSecondStyleStr];
    
    NSMutableAttributedString *richText = [self getAttributedStringWithDiffrentColorArr:@[[UIColor redColor],[UIColor blueColor]] diffrentFountArr:@[[UIFont systemFontOfSize:12],[UIFont systemFontOfSize:15]] diffrentTextArr:@[otherStyleStr,otherSecondStyleStr] underLineStyleArr:@[@(NSUnderlineStyleNone),@(NSUnderlineStyleSingle)] withAllLabelText:totalStr allLabelTextColor:[UIColor greenColor] allLabelTextFont:[UIFont systemFontOfSize:18] lineSpace:10 textAlignment:NSTextAlignmentLeft lineBreakMode:NSLineBreakByWordWrapping];
    self.richTextLabel.attributedText = richText;
    
    
    UITextView *superLink = [_superLikTool showTextViewWithDiffrentColorArr:@[[UIColor redColor],[UIColor blueColor]] diffrentFountArr:@[[UIFont systemFontOfSize:12],[UIFont systemFontOfSize:15]] diffrentTextArr:@[otherStyleStr,otherSecondStyleStr] underLineStyleArr:@[@(NSUnderlineStyleNone),@(NSUnderlineStyleSingle)] linkArr:@[@"1",@"2"] withAllLabelText:totalStr allLabelTextColor:[UIColor greenColor] allLabelTextFont:[UIFont systemFontOfSize:18] lineSpace:15 textAlignment:NSTextAlignmentLeft lineBreakMode:NSLineBreakByWordWrapping clickLinkBlock:^(NSString * _Nonnull clickUrl) {
        NSString *clickStr = @"";
        if ([clickUrl isEqualToString:@"1"]) {
            clickStr = @"点击了第一个链接";
        } else if ([clickUrl isEqualToString:@"2"]) {
            clickStr = @"点击了第二个链接";
        }
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:clickStr preferredStyle:UIAlertControllerStyleAlert];
        __weak typeof(self) wself = self;
        UIAlertAction *actionDone = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            __strong typeof(wself) sself = wself;
            
        }];
        UIAlertAction *actionCancle = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alert addAction:actionDone];
        [alert addAction:actionCancle];
        
        [self presentViewController:alert animated:YES completion:^{
            
        }];
    }];
    superLink.frame = CGRectMake(30, 370, [UIScreen mainScreen].bounds.size.width - 60, [UIScreen mainScreen].bounds.size.height);
    [self.view addSubview:superLink];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
