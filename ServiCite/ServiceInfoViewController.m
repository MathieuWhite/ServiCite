//
//  ServiceInfoViewController.m
//  ServiCite
//
//  Created by Mathieu White on 2014-11-04.
//  Copyright (c) 2014 Mathieu White. All rights reserved.
//

#import "ServiceInfoViewController.h"
#import "Service.h"
#import "Campus.h"
#import "BuildingAnnotation.h"
#import "ServiceDetailView.h"

@interface ServiceInfoViewController ()

@property (nonatomic, strong) Service *service;

@property (nonatomic, weak) UIButton *closeButton;
@property (nonatomic, weak) UIView *mapContainer;
@property (nonatomic, weak) MKMapView *mapView;
@property (nonatomic, weak) UILabel *serviceName;

@property (nonatomic, weak) ServiceDetailView *roomDetail;
@property (nonatomic, weak) ServiceDetailView *phoneDetail;
@property (nonatomic, weak) ServiceDetailView *urlDetail;

@property (nonatomic, weak) UILabel *phone;
@property (nonatomic, weak) UILabel *extension;
@property (nonatomic, weak) UILabel *URL;

@property (nonatomic, strong) NSLayoutConstraint *mapContainerLeftConstraint;
@property (nonatomic, strong) NSLayoutConstraint *mapContainerRightConstraint;
@property (nonatomic, strong) NSLayoutConstraint *mapContainerBottomConstraint;
@property (nonatomic, strong) NSLayoutConstraint *serviceNameTopConstraint;
@property (nonatomic, strong) NSLayoutConstraint *serviceNameLeftConstraint;

@property (nonatomic, assign) UIInterfaceOrientation toInterfaceOrientation;

@end

@implementation ServiceInfoViewController

- (instancetype) initWithService: (Service *) service
{
    self = [super init];
    
    if (self)
    {
        _service = service;
    }
    
    return self;
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    // Set the background color
    [self.view setBackgroundColor: [UIColor colorWithWhite: 1.0f alpha: 0.95f]];
    
    // Initialize the Close Button
    UIButton *closeButton = [UIButton buttonWithType: UIButtonTypeSystem];
    [closeButton setTintColor: [UIColor colorWithRed: 0.0f/255.0f green: 172.0f/255.0f blue: 99.0f/255.0f alpha: 1.0f]];
    [closeButton setTitle: NSLocalizedString(@"Close", nil) forState: UIControlStateNormal];
    [closeButton.titleLabel setFont: [UIFont fontWithName: @"Avenir" size: 18.0f]];
    [closeButton setTranslatesAutoresizingMaskIntoConstraints: NO];
    [closeButton addTarget: self action: @selector(closeServiceInfoView) forControlEvents: UIControlEventTouchUpInside];
    
    // Initialize the container for the mapview
    UIView *mapContainer = [[UIView alloc] init];
    [mapContainer setBackgroundColor: [UIColor colorWithWhite: 0.5f alpha: 0.1f]];
    [mapContainer setTranslatesAutoresizingMaskIntoConstraints: NO];
    
    // Initialize the label with the service name
    UILabel *serviceName = [[UILabel alloc] init];
    [serviceName setText: [self.service name]];
    [serviceName setTextColor: [UIColor blackColor]];
    [serviceName setFont: [UIFont fontWithName: @"Avenir-Light" size: 20.0f]];
    [serviceName setAdjustsFontSizeToFitWidth: YES];
    [serviceName setTranslatesAutoresizingMaskIntoConstraints: NO];
    
    if ([[self.service name] length] > 21)
    {
        [serviceName setLineBreakMode: NSLineBreakByWordWrapping];
        [serviceName setNumberOfLines: 0];
    }
    
    // Initialize the service's room detail
    NSString *room = [self.service room];
    if ([room isEqualToString: @"none"])
        room = NSLocalizedString(@"Not Available", nil);
    ServiceDetailView *roomDetail = [[ServiceDetailView alloc] initWithTitle: NSLocalizedString(@"Room", nil) detail: room];
    
    // Initialize the services phone detail
    NSString *extension;
    NSString *phoneNumber;
    if (![[self.service extension] isEqualToString: @"none"])
    {
        extension = [NSString stringWithFormat: NSLocalizedString(@"ext. %@", nil), [self.service extension]];
        phoneNumber = [NSString stringWithFormat: @"%@, %@", [self.service phone], extension];
    }
    else phoneNumber = [self.service phone];
    ServiceDetailView *phoneDetail = [[ServiceDetailView alloc] initWithTitle: NSLocalizedString(@"Phone", nil) detail: phoneNumber];
    
    // Initialize the services' url detail
    ServiceDetailView *urlDetail = [[ServiceDetailView alloc] initWithTitle: NSLocalizedString(@"Website", nil) detail: [[self.service URL] absoluteString]];
    
    // Add each component to the view
    [self.view addSubview: closeButton];
    [self.view addSubview: mapContainer];
    [self.view addSubview: serviceName];
    [self.view addSubview: roomDetail];
    [self.view addSubview: phoneDetail];
    [self.view addSubview: urlDetail];
    
    // Set each component to a property
    [self setCloseButton: closeButton];
    [self setMapContainer: mapContainer];
    [self setServiceName: serviceName];
    [self setRoomDetail: roomDetail];
    [self setPhoneDetail: phoneDetail];
    [self setUrlDetail: urlDetail];
    
    if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation]))
        [self setToInterfaceOrientation: UIInterfaceOrientationPortrait];
    
    // Auto Layout
    [self setupConstraints];
}

