//
//  MainViewController.h
//  KyounoNihongo
//
//  Created by bear on 11-12-10.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FlipsideViewController.h"
#import "LoadViewController.h"

@interface MainViewController : LoadViewController <FlipsideViewControllerDelegate,UITableViewDataSource,UITableViewDelegate> {
    IBOutlet UIWebView* _webView;
    IBOutlet UITableView* _tableView;
    IBOutlet UINavigationBar* _navBar;
    int selectedRow;
    id _tableData;
}
- (IBAction)showInfo:(id)sender;

@end
