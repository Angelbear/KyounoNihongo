//
//  LoadViewController.h
//  Kukeka
//
//  Created by bear on 11-9-23.
//  Copyright 2011年 tsinghua. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface LoadViewController : UIViewController<MBProgressHUDDelegate> {
    MBProgressHUD *HUD;
}
@property (nonatomic, retain) MBProgressHUD* HUD;
-(void) startProcess:(SEL)selector target:(id)target withObject:(id)object name:(NSString*)name;
@end
