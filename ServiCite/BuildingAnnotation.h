//
//  BuildingAnnotation.h
//  ServiCite
//
//  Created by Mathieu White on 2014-10-31.
//  Copyright (c) 2014 Mathieu White. All rights reserved.
//

@import MapKit;

#import <Foundation/Foundation.h>

@interface BuildingAnnotation : NSObject <MKAnnotation>

@property (nonatomic, copy) NSString *title;
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;

- (id) initWithTitle: (NSString *) title coordinate: (CLLocationCoordinate2D) coordinate;

@end
