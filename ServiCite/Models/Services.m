//
//  Services.m
//  ServiCite
//
//  Created by Mathieu White on 2014-10-31.
//  Copyright (c) 2014 Mathieu White. All rights reserved.
//

@import MapKit;

#import "Services.h"

@interface Services ()

@property (nonatomic, strong) NSString *filename;

@end

@implementation Services

# pragma mark - Initialization

+ (Services *) sharedServices
{
    static Services *_sharedServices;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _sharedServices = [[self alloc] initWithFilename: @"Services"];
    });
    
    return _sharedServices;
}

- (instancetype) initWithFilename: (NSString *) filename
{
    self = [super init];
    
    if (self)
    {
        _filename = filename;
        
        [self initServices];
    }
    
    return  self;
}

- (void) initServices
{
    // Array to store the services at La Cité
    NSMutableArray *allServices = [NSMutableArray array];
    
    // Reading the plist
    NSString *filePath = [[NSBundle mainBundle] pathForResource: [self filename] ofType: @"plist"];
    NSArray *services = [NSArray arrayWithContentsOfFile: filePath];
    
    // Loop through each service
    for (NSUInteger index = 0; index < [services count]; index++)
    {
        NSString *name = [[services objectAtIndex: index] objectForKey: @"name"];
        NSString *room = [[services objectAtIndex: index] objectForKey: @"room"];
        NSString *phone = [[services objectAtIndex: index] objectForKey: @"phone"];
        NSString *extension = [[services objectAtIndex: index] objectForKey: @"extension"];
        NSString *url = [[services objectAtIndex: index] objectForKey: @"url"];
        
        // Array to store the points of the building
        NSMutableArray *points = [NSMutableArray array];
        
        // Get the points of the building
        for (NSDictionary *pointDictionary in [[services objectAtIndex: index] objectForKey: @"points"])
        {
            CLLocationDegrees latitude = [[pointDictionary objectForKey: @"latitute"] doubleValue];
            CLLocationDegrees longitude = [[pointDictionary objectForKey: @"longitude"] doubleValue];
            CLLocationCoordinate2D point = CLLocationCoordinate2DMake(latitude, longitude);
            
            [points addObject: [NSValue valueWithMKCoordinate: point]];
        }
        
        // Get the center point of the building
        CLLocationCoordinate2D center;
        center.latitude = [[[[services objectAtIndex: index] objectForKey: @"center"] objectForKey: @"latitute"] doubleValue];
        center.longitude = [[[[services objectAtIndex: index] objectForKey: @"center"] objectForKey: @"longitude"] doubleValue];
        
        // Initialize a dictionary to hold the information about a service
        NSDictionary *serviceInformation = @{@"name" : name, @"room" : room,
                                             @"phone" : phone, @"extension" : extension, @"url" : url,
                                             @"points" : points, @"center" : [NSValue valueWithMKCoordinate: center]};
        
        // Create a new building
        Service *service = [[Service alloc] initWithDictionary: serviceInformation];
        
        [allServices addObject: service];
    }
    
    
    [self setAllServices: allServices];
}

@end
