//
//  ServiceInfoViewController.h
//  ServiCite
//
//  Created by Mathieu White on 2014-11-04.
//  Copyright (c) 2014 Mathieu White. All rights reserved.
//

@class Service;

@import MapKit;

#import <UIKit/UIKit.h>

@interface ServiceInfoViewController : UIViewController <MKMapViewDelegate>

- (instancetype) initWithService: (Service *) service;

@end
