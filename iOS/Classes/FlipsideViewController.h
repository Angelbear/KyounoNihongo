//
//  FlipsideViewController.h
//  KyounoNihongo
//
//  Created by bear on 11-12-10.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncImageView.h"
#import "LoadViewController.h"
@protocol FlipsideViewControllerDelegate;


@interface FlipsideViewController : LoadViewController {
    IBOutlet UINavigationBar* _navBar;
    IBOutlet AsyncImageView* _image;
    IBOutlet UIWebView* _kaisetsu;
	id <FlipsideViewControllerDelegate> delegate;
    id _tableData;
}

@property (nonatomic, assign) id <FlipsideViewControllerDelegate> delegate;
- (IBAction)done:(id)sender;
- (void)loadResultUrl:(NSString*) url;
@end


@protocol FlipsideViewControllerDelegate
- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller;
@end

