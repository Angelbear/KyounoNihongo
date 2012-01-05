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


- (IBAction)showInfo:(id)sender {    
	
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

-(void) updateUI {
    [_tableView reloadData];
#define CSS @"<link rel=\"stylesheet\" href=\"frame.css\" type=\"text/css\">"
    NSString* finalContent=[NSString stringWithFormat:@"%@%@",CSS,[[[_tableData valueForKey:@"question"]  stringByReplacingOccurrencesOfString:@"+" withString:@" "] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [_webView loadHTMLString:finalContent baseURL:[NSURL fileURLWithPath: [[NSBundle mainBundle]  bundlePath]]];
}

BOOL _loading = YES;

- (void) loadUrl {
    _loading = YES;
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];         
	[request setURL:[NSURL URLWithString:@"http://kyounonihonngo.sinaapp.com/"]];
	[request setHTTPMethod:@"GET"];
	NSData *returnData = [NSURLConnection sendSynchronousRequest:request 
											   returningResponse:nil error:nil]; 
	NSString* str = [[[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	_tableData = [[str objectFromJSONStringWithParseOptions:JKParseOptionValidFlags] retain];
    [[NSUserDefaults standardUserDefaults] setValue:_tableData forKey:@"mondai"];
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]] forKey:@"timestamp"];
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
    
    if([[NSUserDefaults standardUserDefaults] dictionaryForKey:@"mondai"] != nil) {
        NSTimeInterval timeInteval = [[NSUserDefaults standardUserDefaults] doubleForKey:@"timestamp"];
        NSTimeInterval inteval = [[NSDate date] timeIntervalSince1970];
        NSLog(@"%f, %f, %d", timeInteval, inteval, ((int)inteval) % (60 * 60 * 24)) ;
        // Get the inteval of 00:00 today.
        inteval -=  (((int)inteval) % (60 * 60 * 24));
        NSLog(@"%f, %f", timeInteval, inteval);
        if (timeInteval > inteval) {
            _loading = NO;
            _tableData = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"mondai"];
            [self updateUI];
            return;
        }
    }
    [self startProcess:@selector(loadUrl) target:self withObject:nil name:NSLocalizedString(@"Loading...",@"")];
    
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
