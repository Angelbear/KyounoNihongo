//
//  FlipsideViewController.m
//  KyounoNihongo
//
//  Created by bear on 11-12-10.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FlipsideViewController.h"
#import "JSONKit.h"
#import <QuartzCore/QuartzCore.h>
@implementation FlipsideViewController

@synthesize delegate;


- (void)viewDidLoad {
    [super viewDidLoad];
    _navBar.topItem.title = NSLocalizedString(@"Kaisetsu",@"");
    _image.layer.cornerRadius = 12;
    _kaisetsu.layer.cornerRadius = 12;
    for (UIView* subview in _kaisetsu.subviews)
        subview.layer.cornerRadius = 12;
    _kaisetsu.clipsToBounds = YES;
    _kaisetsu.backgroundColor = [UIColor blackColor];
    _kaisetsu.scalesPageToFit = NO;
    self.view.backgroundColor = [UIColor viewFlipsideBackgroundColor];      
}


- (IBAction)done:(id)sender {
	[self.delegate flipsideViewControllerDidFinish:self];	
}

- (NSString *)encodeToPercentEscapeString: (NSString *) input  
{  
    // Encode all the reserved characters, per RFC 3986  
    // (<http://www.ietf.org/rfc/rfc3986.txt>)  
    NSString *outputStr = (NSString *)   
    CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,  
                                            (CFStringRef)input,  
                                            NULL,  
                                            (CFStringRef)@"!*'();:@&=+$,/?%#[]",  
                                            kCFStringEncodingUTF8);  
    return outputStr;  
}  

- (void) updateUI {
#define CSS @"<link rel=\"stylesheet\" href=\"frame.css\" type=\"text/css\">"
    NSString* finalContent=[NSString stringWithFormat:@"%@%@",CSS,[[[_tableData valueForKey:@"explain"] stringByReplacingOccurrencesOfString:@"+" withString:@" "] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [_kaisetsu loadHTMLString:finalContent baseURL:[NSURL fileURLWithPath: [[NSBundle mainBundle]  bundlePath]]];
    [_image  loadImageFromURL:[NSURL URLWithString:[[_tableData valueForKey:@"image"] retain]]];
}

- (void)loadResultUrl:(NSString*) url {
    if([[NSUserDefaults standardUserDefaults] dictionaryForKey:@"kaisetsu"] != nil) {
        NSTimeInterval timeInteval = [[NSUserDefaults standardUserDefaults] doubleForKey:@"timestamp"];
        NSTimeInterval inteval = [[NSDate date] timeIntervalSince1970];
        NSLog(@"%f, %f, %d", timeInteval, inteval, ((int)inteval) % (60 * 60 * 24)) ;
        // Get the inteval of 00:00 today.
        inteval -=  (((int)inteval) % (60 * 60 * 24));
        NSLog(@"%f, %f", timeInteval, inteval);
        if (timeInteval > inteval) {
            id kaisetsu = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"kaisetsu"];
            if([kaisetsu valueForKey:url] != nil) {
                _tableData = [kaisetsu valueForKey:url];
                [self updateUI];
                return;
            }
        }
    }

    
    NSString* finalUrl  = [NSString stringWithFormat:@"http://kyounonihonngo.sinaapp.com/result.php?url=%@",[self encodeToPercentEscapeString:url]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];         
	[request setURL:[NSURL URLWithString:finalUrl]];
	[request setHTTPMethod:@"GET"];
	NSData *returnData = [NSURLConnection sendSynchronousRequest:request 
											   returningResponse:nil error:nil]; 
	NSString* str = [[[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	_tableData = [[str objectFromJSONStringWithParseOptions:JKParseOptionValidFlags] retain];
    NSMutableDictionary* kaisetsu = [NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults] dictionaryForKey:@"kaisetsu"]];
    if(kaisetsu != nil) {
        [kaisetsu setValue:_tableData forKey:url];
        [[NSUserDefaults standardUserDefaults] setValue:kaisetsu forKey:@"kaisetsu"];
    }
    
    [self performSelectorOnMainThread:@selector(updateUI) withObject:nil waitUntilDone:NO];
	[request release];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}


- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/


- (void)dealloc {
    [super dealloc];
}


@end
