//
//  LBBannerItemView.m
//  TanTanKaPianDemo
//
//  Created by Liubo on 2025/1/17.
//  Copyright © 2025 All rights reserved.
//

#import "LBBannerItemView.h"
#import "ExecuteTool.h"
#import "Masonry.h"
@interface LBBannerItemView()
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;


@end

@implementation LBBannerItemView

- (void)showBannerItemWithString:(NSString *)objStr
{
    self.messageLabel.text = objStr;
    if ([objStr isEqualToString:@"1"]) {
        self.backgroundColor = [UIColor redColor];
        __weak typeof(self) wself = self;
        [ExecuteTool executeSomethingAfterDelay:0.5 afterDelay:^{
                    __strong typeof(wself) sself = wself;
                    CGRect frame = sself.frame;
                    frame.size.height = 70;
                    sself.frame = frame;
        }];
        
    } else if ([objStr isEqualToString:@"2"]) {
        self.backgroundColor = [UIColor greenColor];
        __weak typeof(self) wself = self;
        [ExecuteTool executeSomethingAfterDelay:3 afterDelay:^{
            __strong typeof(wself) sself = wself;
            CGRect frame = sself.frame;
            frame.size.height = 200;
            sself.frame = frame;
            
        }];
    } else if ([objStr isEqualToString:@"3"]) {
        self.backgroundColor = [UIColor orangeColor];
    }
}

@end
