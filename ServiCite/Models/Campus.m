//
//  Campus.m
//  ServiCite
//
//  Created by Mathieu White on 2014-10-31.
//  Copyright (c) 2014 Mathieu White. All rights reserved.
//

@import MapKit;

#import "Campus.h"

@interface Campus ()

@property (nonatomic, strong) NSString *filename;

@end

@implementation Campus

# pragma mark - Initialization

+ (Campus *) sharedCampus
{
    static Campus *_sharedCampus;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _sharedCampus = [[self alloc] initWithFilename: @"Buildings"];
    });
    
    return _sharedCampus;
}

- (instancetype) initWithFilename: (NSString *) filename
{
    self = [super init];
    
    if (self)
    {
        _filename = filename;
        
        [self initCampus];
    }
    
    return  self;
}

- (void) initCampus
{
    // Array to store the buildings on campus
    NSMutableArray *campusBuildings = [NSMutableArray array];
    
    // Reading the plist
    NSString *filePath = [[NSBundle mainBundle] pathForResource: [self filename] ofType: @"plist"];
    NSArray *buildings = [NSArray arrayWithContentsOfFile: filePath];
    
    // Loop through each building
    for (NSUInteger index = 0; index < [buildings count]; index++)
    {
        NSString *name = [[buildings objectAtIndex: index] objectForKey: @"name"];
        
        // Array to store the points of the building
        NSMutableArray *points = [NSMutableArray array];
        
        // Get the points of the building
        for (NSDictionary *pointDictionary in [[buildings objectAtIndex: index] objectForKey: @"points"])
        {
            CLLocationDegrees latitude = [[pointDictionary objectForKey: @"latitute"] doubleValue];
            CLLocationDegrees longitude = [[pointDictionary objectForKey: @"longitude"] doubleValue];
            CLLocationCoordinate2D point = CLLocationCoordinate2DMake(latitude, longitude);
            
            [points addObject: [NSValue valueWithMKCoordinate: point]];
        }
        
        // Get the center point of the building
        CLLocationCoordinate2D center;
        center.latitude = [[[[buildings objectAtIndex: index] objectForKey: @"center"] objectForKey: @"latitute"] doubleValue];
        center.longitude = [[[[buildings objectAtIndex: index] objectForKey: @"center"] objectForKey: @"longitude"] doubleValue];
        
        // Create a new building
        Building *building = [[Building alloc] initWithName: name points: points];
        [building setCenterPoint: center];
        
        [campusBuildings addObject: building];
    }
    
    [self setBuildings: campusBuildings];
}

@end
