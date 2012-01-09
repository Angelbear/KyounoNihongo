//
//  MainViewController.h
//  KyounoNihongo
//
//  Created by bear on 11-12-10.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FlipsideViewController.h"
#import "LoadViewController.h"
#import "DatePickerViewController.h"

@interface MainViewController : LoadViewController <FlipsideViewControllerDelegate,UITableViewDataSource,UITableViewDelegate,DatePickerViewControllerDelegate> {
    IBOutlet UIWebView* _webView;
    IBOutlet UITableView* _tableView;
    IBOutlet UINavigationBar* _navBar;
    IBOutlet UINavigationItem* _bookMark;
    int selectedRow;
    id _tableData;
    NSDate* currentDate;
    NSDate* tmpDate;
}
@property(nonatomic, retain) NSDate* currentDate;
- (IBAction)callDP:(id)sender;
-(void) showMondai:(NSDate*) date;
@end
