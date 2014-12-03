//
//  ActionBar.h
//  ServiCite
//
//  Created by Mathieu White on 2014-10-28.
//  Copyright (c) 2014 Mathieu White. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString * kUserWantsLocationTrackingNotification = @"kUserWantsLocationTrackingNotification";
static NSString * kUserWantsFrontViewNotification = @"kUserWantsFrontViewNotification";
static NSString * kUserWantsViewBehindNotification = @"kUserWantsViewBehindNotification";
static NSString * kUserTappedFrontViewNotification = @"kUserTappedFrontViewNotification";
static NSString * kUserLocationTrackingStateChanged = @"kUserLocationTrackingStateChanged";

@interface ActionBar : UIView

+ (ActionBar *) sharedActionBar;

@end
