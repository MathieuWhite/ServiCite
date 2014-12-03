//
//  Building.m
//  ServiCite
//
//  Created by Mathieu White on 2014-10-31.
//  Copyright (c) 2014 Mathieu White. All rights reserved.
//

#import "Building.h"

@implementation Building

#pragma mark - Initialization

- (instancetype) initWithName: (NSString *) name points: (NSMutableArray *) points
{
    self = [super init];
    
    if (self)
    {
        _name = name;
        _points = points;
        
        [self initBuilding];
    }
    
    return  self;
}

- (void) initBuilding
{
    
}

@end
