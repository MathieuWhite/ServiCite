//
//  SearchTableView.h
//  ServiCite
//
//  Created by Mathieu White on 2014-10-31.
//  Copyright (c) 2014 Mathieu White. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Services.h"

static NSString * kUserSelectedServiceFromSearchTableNotification = @"kUserSelectedServiceFromSearchTableNotification";

@interface SearchTableView : UITableView <UITableViewDataSource, UITableViewDelegate>

@end
