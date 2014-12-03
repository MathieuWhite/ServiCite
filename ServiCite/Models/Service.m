//
//  Service.m
//  ServiCite
//
//  Created by Mathieu White on 2014-10-31.
//  Copyright (c) 2014 Mathieu White. All rights reserved.
//

#import "Service.h"

@implementation Service

#pragma mark - Initialization

- (instancetype) initWithDictionary: (NSDictionary *) serviceInformation
{
    self = [super init];
    
    if (self)
    {
        _name = [serviceInformation objectForKey: @"name"];
        _room = [serviceInformation objectForKey: @"room"];
        _phone = [serviceInformation objectForKey: @"phone"];
        _extension = [serviceInformation objectForKey: @"extension"];
        _URL = [NSURL URLWithString: [serviceInformation objectForKey: @"url"]];
        _points = [serviceInformation objectForKey: @"points"];
        _centerPoint = [[serviceInformation objectForKey: @"center"] MKCoordinateValue];
        
        [self initService];
    }
    
    return  self;
}

- (void) initService
{
    
}

@end
