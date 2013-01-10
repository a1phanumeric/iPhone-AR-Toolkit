//
//  ViewController.h
//  iPhone-AR-Demo
//
//  Created by Ed Rackham on 03/01/2013.
//  Copyright (c) 2013 edrackham.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ARKit.h"

@interface ViewController : UIViewController <ARLocationDelegate>

- (IBAction)startAR:(id)sender;
- (IBAction)startARWithoutCloseButton:(id)sender;
@end
