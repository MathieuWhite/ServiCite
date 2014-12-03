//
//  FrontViewController.m
//  ServiCite
//
//  Created by Mathieu White on 2014-10-28.
//  Copyright (c) 2014 Mathieu White. All rights reserved.
//

@import MapKit;

#import "FrontViewController.h"
#import "ServiceInfoViewController.h"
#import "PresentingAnimator.h"
#import "DismissingAnimator.h"
#import "Campus.h"
#import "Services.h"
#import "POP.h"

@interface FrontViewController () <CLLocationManagerDelegate, MKMapViewDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;

@property (nonatomic, weak) MKMapView *mapView;
@property (nonatomic, weak) ActionBar *actionBar;

@property (nonatomic, strong) NSMutableArray *buildingAnnotations;
@property (nonatomic, strong) NSMutableArray *serviceAnnotations;
@property (nonatomic, strong) NSMutableArray *duplicateAnnotations;
@property (nonatomic, strong) NSMutableArray *serviceAnnotationsNoRooms;
@property (nonatomic, strong) NSMutableArray *serviceOverlays;
@property (nonatomic, strong) NSMutableArray *duplicateOverlays;

@property (nonatomic, assign) BOOL showingServiceAnnotations;
@property (nonatomic, getter = isTrackingUserLocation) BOOL trackingUserLocation;

@end

@implementation FrontViewController

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    [self setupLocationManager];
    
    // Set the background color
    [self.view setBackgroundColor: [UIColor grayColor]];
    
    // The array to store the title annotations
    NSMutableArray *buildingAnnotations = [NSMutableArray array];
    [self setBuildingAnnotations: buildingAnnotations];
    
    // Tap Gesture Recognizer for retrieving coordinates
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(getCoordinates:)];
    
    // Initialize the map view
    MKMapView *mapView = [[MKMapView alloc] init];
    [mapView setTranslatesAutoresizingMaskIntoConstraints: NO];
    [mapView addGestureRecognizer: tapGesture];
    [mapView setShowsPointsOfInterest: NO];
    [mapView setShowsUserLocation: YES];
    [mapView setDelegate: self];
    
    // Initialize the action bar
    ActionBar *actionBar =[ActionBar sharedActionBar];
    
    // Add the components to the view
    [self.view addSubview: mapView];
    [self.view addSubview: actionBar];
    
    // Set each component to a property
    [self setMapView: mapView];
    [self setActionBar: actionBar];
    
    // Load the campus overlay on the map
    [self setupCampusOverlay];
    
    // Setup the services
    [self setupServices];
    
    // Auto Layout
    [self setupConstraints];
    
    // Notification to set the map view region to the main campus
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(showCiteCampus)
                                                 name: kMapViewMainCampusRegionNotification
                                               object: nil];
    
    // Notification to show the points of interest on the map
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(showPointsOfInterest)
                                                 name: kShowPointsOfInterestNotification
                                               object: nil];
    
    // Notification to set the map view type to satellite
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(changeMapType)
                                                 name: kChangeMapTypeNotification
                                               object: nil];
    
    // Notification for when the user taps the location tracking button
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(trackUserLocation)
                                                 name: kUserWantsLocationTrackingNotification
                                               object: nil];
}

- (void) viewWillAppear: (BOOL) animated
{
    [super viewWillAppear: animated];
    
    [self showCiteCampus];
}

- (void) setupLocationManager
{
    CLLocationManager *locationManager = [[CLLocationManager alloc] init];
    [locationManager setDelegate: self];
    
    // Check for iOS 8. Without this guard the code will crash with "unknown selector" on iOS 7.
    if ([locationManager respondsToSelector: @selector(requestWhenInUseAuthorization)])
        [locationManager requestWhenInUseAuthorization];
    
    [locationManager startUpdatingLocation];
    
    [self setLocationManager: locationManager];
}

- (void) setupCampusOverlay
{
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
        [self.mapView addOverlay: buildingPolygon];
        
        CLLocationCoordinate2D centerPoint = [building centerPoint];
        BuildingAnnotation *annotation = [[BuildingAnnotation alloc] initWithTitle: [building name]
                                                                        coordinate: centerPoint];
        //[self.mapView addAnnotation: title];
        [self.buildingAnnotations addObject: annotation];
    }
}

