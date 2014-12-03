//
//  FrontViewController.h
//  ServiCite
//
//  Created by Mathieu White on 2014-10-28.
//  Copyright (c) 2014 Mathieu White. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BehindViewController.h"
#import "ActionBar.h"

static NSString * kShowPointsOfInterestNotification = @"kShowPointsOfInterestNotification";
static NSString * kChangeMapTypeNotification = @"kChangeMapTypeNotification";
static NSString * kMapViewMainCampusRegionNotification = @"kMapViewMainCampusRegionNotification";

@protocol FrontViewControllerDelegate <NSObject>

- (void) moveFrontViewToBottom;
- (void) moveFrontViewToOriginalPosition;

@end

@interface FrontViewController : UIViewController <UIAlertViewDelegate, UIViewControllerTransitioningDelegate>

@property (nonatomic, assign) id <FrontViewControllerDelegate> delegate;

@end
