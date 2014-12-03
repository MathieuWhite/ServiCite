//
//  BuildingAnnotation.m
//  ServiCite
//
//  Created by Mathieu White on 2014-10-31.
//  Copyright (c) 2014 Mathieu White. All rights reserved.
//

#import "BuildingAnnotation.h"

@implementation BuildingAnnotation

#pragma mark - Initialization

- (id) initWithTitle: (NSString *) title coordinate: (CLLocationCoordinate2D) coordinate
{
    self = [super init];
    
    if (self)
    {
        _title = title;
        _coordinate = coordinate;
    }
    
    return self;
}

@end