- (void) setupServices
{
    // The array to store the service annotations
    NSMutableArray *serviceAnnotations = [NSMutableArray array];
    NSMutableArray *serviceAnnotationsNoRooms = [NSMutableArray array];
    NSMutableArray *duplicateAnnotations = [NSMutableArray array];
    
    // The array to store the service overlays
    NSMutableArray *serviceOverlays = [NSMutableArray array];
    NSMutableArray *duplicateOverlays = [NSMutableArray array];
    
    Services *services = [Services sharedServices];
    
    for (Service *service in [services allServices])
    {
        CLLocationCoordinate2D points[[service.points count]];
        
        for (NSUInteger index = 0; index < [service.points count]; index++)
        {
            CLLocationCoordinate2D point = [[service.points objectAtIndex: index] MKCoordinateValue];
            points[index] = point;
        }
        
        MKPolygon *servicePolygon = [MKPolygon polygonWithCoordinates: points count: [service.points count]];
        [servicePolygon setTitle: @"servicePolygon"];
        [serviceOverlays addObject: servicePolygon];
        
        CLLocationCoordinate2D centerPoint = [service centerPoint];
        
        MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
        if ([service.name length] < 26)
            [annotation setTitle: [service name]];
        else [annotation setTitle: [NSString stringWithFormat: @"%@...", [service.name substringToIndex: 26]]];
        
        if (![[service room] isEqualToString: @"none"])
            [annotation setSubtitle: [service room]];
        [annotation setCoordinate: centerPoint];
        
        [serviceAnnotations addObject: annotation];
        
        // These service annotations have no dedicated room
        if (centerPoint.latitude == 45.439953 && centerPoint.longitude == -75.626851)
            [serviceAnnotationsNoRooms addObject: annotation];
    }
    
    [self setServiceAnnotations: serviceAnnotations];
    [self setServiceOverlays: serviceOverlays];
    [self setServiceAnnotationsNoRooms: serviceAnnotationsNoRooms];
    [self setDuplicateAnnotations: duplicateAnnotations];
    [self setDuplicateOverlays: duplicateOverlays];
}

- (void) didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIViewControllerTransitioningDelegate Methods

- (id <UIViewControllerAnimatedTransitioning>) animationControllerForPresentedController: (UIViewController *) presented
                                                                    presentingController: (UIViewController *) presenting
                                                                        sourceController: (UIViewController *) source
{
    return [[PresentingAnimator alloc] init];
}

- (id <UIViewControllerAnimatedTransitioning>) animationControllerForDismissedController: (UIViewController *) dismissed
{
    return [[DismissingAnimator alloc] init];
}

#pragma mark - Gesture Recognizer Method

- (void) getCoordinates: (UITapGestureRecognizer *) gesture
{
    CLLocationCoordinate2D coordinates = [self.mapView convertPoint:
                                          [gesture locationInView: self.mapView] toCoordinateFromView: self.mapView];
    NSLog(@"{ %.10f, %.10f }", coordinates.latitude, coordinates.longitude);
}

#pragma mark - Auto Layout Method

