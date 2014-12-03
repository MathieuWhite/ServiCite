//
//  MenuTableView.h
//  ServiCite
//
//  Created by Mathieu White on 2014-10-31.
//  Copyright (c) 2014 Mathieu White. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString * kUserWantsPointsOfInterestNotification = @"kUserWantsPointsOfInterestNotification";
static NSString * kUserWantsMainCampusNotification = @"kUserWantsMainCampusNotification";
static NSString * kUserWantsMapTypeChangeNotification = @"kUserWantsMapTypeChangeNotification";
static NSString * kMapTypeChangedNotification = @"kMapTypeChangedNotification";

@interface MenuTableView : UITableView <UITableViewDataSource, UITableViewDelegate>

@end