- (void) viewDidAppear: (BOOL) animated
{
    [super viewDidAppear: animated];
    
    [self setupMapView];
}

- (void) didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) willRotateToInterfaceOrientation: (UIInterfaceOrientation) toInterfaceOrientation duration: (NSTimeInterval) duration
{
    [super willRotateToInterfaceOrientation: toInterfaceOrientation duration: duration];
    
    [self setToInterfaceOrientation: toInterfaceOrientation];
    
    [self updateViewConstraints];
}

/*
- (void) didRotateFromInterfaceOrientation: (UIInterfaceOrientation) fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation: fromInterfaceOrientation];
    
    [self updateViewConstraints];
}
 */

#pragma mark - Private Methods

- (void) closeServiceInfoView
{
    [self dismissViewControllerAnimated: YES completion: nil];
}

- (void) setupMapView
{
    // Initialize a map view
    MKMapView *mapView = [[MKMapView alloc] init];
    [mapView setUserInteractionEnabled: NO];
    [mapView setShowsPointsOfInterest: NO];
    [mapView setTranslatesAutoresizingMaskIntoConstraints: NO];
    [mapView setDelegate: self];
    
    // Set the region to the service location
    MKCoordinateRegion serviceRegion = MKCoordinateRegionMakeWithDistance([self.service centerPoint], 140, 140);
    [mapView setRegion: serviceRegion animated: NO];
    
    // Set up the campus overlay
    Campus *campus = [Campus sharedCampus];
        
    for (Building *building in [campus buildings])
    {
        CLLocationCoordinate2D points[[building.points count]];
            
        for (NSUInteger index = 0; index < [building.points count]; index++)
        {
            CLLocationCoordinate2D point = [[building.points objectAtIndex: index] MKCoordinateValue];
            points[index] = point;
        }
            
        MKPolygon *buildingPolygon = [MKPolygon polygonWithCoordinates: points count: [building.points count]];
        [buildingPolygon setTitle: @"buildingPolygon"];
        [mapView addOverlay: buildingPolygon];
            
        CLLocationCoordinate2D centerPoint = [building centerPoint];
        BuildingAnnotation *annotation = [[BuildingAnnotation alloc] initWithTitle: [building name]
                                                                        coordinate: centerPoint];
        [mapView addAnnotation: annotation];
    }
    
    // Add the service overlay
    CLLocationCoordinate2D points[[self.service.points count]];
    
    for (NSUInteger index = 0; index < [self.service.points count]; index++)
    {
        CLLocationCoordinate2D point = [[self.service.points objectAtIndex: index] MKCoordinateValue];
        points[index] = point;
    }
    
    MKPolygon *polygon = [MKPolygon polygonWithCoordinates: points count: [self.service.points count]];
    [polygon setTitle: @"servicePolygon"];
    [mapView addOverlay: polygon];
    
    // Add the point annotation
    MKPointAnnotation *pin = [[MKPointAnnotation alloc] init];
    [pin setCoordinate: [self.service centerPoint]];
    [mapView addAnnotation: pin];
    
    [self.mapContainer addSubview: mapView];
    
    // Map View Auto Layout
    NSDictionary *views = @{@"mapView" : mapView};
    
    NSArray *mapHorizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat: @"H:|[mapView]|"
                                                                                options: 0
                                                                                metrics: nil
                                                                                  views: views];
    
    NSArray *mapVerticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat: @"V:|[mapView]|"
                                                                              options: 0
                                                                              metrics: nil
                                                                                views: views];
    
    [self.mapContainer addConstraints: mapHorizontalConstraints];
    [self.mapContainer addConstraints: mapVerticalConstraints];
    
    [self setMapView: mapView];
}

