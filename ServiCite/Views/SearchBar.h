//
//  SearchBar.h
//  ServiCite
//
//  Created by Mathieu White on 2014-10-29.
//  Copyright (c) 2014 Mathieu White. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString * kUserOpenedSearchNotification = @"kUserOpenedSearchNotification";
static NSString * kUserClosedSearchNotification = @"kUserClosedSearchNotification";
static NSString * kUserDraggedSearchTableNotification = @"kUserDraggedSearchTableNotification";
static NSString * kUserIsSearchingForServicesNotification = @"kUserIsSearchingForServicesNotification";

@interface SearchBar : UIView <UITextFieldDelegate>

+ (SearchBar *) sharedSearchBar;

@end
