//
//  Service.h
//  ServiCite
//
//  Created by Mathieu White on 2014-10-31.
//  Copyright (c) 2014 Mathieu White. All rights reserved.
//

@import MapKit;

#import <Foundation/Foundation.h>

@interface Service : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *room;
@property (nonatomic, strong) NSString *phone;
@property (nonatomic, strong) NSString *extension;
@property (nonatomic, strong) NSURL *URL;
@property (nonatomic, strong) NSMutableArray *points;
@property (nonatomic, assign) CLLocationCoordinate2D centerPoint;

- (instancetype) initWithDictionary: (NSDictionary *) serviceInformation;

@end
