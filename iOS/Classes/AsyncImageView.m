//
//  AsyncImageView.m
//  Kukeka
//
//  Created by mac on 9/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AsyncImageView.h"
#import <Foundation/Foundation.h>

@implementation AsyncImageView

- (void)loadImageFromURL:(NSURL*)url {
    _url = url;
    if (connection!=nil) { [connection release]; }
    if (data!=nil) { [data release]; }
    if([[NSUserDefaults standardUserDefaults] valueForKey:[_url absoluteString]] != nil) {
        UIImageView* imageView = [[[UIImageView alloc] initWithImage:[UIImage imageWithData:[[NSUserDefaults standardUserDefaults] valueForKey:[_url absoluteString]]]] autorelease];
        
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.autoresizingMask = ( UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight );
        
        [self addSubview:imageView];
        imageView.frame = self.bounds;
        [imageView setNeedsLayout];
        [self setNeedsLayout];

    }else {
        NSURLRequest* request = [NSURLRequest requestWithURL:url
                                                 cachePolicy:NSURLRequestUseProtocolCachePolicy
                                             timeoutInterval:60.0];
        connection = [[NSURLConnection alloc]
                      initWithRequest:request delegate:self];
        //TODO error handling, what if connection is nil?
    }
}

- (void)connection:(NSURLConnection *)theConnection
    didReceiveData:(NSData *)incrementalData {
    if (data==nil) {
        data =
        [[NSMutableData alloc] initWithCapacity:2048];
    }
    [data appendData:incrementalData];
}

- (void)connectionDidFinishLoading:(NSURLConnection*)theConnection {
    
    [connection release];
    connection=nil;
    
    if ([[self subviews] count]>0) {
        [[[self subviews] objectAtIndex:0] removeFromSuperview];
    }
    
    if([[NSUserDefaults standardUserDefaults] valueForKey:[_url absoluteString]] == nil) {
        [[NSUserDefaults standardUserDefaults] setValue:data forKey:[_url absoluteString]];
    }
    
    UIImageView* imageView = [[[UIImageView alloc] initWithImage:[UIImage imageWithData:data]] autorelease];
    
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.autoresizingMask = ( UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight );
    
    [self addSubview:imageView];
    imageView.frame = self.bounds;
    [imageView setNeedsLayout];
    [self setNeedsLayout];
    [data release];
    data=nil;
}

- (UIImage*) image {
    UIImageView* iv = [[self subviews] objectAtIndex:0];
    return [iv image];
}

- (void)dealloc {
    [connection cancel];
    [connection release];
    [data release];
    [super dealloc];
}

@end