//
//  Building.h
//  ServiCite
//
//  Created by Mathieu White on 2014-10-31.
//  Copyright (c) 2014 Mathieu White. All rights reserved.
//

@import MapKit;

#import <Foundation/Foundation.h>

@interface Building : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSMutableArray *points;
@property (nonatomic, assign) CLLocationCoordinate2D centerPoint;

- (instancetype) initWithName: (NSString *) name points: (NSMutableArray *) points;

@end