- (void) setupConstraints
{
    // Map View Width
    [self.view addConstraint: [NSLayoutConstraint constraintWithItem: self.mapView
                                                           attribute: NSLayoutAttributeWidth
                                                           relatedBy: NSLayoutRelationEqual
                                                              toItem: self.view
                                                           attribute: NSLayoutAttributeWidth
                                                          multiplier: 1.0f
                                                            constant: 0.0f]];
    
    // Map View Height
    [self.view addConstraint: [NSLayoutConstraint constraintWithItem: self.mapView
                                                           attribute: NSLayoutAttributeHeight
                                                           relatedBy: NSLayoutRelationEqual
                                                              toItem: self.view
                                                           attribute: NSLayoutAttributeHeight
                                                          multiplier: 1.0f
                                                            constant: 0.0f]];
    
    // Map View Top
    [self.view addConstraint: [NSLayoutConstraint constraintWithItem: self.mapView
                                                           attribute: NSLayoutAttributeTop
                                                           relatedBy: NSLayoutRelationEqual
                                                              toItem: self.view
                                                           attribute: NSLayoutAttributeTop
                                                          multiplier: 1.0f
                                                            constant: 0.0f]];
    
    // Map View Left
    [self.view addConstraint: [NSLayoutConstraint constraintWithItem: self.mapView
                                                           attribute: NSLayoutAttributeLeft
                                                           relatedBy: NSLayoutRelationEqual
                                                              toItem: self.view
                                                           attribute: NSLayoutAttributeLeft
                                                          multiplier: 1.0f
                                                            constant: 0.0f]];
    
    // Action Bar Width
    [self.view addConstraint: [NSLayoutConstraint constraintWithItem: self.actionBar
                                                           attribute: NSLayoutAttributeWidth
                                                           relatedBy: NSLayoutRelationEqual
                                                              toItem: self.view
                                                           attribute: NSLayoutAttributeWidth
                                                          multiplier: 1.0f
                                                            constant: 0.0f]];
    
    // Action Bar Height
    [self.view addConstraint: [NSLayoutConstraint constraintWithItem: self.actionBar
                                                           attribute: NSLayoutAttributeHeight
                                                           relatedBy: NSLayoutRelationEqual
                                                              toItem: self.view
                                                           attribute: NSLayoutAttributeHeight
                                                          multiplier: 0.0f
                                                            constant: 64.0f]];
    
    // Action Bar Top
    [self.view addConstraint: [NSLayoutConstraint constraintWithItem: self.actionBar
                                                           attribute: NSLayoutAttributeTop
                                                           relatedBy: NSLayoutRelationEqual
                                                              toItem: self.view
                                                           attribute: NSLayoutAttributeTop
                                                          multiplier: 1.0f
                                                            constant: 0.0f]];
    
    // Action Bar Left
    [self.view addConstraint: [NSLayoutConstraint constraintWithItem: self.actionBar
                                                           attribute: NSLayoutAttributeLeft
                                                           relatedBy: NSLayoutRelationEqual
                                                              toItem: self.view
                                                           attribute: NSLayoutAttributeLeft
                                                          multiplier: 1.0f
                                                            constant: 0.0f]];
}

#pragma mark - MKMapViewDelegate Methods

- (void) mapView: (MKMapView *) mapView regionDidChangeAnimated: (BOOL) animated
{
    //NSLog(@"region did change");
    
    // Change the compass view frame
    for (UIView *aView in [mapView subviews])
    {
        if ([NSStringFromClass([aView class]) isEqualToString: @"MKCompassView"])
        {
            CGFloat width = CGRectGetWidth([aView bounds]);
            CGFloat height = CGRectGetHeight([aView bounds]);
            CGFloat x = CGRectGetMaxX([self.view bounds]) - width - 14.0f;
            CGFloat y = 64.0f;
            
            [aView setFrame: CGRectMake(x, y, width, height)];
            
            break;
        }
    }
    
    // Show/Hide Building names at a certain region span
    if (mapView.region.span.longitudeDelta > 0.004)
        [mapView removeAnnotations: [self buildingAnnotations]];
    else [mapView addAnnotations: [self buildingAnnotations]];
    
    /*
    // Turn off user tracking
    if([self isTrackingUserLocation] )
    {
        [mapView setUserTrackingMode: MKUserTrackingModeNone];
        
        [self setTrackingUserLocation: NO];
        
        [[NSNotificationCenter defaultCenter] postNotificationName: kUserLocationTrackingStateChanged
                                                            object: @([self isTrackingUserLocation])];
    }
    
    [self setPendingRegionChange: NO];
     */
}

- (void) mapViewWillStartLoadingMap: (MKMapView *) mapView
{
    NSLog(@"mapViewWillStartLoadingMap");
}

- (void) mapViewDidFinishLoadingMap: (MKMapView *) mapView
{
    NSLog(@"mapViewDidFinishLoadingMap");
}

- (void) mapViewDidFinishRenderingMap: (MKMapView *) mapView fullyRendered: (BOOL) fullyRendered
{
    NSLog(@"mapViewDidFinishRenderingMap");
}

