//
//  DatePickerViewController.m
//  KyounoNihongo
//
//  Created by Yangyang Zhao on 1/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DatePickerViewController.h"

@implementation DatePickerViewController
@synthesize delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil delegate:(id)del date:(NSDate*)date
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.delegate = del;
        _initDate = [date retain];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


- (void)dismissDatePickerConfirm:(id)sender {
    [self.delegate doneSelectDate:_datePicker.date];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    _datePicker.tag = 10;
    _datePicker.date = _initDate;
    _datePicker.datePickerMode = UIDatePickerModeDate;
    _datePicker.minimumDate = [NSDate dateWithTimeIntervalSince1970:1325635200.00];
    _datePicker.maximumDate = [NSDate date];

    UIBarButtonItem *callModalViewButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissDatePickerConfirm:)];
    self.navigationItem.rightBarButtonItem = callModalViewButton;
    self.view.bounds = CGRectMake(0,0,320,260);
    // Do any additional setup after loading the view from its nib.
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
	return YES;
}

@end
