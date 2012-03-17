//
//  MainViewController.m
//  KyounoNihongo
//
//  Created by bear on 11-12-10.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MainViewController.h"
#import "JSONKit.h"
#import <QuartzCore/QuartzCore.h>

@implementation MainViewController
@synthesize currentDate;


/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	[super viewDidLoad];
}
*/


- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller {
    
	[self dismissModalViewControllerAnimated:YES];
}

-(bool)checkDevice:(NSString*)name  
{  
    NSString* deviceType = [UIDevice currentDevice].model;  
    
    NSRange range = [deviceType rangeOfString:name];  
    return range.location != NSNotFound;  
}  


- (void)showInfo:(id)sender {    
	
    NSString *  nsStrIphone=@"iPhone";  
    NSString *  nsStrIpod=@"iPod";  
    NSString *  nsStrIpad=@"iPad";  
    bool  bIsiPhone=false;  
    bool  bIsiPod=false;  
    bool  bIsiPad=false;  
    bIsiPhone=[self  checkDevice:nsStrIphone];  
    bIsiPod=[self checkDevice:nsStrIpod];  
    bIsiPad=[self checkDevice:nsStrIpad]; 
    
    FlipsideViewController *controller = nil;
    if(bIsiPhone || bIsiPod) {
        controller = [[FlipsideViewController alloc] initWithNibName:@"FlipsideView" bundle:nil];
    }else {
        controller = [[FlipsideViewController alloc] initWithNibName:@"FlipsideView-iPad" bundle:nil];
    }
	controller.delegate = self;
	
	controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
	[self presentModalViewController:controller animated:YES];
    NSString* choiceUrl = [[[_tableData valueForKey:@"choice"] objectAtIndex:selectedRow] valueForKey:@"link"];
    [controller startProcess:@selector(loadResultUrl:) target:controller withObject:choiceUrl name:NSLocalizedString(@"Loading...",@"")];
	[controller release];
}

- (void)changeDate:(UIDatePicker *)sender {
    tmpDate = sender.date;
}

- (void)removeViews:(id)object {
    [[self.view viewWithTag:9] removeFromSuperview];
    [[self.view viewWithTag:10] removeFromSuperview];
    [[self.view viewWithTag:11] removeFromSuperview];
}

- (void)dismissDatePicker:(id)sender {
    CGRect toolbarTargetFrame = CGRectMake(0, self.view.bounds.size.height, 320, 44);
    CGRect datePickerTargetFrame = CGRectMake(0, self.view.bounds.size.height+44, 320, 216);
    [UIView beginAnimations:@"MoveOut" context:nil];
    [self.view viewWithTag:9].alpha = 0;
    [self.view viewWithTag:10].frame = datePickerTargetFrame;
    [self.view viewWithTag:11].frame = toolbarTargetFrame;
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(removeViews:)];
    [UIView commitAnimations];
}

- (void)dismissDatePickerCancel:(id)sender {
    [self dismissDatePicker:sender];
}

- (void)dismissDatePickerConfirm:(id)sender {
    [self dismissDatePicker:sender];
    self.currentDate = tmpDate != nil ? tmpDate : [NSDate date];
    [self showMondai:self.currentDate];
}

UIPopoverController* _pop; 
-(void) doneSelectDate:(NSDate*)date {
    [self showMondai:date];
    [_pop dismissPopoverAnimated:YES];
}



- (IBAction)calliPadDP:(id)sender {
    DatePickerViewController* controller = [[DatePickerViewController alloc] initWithNibName:@"DatePickerViewController" bundle:nil delegate:self date:currentDate];
    UINavigationController* nav = [[UINavigationController alloc] initWithRootViewController:controller];
    
    UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:nav];
	popover.popoverContentSize = CGSizeMake(320, 250); //弹出窗口大小，如果屏幕画不下，会挤小的。这个值默认是320x1100
    
	CGRect popoverRect = CGRectMake(740, 20, 5, 5);
	[popover presentPopoverFromRect:popoverRect  //popoverRect的中心点是用来画箭头的，如果中心点如果出了屏幕，系统会优化到窗口边缘
							 inView:self.view //上面的矩形坐标是以这个view为参考的
		   permittedArrowDirections:UIPopoverArrowDirectionUp  //箭头方向
						   animated:YES];
    _pop = popover;
}

- (IBAction)callDP:(id)sender {
    if ([self.view viewWithTag:9]) {
        return;
    }
    CGRect toolbarTargetFrame = CGRectMake(0, self.view.bounds.size.height-216-44, 320, 44);
    CGRect datePickerTargetFrame = CGRectMake(0, self.view.bounds.size.height-216, 320, 216);
    
    UIView *darkView = [[[UIView alloc] initWithFrame:self.view.bounds] autorelease];
    darkView.alpha = 0;
    darkView.backgroundColor = [UIColor blackColor];
    darkView.tag = 9;
    UITapGestureRecognizer *tapGesture = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissDatePickerCancel:)] autorelease];
    [darkView addGestureRecognizer:tapGesture];
    [self.view addSubview:darkView];
    
    UIDatePicker *datePicker = [[[UIDatePicker alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height+44, 320, 216)] autorelease];
    datePicker.tag = 10;
    datePicker.datePickerMode = UIDatePickerModeDate;
    datePicker.date = self.currentDate;
    datePicker.minimumDate = [NSDate dateWithTimeIntervalSince1970:1325635200.00];
    datePicker.maximumDate = [NSDate date];
    [datePicker addTarget:self action:@selector(changeDate:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:datePicker];
    
    UIToolbar *toolBar = [[[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height, 320, 44)] autorelease];
    toolBar.tag = 11;
    toolBar.barStyle = UIBarStyleBlackTranslucent;
    UIBarButtonItem *spacer = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease];
    UIBarButtonItem *doneButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissDatePickerConfirm:)] autorelease];
    [toolBar setItems:[NSArray arrayWithObjects:spacer, doneButton, nil]];
    [self.view addSubview:toolBar];
    
    [UIView beginAnimations:@"MoveIn" context:nil];
    toolBar.frame = toolbarTargetFrame;
    datePicker.frame = datePickerTargetFrame;
    darkView.alpha = 0.5;
    [UIView commitAnimations];
}


