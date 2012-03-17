//
//  DatePickerViewController.h
//  KyounoNihongo
//
//  Created by Yangyang Zhao on 1/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DatePickerViewControllerDelegate <NSObject>
-(void) doneSelectDate:(NSDate*)date;
@end

@interface DatePickerViewController : UIViewController {
    IBOutlet UIDatePicker* _datePicker;
    NSDate* _initDate;
    id<DatePickerViewControllerDelegate> delegate;
}
@property(nonatomic, assign) id<DatePickerViewControllerDelegate> delegate;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil delegate:(id)del date:(NSDate*)date;
@end