- (void) mapView: (MKMapView *) mapView didUpdateUserLocation: (MKUserLocation *) userLocation
{
    if ([self isTrackingUserLocation])
        [self.mapView setCenterCoordinate: userLocation.location.coordinate animated: YES];
    
    //NSLog(@"didUpdateUserLocation");

    //if ([self userWantsLocationTracking])
    //    [self trackUserLocation];
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
    
    // Return a pin annotation view
    MKPinAnnotationView *pin = [[MKPinAnnotationView alloc] initWithAnnotation: annotation reuseIdentifier: @"ServiceAnnoation"];

    UIButton *infoButton = [UIButton buttonWithType: UIButtonTypeInfoLight];
    [infoButton setTintColor: [UIColor colorWithRed: 0.0f/255.0f green: 172.0f/255.0f blue: 99.0f/255.0f alpha: 1.0f]];
    [infoButton setFrame: CGRectMake(0, 0, 24, 24)];
    [infoButton setContentHorizontalAlignment: UIControlContentHorizontalAlignmentCenter];
    [infoButton setContentVerticalAlignment: UIControlContentVerticalAlignmentCenter];
        
    [pin setAnimatesDrop: YES];
    [pin setCanShowCallout: YES];
    [pin setRightCalloutAccessoryView: infoButton];
    
    return pin;
}

- (void) mapView: (MKMapView *) mapView annotationView: (MKAnnotationView *) view calloutAccessoryControlTapped: (UIControl *) control
{
    NSLog(@"calloutAccessoryControlTapped");
    
    Service *service;
    
    for (NSUInteger index = 0; index < [self.serviceAnnotations count]; index++)
    {
        if ([[self.serviceAnnotations objectAtIndex: index] isEqual: view.annotation])
        {
            NSLog(@"found it at index: %ld", (unsigned long)index);
            service = [[[Services sharedServices] allServices] objectAtIndex: index];
            break;
        }
    }
    
    NSLog(@"Service name: %@", [service name]);
    ServiceInfoViewController *serviceInformationViewController = [[ServiceInfoViewController alloc] initWithService: service];
    [serviceInformationViewController setTransitioningDelegate: self];
    [serviceInformationViewController setModalPresentationStyle: UIModalPresentationCustom];
    
    [self.navigationController presentViewController: serviceInformationViewController animated: YES completion: nil];
}

-(void) mapView: (MKMapView *) mapView didAddAnnotationViews: (NSArray *) views
{
    MKAnnotationView *userLocationAnnotation = [mapView viewForAnnotation: mapView.userLocation];
    [userLocationAnnotation setTintColor: [UIColor colorWithRed: 0.0f/255.0f green: 172.0f/255.0f blue: 99.0f/255.0f alpha: 1.0f]];
    [userLocationAnnotation setEnabled: NO];
}

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
    
    if ([overlay isKindOfClass: [MKCircle class]])
    {
        MKCircleRenderer *renderer = [[MKCircleRenderer alloc] initWithCircle: overlay];
        [renderer setFillColor: [UIColor colorWithRed: 14.0f/255.0f green: 169.0f/255.0f blue: 233.0f/255.0f alpha: 0.3f]];
        [renderer setStrokeColor: [UIColor colorWithRed: 14.0f/255.0f green: 169.0f/255.0f blue: 233.0f/255.0f alpha: 0.6f]];
        [renderer setLineWidth: 2.0f];
        return renderer;
    }
    
    return nil;
}

- (void) mapView: (MKMapView *) mapView didSelectAnnotationView: (MKAnnotationView *) view
{
    if ([[view annotation] isEqual: [mapView userLocation]])
        return;
}

- (void) mapView: (MKMapView *) mapView didDeselectAnnotationView: (MKAnnotationView *) view
{
    if ([[view annotation] isEqual: [mapView userLocation]])
        return;
}

#pragma mark - Notification Methods

- (void) showPointsOfInterest
{
    if (![self showingServiceAnnotations])
    {
        [self.mapView addOverlays: [self serviceOverlays]];
        [self.mapView addAnnotations: [self serviceAnnotations]];
        [self.mapView removeAnnotations: [self serviceAnnotationsNoRooms]];
        [self setShowingServiceAnnotations: YES];
        NSLog(@"Showing Points Of Interest");
    }
}

- (void) showCiteCampus
{
    // Zoom into the campus at La Cite
    CLLocationCoordinate2D campusCoordinates;
    campusCoordinates.latitude = 45.439953;
    campusCoordinates.longitude = -75.626851;
    
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(campusCoordinates, 800, 800);
    
    [self.mapView setRegion: viewRegion animated: NO];
}

- (void) changeMapType
{
    if (self.mapView.mapType == MKMapTypeStandard)
        [self.mapView setMapType: MKMapTypeSatellite];
    else [self.mapView setMapType: MKMapTypeStandard];
}

