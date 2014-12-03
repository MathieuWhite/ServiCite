//
//  Services.h
//  ServiCite
//
//  Created by Mathieu White on 2014-10-31.
//  Copyright (c) 2014 Mathieu White. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Service.h"

@interface Services : NSObject

@property (nonatomic, strong) NSMutableArray *allServices;

+ (Services *) sharedServices;
- (instancetype) initWithFilename: (NSString *) filename;

@end
