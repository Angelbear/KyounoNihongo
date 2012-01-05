//
//  AsyncImageView.h
//  Kukeka
//
//  Created by mac on 9/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AsyncImageView : UIView {
    NSURLConnection* connection;
    NSMutableData* data;
    NSURL* _url;
}
- (void)loadImageFromURL:(NSURL*)url;
@end