- (void) trackUserLocation
{
    // Already tracking the user location, turn it off
    if ([self isTrackingUserLocation])
    {
        [self setTrackingUserLocation: NO];
        [self.mapView setUserTrackingMode: MKUserTrackingModeNone animated: YES];
        [[NSNotificationCenter defaultCenter] postNotificationName: kUserLocationTrackingStateChanged
                                                            object: @([self isTrackingUserLocation])];
        return;
    }
    
    // Check if the user has a location
    CLLocationCoordinate2D noLocation;
    noLocation.latitude = 0.000000;
    noLocation.longitude = 0.000000;
    
    if (self.mapView.userLocation.coordinate.latitude == 0.000000 && self.mapView.userLocation.coordinate.longitude == 0.000000)
    {
        NSLog(@"Cannot Determine Location");
        
        [self.mapView setUserTrackingMode: MKUserTrackingModeNone animated: YES];
        [self setTrackingUserLocation: NO];
        
        [[NSNotificationCenter defaultCenter] postNotificationName: kUserLocationTrackingStateChanged
                                                            object: @([self isTrackingUserLocation])];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"No Location", nil)
                                                        message: @""
                                                       delegate: self
                                              cancelButtonTitle: NSLocalizedString(@"Alert Cancel Button", nil)
                                              otherButtonTitles: nil];
        [alert setTintColor: [UIColor colorWithRed: 0.0f/255.0f green: 172.0f/255.0f blue: 99.0f/255.0f alpha: 0.6f]];
        [alert show];
        
        return;
    }
    
    // Check if the user is on campus
    CLLocationCoordinate2D campusCoordinates;
    campusCoordinates.latitude = 45.439953;
    campusCoordinates.longitude = -75.626851;
    
    CLLocation *campusLocation = [[CLLocation alloc] initWithLatitude: campusCoordinates.latitude longitude: campusCoordinates.longitude];
    
    if ([[self.mapView.userLocation location] distanceFromLocation: campusLocation] > 800)
    {
        NSLog(@"not on campus");

        [self.mapView setUserTrackingMode: MKUserTrackingModeNone animated: YES];
        [self setTrackingUserLocation: NO];
        
        [[NSNotificationCenter defaultCenter] postNotificationName: kUserLocationTrackingStateChanged
                                                            object: @([self isTrackingUserLocation])];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @""
                                                        message: NSLocalizedString(@"Tracking Location Message", nil)
                                                       delegate: self
                                              cancelButtonTitle: NSLocalizedString(@"Alert Cancel Button", nil)
                                              otherButtonTitles: nil];
        [alert setTintColor: [UIColor colorWithRed: 0.0f/255.0f green: 172.0f/255.0f blue: 99.0f/255.0f alpha: 0.6f]];
        [alert show];
    }
    else
    {
        [self.mapView setUserTrackingMode: MKUserTrackingModeFollowWithHeading animated: YES];

        [self setTrackingUserLocation: YES];
        
        [[NSNotificationCenter defaultCenter] postNotificationName: kUserLocationTrackingStateChanged
                                                            object: @([self isTrackingUserLocation])];
        
        [self.mapView setCenterCoordinate: self.mapView.userLocation.coordinate animated: YES];
    }
    
    NSLog(@"userlocation: %f, %f", self.mapView.userLocation.coordinate.latitude, self.mapView.userLocation.coordinate.longitude);
    
    /*
    // Zoom into the user's location
    CLLocationCoordinate2D zoomLocation;
    zoomLocation.latitude = self.mapView.userLocation.coordinate.latitude;
    zoomLocation.longitude = self.mapView.userLocation.coordinate.longitude;
    
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, 800, 800);
     
    [self.mapView setRegion: viewRegion animated: YES];
     */
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver: self forKeyPath: kShowPointsOfInterestNotification];
    [[NSNotificationCenter defaultCenter] removeObserver: self forKeyPath: kChangeMapTypeNotification];
    [[NSNotificationCenter defaultCenter] removeObserver: self forKeyPath: kMapViewMainCampusRegionNotification];
    [[NSNotificationCenter defaultCenter] removeObserver: self forKeyPath: kUserWantsLocationTrackingNotification];
}

@end