-(void) updateUI {
    [_tableView reloadData];
#define CSS @"<link rel=\"stylesheet\" href=\"frame.css\" type=\"text/css\">"
    NSString* finalContent=[NSString stringWithFormat:@"%@%@",CSS,[[[_tableData valueForKey:@"question"]  stringByReplacingOccurrencesOfString:@"+" withString:@" "] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [_webView loadHTMLString:finalContent baseURL:[NSURL fileURLWithPath: [[NSBundle mainBundle]  bundlePath]]];
}

BOOL _loading = YES;

- (void) loadUrl:(NSDate*)date {
    _loading = YES;
    NSDateFormatter *df = [NSDateFormatter new];
    [df setDateFormat:@"yyyy-MM-dd"];
    NSLog(@"%@",[df stringFromDate:date]);
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];         
	[request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://kyounonihonngo.sinaapp.com/?date=%@",[df stringFromDate:date]]]];
	[request setHTTPMethod:@"GET"];
	NSData *returnData = [NSURLConnection sendSynchronousRequest:request 
											   returningResponse:nil error:nil]; 
	NSString* str = [[[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	_tableData = [[str objectFromJSONStringWithParseOptions:JKParseOptionValidFlags] retain];
    NSMutableDictionary* mondai = [NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults] dictionaryForKey:@"mondai"]];
    if(mondai == nil) {
        mondai = [[NSMutableDictionary alloc] init];
    }
    [mondai setValue:_tableData forKey:[df stringFromDate:date]];
    [[NSUserDefaults standardUserDefaults] setValue:mondai forKey:@"mondai"];
    [df release];
    _loading = NO;
    [self performSelectorOnMainThread:@selector(updateUI) withObject:nil waitUntilDone:NO];
	[request release];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(section == 0) {
        return 3;
    }else if(section == 1) {
        return 1;
    }
    return 0;
}


#define SimpleTableIdentifier @"simpletableidentifier"

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:
                             SimpleTableIdentifier];
    if (cell == nil) {  
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                       reuseIdentifier: SimpleTableIdentifier] autorelease];
    }
    
    if(indexPath.section == 0) {
        if(selectedRow == indexPath.row && _loading == NO) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        
        if(_tableData != nil) {
            cell.textLabel.text = [[[_tableData valueForKey:@"choice"] objectAtIndex:indexPath.row] valueForKey:@"text"];
        }
    }else if(indexPath.section == 1) {
        cell.textLabel.textAlignment = UITextAlignmentCenter;
        cell.textLabel.text = NSLocalizedString(@"See answer", @"");
    }
    return cell;
        
}



- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if(section == 0) {
        return NSLocalizedString(@"Choice",@"");
    }
    return @"";
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if(section == 1) {
        return @"Copyright © 2012 ChaosYang. All Rights Reserved.";
    }
    return @"";
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 0) {
        selectedRow = indexPath.row;
        [tableView reloadData];
    }else {
        [[tableView cellForRowAtIndexPath:indexPath] setSelected:YES animated:YES];
        [self showInfo:nil];
        [[tableView cellForRowAtIndexPath:indexPath] setSelected:NO animated:YES];
    }
}

-(void) showMondai:(NSDate*) date {
    self.currentDate = date;
    if([[NSUserDefaults standardUserDefaults] dictionaryForKey:@"mondai"] != nil) {
        id mondai = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"mondai"];
        NSDateFormatter *df = [NSDateFormatter new];
        [df setDateFormat:@"yyyy-MM-dd"];
        if([mondai valueForKey:[df stringFromDate:date]] != nil) {
            _loading = NO;
            _tableData = [mondai valueForKey:[df stringFromDate:date]] ;
            [df release];
            [self updateUI];
            return;
        }
        [df release];
    }
    [self startProcess:@selector(loadUrl:) target:self withObject:date name:NSLocalizedString(@"Loading...",@"")];
}
-(void) viewDidLoad {
	[super viewDidLoad];
    _webView.layer.cornerRadius = 12;
    for (UIView* subview in _webView.subviews)
        subview.layer.cornerRadius = 12;
    _webView.clipsToBounds = YES;
    _webView.backgroundColor = [UIColor blackColor];
    _webView.scalesPageToFit = NO;
    
    UIView *newBackgroundView = [[[UIView alloc] init] autorelease];
    newBackgroundView.backgroundColor = [UIColor clearColor];
    _tableView.backgroundView = newBackgroundView;
    _tableView.allowsSelection = YES;
    _navBar.topItem.title = NSLocalizedString(@"KyounoNihongo",@"");
    
    self.currentDate = [NSDate date];
    [self showMondai:self.currentDate];
    
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc. that aren't in use.
}


- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations.
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/


- (void)dealloc {
    [super dealloc];
}


@end
