//
//  LoadViewController.m
//  Kukeka
//
//  Created by bear on 11-9-23.
//  Copyright 2011年 tsinghua. All rights reserved.
//

#import "LoadViewController.h"


@implementation LoadViewController
@synthesize HUD;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [self.HUD release];
    self.HUD = nil;
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/




// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}

-(void) startProcess:(SEL)selector target:(id)target withObject:(id)object name:(NSString*)name {
    self.HUD = [[MBProgressHUD alloc] initWithView:self.view];
    self.HUD.delegate = self;
    [self.view addSubview:HUD];
    [self.view bringSubviewToFront:self.HUD];
    self.HUD.labelText = name;
    self.HUD.removeFromSuperViewOnHide = YES;
    [self.HUD showWhileExecuting:selector onTarget:target withObject:object animated:YES];
}

- (void)hudWasHidden:(MBProgressHUD *)hud {
   [self.HUD release];
    self.HUD = nil;
}
- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
