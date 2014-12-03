//
//  Campus.h
//  ServiCite
//
//  Created by Mathieu White on 2014-10-31.
//  Copyright (c) 2014 Mathieu White. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Building.h"
#import "BuildingAnnotation.h"

@interface Campus : NSObject

@property (nonatomic, strong) NSMutableArray *buildings;

+ (Campus *) sharedCampus;
- (instancetype) initWithFilename: (NSString *) filename;

@end