#pragma mark - Auto Layout Method

- (void) setupConstraints
{
    // Close Button Width
    [self.view addConstraint: [NSLayoutConstraint constraintWithItem: self.closeButton
                                                           attribute: NSLayoutAttributeWidth
                                                           relatedBy: NSLayoutRelationEqual
                                                              toItem: self.view
                                                           attribute: NSLayoutAttributeWidth
                                                          multiplier: 0.0f
                                                            constant: 60.0f]];
    
    // Close Button Height
    [self.view addConstraint: [NSLayoutConstraint constraintWithItem: self.closeButton
                                                           attribute: NSLayoutAttributeHeight
                                                           relatedBy: NSLayoutRelationEqual
                                                              toItem: self.view
                                                           attribute: NSLayoutAttributeHeight
                                                          multiplier: 0.0f
                                                            constant: 44.0f]];
    
    // Close Button Top
    [self.view addConstraint: [NSLayoutConstraint constraintWithItem: self.closeButton
                                                           attribute: NSLayoutAttributeTop
                                                           relatedBy: NSLayoutRelationEqual
                                                              toItem: self.view
                                                           attribute: NSLayoutAttributeTop
                                                          multiplier: 1.0f
                                                            constant: 0.0f]];
    
    // Close Button Right
    [self.view addConstraint: [NSLayoutConstraint constraintWithItem: self.closeButton
                                                           attribute: NSLayoutAttributeRight
                                                           relatedBy: NSLayoutRelationEqual
                                                              toItem: self.view
                                                           attribute: NSLayoutAttributeRight
                                                          multiplier: 1.0f
                                                            constant: -8.0f]];
    
    // Map Container Top
    [self.view addConstraint: [NSLayoutConstraint constraintWithItem: self.mapContainer
                                                           attribute: NSLayoutAttributeTop
                                                           relatedBy: NSLayoutRelationEqual
                                                              toItem: self.closeButton
                                                           attribute: NSLayoutAttributeBottom
                                                          multiplier: 1.0f
                                                            constant: 0.0f]];
    
    // Service Name Height
    if ([self.service.name length] > 21)
    {
        [self.view addConstraint: [NSLayoutConstraint constraintWithItem: self.serviceName
                                                               attribute: NSLayoutAttributeHeight
                                                               relatedBy: NSLayoutRelationEqual
                                                                  toItem: self.view
                                                               attribute: NSLayoutAttributeHeight
                                                              multiplier: 0.0f
                                                                constant: 66.0f]];
    }
    else
    {
        [self.view addConstraint: [NSLayoutConstraint constraintWithItem: self.serviceName
                                                               attribute: NSLayoutAttributeHeight
                                                               relatedBy: NSLayoutRelationEqual
                                                                  toItem: self.view
                                                               attribute: NSLayoutAttributeHeight
                                                              multiplier: 0.0f
                                                                constant: 44.0f]];
    }
    
    // Service Name Right
    [self.view addConstraint: [NSLayoutConstraint constraintWithItem: self.serviceName
                                                           attribute: NSLayoutAttributeRight
                                                           relatedBy: NSLayoutRelationEqual
                                                              toItem: self.view
                                                           attribute: NSLayoutAttributeRight
                                                          multiplier: 1.0f
                                                            constant: -16.0f]];
    
    // Room Detail Height
    [self.view addConstraint: [NSLayoutConstraint constraintWithItem: self.roomDetail
                                                           attribute: NSLayoutAttributeHeight
                                                           relatedBy: NSLayoutRelationEqual
                                                              toItem: self.view
                                                           attribute: NSLayoutAttributeHeight
                                                          multiplier: 0.0f
                                                            constant: 48.0f]];
    
    // Room Detail Top
    [self.view addConstraint: [NSLayoutConstraint constraintWithItem: self.roomDetail
                                                           attribute: NSLayoutAttributeTop
                                                           relatedBy: NSLayoutRelationEqual
                                                              toItem: self.serviceName
                                                           attribute: NSLayoutAttributeBottom
                                                          multiplier: 1.0f
                                                            constant: 0.0f]];
    
    // Room Detail Right
    [self.view addConstraint: [NSLayoutConstraint constraintWithItem: self.roomDetail
                                                           attribute: NSLayoutAttributeRight
                                                           relatedBy: NSLayoutRelationEqual
                                                              toItem: self.view
                                                           attribute: NSLayoutAttributeRight
                                                          multiplier: 1.0f
                                                            constant: -16.0f]];
    
    // Room Detail Left
    [self.view addConstraint: [NSLayoutConstraint constraintWithItem: self.roomDetail
                                                           attribute: NSLayoutAttributeLeft
                                                           relatedBy: NSLayoutRelationEqual
                                                              toItem: self.serviceName
                                                           attribute: NSLayoutAttributeLeft
                                                          multiplier: 1.0f
                                                            constant: 0.0f]];
    
    // Phone Detail Height
    [self.view addConstraint: [NSLayoutConstraint constraintWithItem: self.phoneDetail
                                                           attribute: NSLayoutAttributeHeight
                                                           relatedBy: NSLayoutRelationEqual
                                                              toItem: self.view
                                                           attribute: NSLayoutAttributeHeight
                                                          multiplier: 0.0f
                                                            constant: 48.0f]];
    
    // Phone Detail Top
    [self.view addConstraint: [NSLayoutConstraint constraintWithItem: self.phoneDetail
                                                           attribute: NSLayoutAttributeTop
                                                           relatedBy: NSLayoutRelationEqual
                                                              toItem: self.roomDetail
                                                           attribute: NSLayoutAttributeBottom
                                                          multiplier: 1.0f
                                                            constant: 8.0f]];
    
    // Phone Detail Right
    [self.view addConstraint: [NSLayoutConstraint constraintWithItem: self.phoneDetail
                                                           attribute: NSLayoutAttributeRight
                                                           relatedBy: NSLayoutRelationEqual
                                                              toItem: self.view
                                                           attribute: NSLayoutAttributeRight
                                                          multiplier: 1.0f
                                                            constant: -16.0f]];
    
    // Phone Detail Left
    [self.view addConstraint: [NSLayoutConstraint constraintWithItem: self.phoneDetail
                                                           attribute: NSLayoutAttributeLeft
                                                           relatedBy: NSLayoutRelationEqual
                                                              toItem: self.serviceName
                                                           attribute: NSLayoutAttributeLeft
                                                          multiplier: 1.0f
                                                            constant: 0.0f]];
    
    // URL Detail Height
    [self.view addConstraint: [NSLayoutConstraint constraintWithItem: self.urlDetail
                                                           attribute: NSLayoutAttributeHeight
                                                           relatedBy: NSLayoutRelationEqual
                                                              toItem: self.view
                                                           attribute: NSLayoutAttributeHeight
                                                          multiplier: 0.0f
                                                            constant: 48.0f]];
    
    // URL Detail Top
    [self.view addConstraint: [NSLayoutConstraint constraintWithItem: self.urlDetail
                                                           attribute: NSLayoutAttributeTop
                                                           relatedBy: NSLayoutRelationEqual
                                                              toItem: self.phoneDetail
                                                           attribute: NSLayoutAttributeBottom
                                                          multiplier: 1.0f
                                                            constant: 8.0f]];
    
    // URL Detail Right
    [self.view addConstraint: [NSLayoutConstraint constraintWithItem: self.urlDetail
                                                           attribute: NSLayoutAttributeRight
                                                           relatedBy: NSLayoutRelationEqual
                                                              toItem: self.view
                                                           attribute: NSLayoutAttributeRight
                                                          multiplier: 1.0f
                                                            constant: -16.0f]];
    
    // URL Detail Left
    [self.view addConstraint: [NSLayoutConstraint constraintWithItem: self.urlDetail
                                                           attribute: NSLayoutAttributeLeft
                                                           relatedBy: NSLayoutRelationEqual
                                                              toItem: self.serviceName
                                                           attribute: NSLayoutAttributeLeft
                                                          multiplier: 1.0f
                                                            constant: 0.0f]];
    
    // Orientation specific layout
    NSLayoutConstraint *mapContainerLeftConstraint;
    NSLayoutConstraint *mapContainerRightConstraint;
    NSLayoutConstraint *mapContainerBottomConstraint;
    NSLayoutConstraint *serviceNameTopConstraint;
    NSLayoutConstraint *serviceNameLeftConstraint;
    
    // Portrait
    if ([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationPortrait)
    {
        // Map Container Left
        mapContainerLeftConstraint = [NSLayoutConstraint constraintWithItem: self.mapContainer
                                                                  attribute: NSLayoutAttributeLeft
                                                                  relatedBy: NSLayoutRelationEqual
                                                                     toItem: self.view
                                                                  attribute: NSLayoutAttributeLeft
                                                                 multiplier: 1.0f
                                                                   constant: 0.0f];
        
        // Map Container Right
        mapContainerRightConstraint = [NSLayoutConstraint constraintWithItem: self.mapContainer
                                                                   attribute: NSLayoutAttributeRight
                                                                   relatedBy: NSLayoutRelationEqual
                                                                      toItem: self.view
                                                                   attribute: NSLayoutAttributeRight
                                                                  multiplier: 1.0f
                                                                    constant: 0.0f];
        
        // Map Container Bottom
        mapContainerBottomConstraint = [NSLayoutConstraint constraintWithItem: self.mapContainer
                                                                    attribute: NSLayoutAttributeBottom
                                                                    relatedBy: NSLayoutRelationEqual
                                                                       toItem: self.view
                                                                    attribute: NSLayoutAttributeBottom
                                                                   multiplier: 0.4f
                                                                     constant: 0.0f];
        
        // Service Name Top
        serviceNameTopConstraint = [NSLayoutConstraint constraintWithItem: self.serviceName
                                                                attribute: NSLayoutAttributeTop
                                                                relatedBy: NSLayoutRelationEqual
                                                                   toItem: self.view
                                                                attribute: NSLayoutAttributeBottom
                                                               multiplier: 0.4f
                                                                 constant: 8.0f];
        
        // Service Name Left
        serviceNameLeftConstraint = [NSLayoutConstraint constraintWithItem: self.serviceName
                                                                 attribute: NSLayoutAttributeLeft
                                                                 relatedBy: NSLayoutRelationEqual
                                                                    toItem: self.view
                                                                 attribute: NSLayoutAttributeLeft
                                                                multiplier: 1.0f
                                                                  constant: 16.0f];
    }
    
    else
    {
        // Map Container Left
        mapContainerLeftConstraint = [NSLayoutConstraint constraintWithItem: self.mapContainer
                                                                  attribute: NSLayoutAttributeLeft
                                                                  relatedBy: NSLayoutRelationEqual
                                                                     toItem: self.view
                                                                  attribute: NSLayoutAttributeLeft
                                                                 multiplier: 1.0f
                                                                   constant: 10.0f];
        
        // Map Container Right
        mapContainerRightConstraint = [NSLayoutConstraint constraintWithItem: self.mapContainer
                                                                   attribute: NSLayoutAttributeRight
                                                                   relatedBy: NSLayoutRelationEqual
                                                                      toItem: self.view
                                                                   attribute: NSLayoutAttributeCenterX
                                                                  multiplier: 1.0f
                                                                    constant: -8.0f];
        
        // Map Container Bottom
        mapContainerBottomConstraint = [NSLayoutConstraint constraintWithItem: self.mapContainer
                                                                    attribute: NSLayoutAttributeBottom
                                                                    relatedBy: NSLayoutRelationEqual
                                                                       toItem: self.view
                                                                    attribute: NSLayoutAttributeBottom
                                                                   multiplier: 1.0f
                                                                     constant: -10.0f];
        
        // Service Name Top
        serviceNameTopConstraint = [NSLayoutConstraint constraintWithItem: self.serviceName
                                                                attribute: NSLayoutAttributeTop
                                                                relatedBy: NSLayoutRelationEqual
                                                                   toItem: self.closeButton
                                                                attribute: NSLayoutAttributeBottom
                                                               multiplier: 1.0f
                                                                 constant: 8.0f];
        
        // Service Name Left
        serviceNameLeftConstraint = [NSLayoutConstraint constraintWithItem: self.serviceName
                                                                 attribute: NSLayoutAttributeLeft
                                                                 relatedBy: NSLayoutRelationEqual
                                                                    toItem: self.view
                                                                 attribute: NSLayoutAttributeCenterX
                                                                multiplier: 1.0f
                                                                  constant: 8.0f];
    }
    
    [self.view addConstraint: mapContainerLeftConstraint];
    [self.view addConstraint: mapContainerRightConstraint];
    [self.view addConstraint: mapContainerBottomConstraint];
    [self.view addConstraint: serviceNameTopConstraint];
    [self.view addConstraint: serviceNameLeftConstraint];
    
    [self setMapContainerLeftConstraint: mapContainerLeftConstraint];
    [self setMapContainerRightConstraint: mapContainerRightConstraint];
    [self setMapContainerBottomConstraint: mapContainerBottomConstraint];
    [self setServiceNameTopConstraint: serviceNameTopConstraint];
    [self setServiceNameLeftConstraint: serviceNameLeftConstraint];
    
}

- (void) updateViewConstraints
{
    [self.view removeConstraint: self.mapContainerLeftConstraint];
    [self.view removeConstraint: self.mapContainerRightConstraint];
    [self.view removeConstraint: self.mapContainerBottomConstraint];
    [self.view removeConstraint: self.serviceNameTopConstraint];
    [self.view removeConstraint: self.serviceNameLeftConstraint];
    
    NSLayoutConstraint *mapContainerLeftConstraint;
    NSLayoutConstraint *mapContainerRightConstraint;
    NSLayoutConstraint *mapContainerBottomConstraint;
    NSLayoutConstraint *serviceNameTopConstraint;
    NSLayoutConstraint *serviceNameLeftConstraint;
    
    // Portrait
    //if ([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationPortrait)
    if (UIInterfaceOrientationIsPortrait([self toInterfaceOrientation]))
    {
        // Map Container Left
        mapContainerLeftConstraint = [NSLayoutConstraint constraintWithItem: self.mapContainer
                                                                  attribute: NSLayoutAttributeLeft
                                                                  relatedBy: NSLayoutRelationEqual
                                                                     toItem: self.view
                                                                  attribute: NSLayoutAttributeLeft
                                                                 multiplier: 1.0f
                                                                   constant: 0.0f];
        
        // Map Container Right
        mapContainerRightConstraint = [NSLayoutConstraint constraintWithItem: self.mapContainer
                                                                   attribute: NSLayoutAttributeRight
                                                                   relatedBy: NSLayoutRelationEqual
                                                                      toItem: self.view
                                                                   attribute: NSLayoutAttributeRight
                                                                  multiplier: 1.0f
                                                                    constant: 0.0f];
        
        // Map Container Bottom
        mapContainerBottomConstraint = [NSLayoutConstraint constraintWithItem: self.mapContainer
                                                                    attribute: NSLayoutAttributeBottom
                                                                    relatedBy: NSLayoutRelationEqual
                                                                       toItem: self.view
                                                                    attribute: NSLayoutAttributeBottom
                                                                   multiplier: 0.4f
                                                                     constant: 0.0f];
        
        // Service Name Top
        serviceNameTopConstraint = [NSLayoutConstraint constraintWithItem: self.serviceName
                                                                attribute: NSLayoutAttributeTop
                                                                relatedBy: NSLayoutRelationEqual
                                                                   toItem: self.view
                                                                attribute: NSLayoutAttributeBottom
                                                               multiplier: 0.4f
                                                                 constant: 8.0f];
        
        // Service Name Left
        serviceNameLeftConstraint = [NSLayoutConstraint constraintWithItem: self.serviceName
                                                                 attribute: NSLayoutAttributeLeft
                                                                 relatedBy: NSLayoutRelationEqual
                                                                    toItem: self.view
                                                                 attribute: NSLayoutAttributeLeft
                                                                multiplier: 1.0f
                                                                  constant: 16.0f];
    }
    
    else
    {
        // Map Container Left
        mapContainerLeftConstraint = [NSLayoutConstraint constraintWithItem: self.mapContainer
                                                                  attribute: NSLayoutAttributeLeft
                                                                  relatedBy: NSLayoutRelationEqual
                                                                     toItem: self.view
                                                                  attribute: NSLayoutAttributeLeft
                                                                 multiplier: 1.0f
                                                                   constant: 10.0f];
        
        // Map Container Right
        mapContainerRightConstraint = [NSLayoutConstraint constraintWithItem: self.mapContainer
                                                                   attribute: NSLayoutAttributeRight
                                                                   relatedBy: NSLayoutRelationEqual
                                                                      toItem: self.view
                                                                   attribute: NSLayoutAttributeCenterX
                                                                  multiplier: 1.0f
                                                                    constant: -8.0f];
        
        // Map Container Bottom
        mapContainerBottomConstraint = [NSLayoutConstraint constraintWithItem: self.mapContainer
                                                                    attribute: NSLayoutAttributeBottom
                                                                    relatedBy: NSLayoutRelationEqual
                                                                       toItem: self.view
                                                                    attribute: NSLayoutAttributeBottom
                                                                   multiplier: 1.0f
                                                                     constant: -10.0f];
        
        // Service Name Top
        serviceNameTopConstraint = [NSLayoutConstraint constraintWithItem: self.serviceName
                                                                attribute: NSLayoutAttributeTop
                                                                relatedBy: NSLayoutRelationEqual
                                                                   toItem: self.closeButton
                                                                attribute: NSLayoutAttributeBottom
                                                               multiplier: 1.0f
                                                                 constant: 8.0f];
        
        // Service Name Left
        serviceNameLeftConstraint = [NSLayoutConstraint constraintWithItem: self.serviceName
                                                                 attribute: NSLayoutAttributeLeft
                                                                 relatedBy: NSLayoutRelationEqual
                                                                    toItem: self.view
                                                                 attribute: NSLayoutAttributeCenterX
                                                                multiplier: 1.0f
                                                                  constant: 8.0f];
    }
    
    [self.view addConstraint: mapContainerLeftConstraint];
    [self.view addConstraint: mapContainerRightConstraint];
    [self.view addConstraint: mapContainerBottomConstraint];
    [self.view addConstraint: serviceNameTopConstraint];
    [self.view addConstraint: serviceNameLeftConstraint];
    
    [self setMapContainerLeftConstraint: mapContainerLeftConstraint];
    [self setMapContainerRightConstraint: mapContainerRightConstraint];
    [self setMapContainerBottomConstraint: mapContainerBottomConstraint];
    [self setServiceNameTopConstraint: serviceNameTopConstraint];
    [self setServiceNameLeftConstraint: serviceNameLeftConstraint];
    
    [super updateViewConstraints];
}

#pragma mark - MKMapViewDelegate Methods

- (MKOverlayRenderer *) mapView: (MKMapView *) mapView rendererForOverlay: (id <MKOverlay>) overlay
{
    if ([overlay isKindOfClass: [MKPolygon class]])
    {
        MKPolygonRenderer *renderer = [[MKPolygonRenderer alloc] initWithPolygon: overlay];
        if ([[renderer.overlay title] isEqualToString: @"buildingPolygon"])
            [renderer setFillColor: [UIColor colorWithRed: 0.0f/255.0f green: 172.0f/255.0f blue: 99.0f/255.0f alpha: 0.6f]];
        else
            [renderer setFillColor: [UIColor colorWithRed: 0.0f green: 0.0f blue: 0.0f alpha: 0.2f]];
        return renderer;
    }
    
    return nil;
}

- (MKAnnotationView *) mapView: (MKMapView *) map viewForAnnotation: (id <MKAnnotation>) annotation
{
    // User location annotation
    if ([annotation isKindOfClass: [MKUserLocation class]])
    {
        return nil;
    }
    
    // Building label annotation
    if ([annotation isKindOfClass: [BuildingAnnotation class]])
    {
        MKAnnotationView *aView = [[MKAnnotationView alloc] init];
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame: CGRectMake(0, 0, 64, 20)];
        [titleLabel setText: [annotation title]];
        [titleLabel setTextColor: [UIColor whiteColor]];
        [titleLabel setTextAlignment: NSTextAlignmentCenter];
        [titleLabel setFont: [UIFont fontWithName: @"Avenir-Medium" size: 14.0f]];
        [aView addSubview: titleLabel];
        [aView setFrame: [titleLabel bounds]];
        
        return aView;
    }
    
    return nil;
}

@end
