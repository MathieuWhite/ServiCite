//
//  SearchButton.h
//  ServiCite
//
//  Created by Mathieu White on 2014-10-27.
//  Copyright (c) 2014 Mathieu White. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString * kUserWantsToOpenSearchNotification = @"kUserWantsToOpenSearchNotification";
static NSString * kUserWantsToCloseSearchNotification = @"kUserWantsToCloseSearchNotification";
static NSString * kUserStartedEditingSearchFieldNotification = @"kUserStartedEditingSearchFieldNotification";

@interface SearchButton : UIButton

+ (instancetype) button;

@end
