//
//  MainViewController.m
//  ServiCite
//
//  Created by Mathieu White on 2014-10-28.
//  Copyright (c) 2014 Mathieu White. All rights reserved.
//

#import "MainViewController.h"
#import "FrontViewController.h"
#import "BehindViewController.h"
#import "POP.h"

#define FRONT_TAG 1
#define BEHIND_TAG 2

@interface MainViewController () <FrontViewControllerDelegate>

@property (nonatomic, weak) UITapGestureRecognizer *tapGestureRecognizer;

@property (nonatomic, strong) FrontViewController *frontViewController;
@property (nonatomic, strong) BehindViewController *behindViewController;

@property (nonatomic, strong) NSLayoutConstraint *frontViewTopConstraints;

@property (nonatomic, assign) BOOL showingViewBehind;

@end

@implementation MainViewController

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationController setNavigationBarHidden: YES];
    
    // Set the background color
    [self.view setBackgroundColor: [UIColor blackColor]];
    
    [self setupMainViewController];
    
    // Notification for when the user wants to bring up the front view
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(moveFrontViewToOriginalPosition)
                                                 name: kUserWantsFrontViewNotification
                                               object: nil];
    
    // Notification for when the user wants to reveal the view behind
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(moveFrontViewToBottom)
                                                 name: kUserWantsViewBehindNotification
                                               object: nil];
    
    // Notification for when the user selects the points of interest menu item
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(userWantsPointsOfInterest)
                                                 name: kUserWantsPointsOfInterestNotification
                                               object: nil];
    
    // Notification for when the user selects the campus menu item
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(userWantsMainCampusRegion)
                                                 name: kUserWantsMainCampusNotification
                                               object: nil];
    
    // Notification for when the user selects the satellite menu item
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(userWantsSatelliteMapType)
                                                 name: kUserWantsMapTypeChangeNotification
                                               object: nil];
}

- (void) setupMainViewController
{
    FrontViewController *frontViewController = [[FrontViewController alloc] init];
    [frontViewController.view setTag: FRONT_TAG];
    [frontViewController setDelegate: self];
    
    [self.view addSubview: frontViewController.view];
    [self setFrontViewController: frontViewController];

    [self addChildViewController: self.frontViewController];
    [self.frontViewController didMoveToParentViewController: self];
    
    [self.frontViewController.view setTranslatesAutoresizingMaskIntoConstraints: NO];
    [self setupConstraints];
    [self setupGestures];
}

- (void) resetMainView
{
    // Remove behind view
    if (self.behindViewController)
    {
        [self.behindViewController.view removeFromSuperview];
        self.behindViewController = nil;
        [self setShowingViewBehind: NO];
    }
    
    NSLog(@"Behind view: %@", self.behindViewController);
    
    // Remove front view shadows
    [self showFrontViewWithShadow: NO xOffset: 0.0f yOffset: 0.0f];
}

- (UIView *) getViewBehind
{
    // Init if it doesn't already exist
    if (self.behindViewController == nil)
    {
        BehindViewController *behindViewController = [[BehindViewController alloc] init];
        [behindViewController.view setTag: BEHIND_TAG];
        [behindViewController.view setTranslatesAutoresizingMaskIntoConstraints: NO];
        
        [self.view addSubview: behindViewController.view];
        [self setBehindViewController: behindViewController];

        [self addChildViewController: self.behindViewController];
        [self.behindViewController didMoveToParentViewController: self];
    }
    
    [self setShowingViewBehind: YES];
    
    // Add shadow to the front view
    [self showFrontViewWithShadow: YES xOffset: 0.0f yOffset: -2.0f];
    
    return [self.behindViewController view];
}

- (void) showFrontViewWithShadow: (BOOL) shadow xOffset: (CGFloat) xOffset yOffset: (CGFloat) yOffset
{
    if (shadow)
    {
        [self.frontViewController.view.layer setShadowColor: [UIColor blackColor].CGColor];
        [self.frontViewController.view.layer setShadowOpacity: 0.3f];
        [self.frontViewController.view.layer setShadowOffset: CGSizeMake(xOffset, yOffset)];
    }
    else
    {
        [self.frontViewController.view.layer setShadowOffset: CGSizeMake(xOffset, yOffset)];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIGestureRecognizer Methods

- (void) setupGestures
{
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(touchFrontView)];
    [tapGestureRecognizer setEnabled: NO];
    
    [self.frontViewController.view addGestureRecognizer: tapGestureRecognizer];
    [self setTapGestureRecognizer: tapGestureRecognizer];
}

- (void) touchFrontView
{
    [[NSNotificationCenter defaultCenter] postNotificationName: kUserTappedFrontViewNotification object: nil];
    [self moveFrontViewToOriginalPosition];
}

#pragma mark - FrontViewControllerDelegate Methods

- (void) moveFrontViewToOriginalPosition
{
    NSLog(@"moveFrontViewToOriginalPosition");
    [self.tapGestureRecognizer setEnabled: NO];
    
    // The front view animation
    POPSpringAnimation *frontViewAnimation = [POPSpringAnimation animationWithPropertyNamed: kPOPLayerPositionY];
    [frontViewAnimation setToValue: @(CGRectGetHeight(self.view.bounds) - CGRectGetMidY(self.frontViewController.view.bounds))];
    [frontViewAnimation setSpringBounciness: 0.0f];
    
    [frontViewAnimation setCompletionBlock: ^(POPAnimation *anim, BOOL finished){
        NSLog(@"Animation has completed.");
        NSLog(@"FrontView Y: %f", CGRectGetMinY(self.frontViewController.view.frame));
        [self setShowingViewBehind: NO];
        [self updateViewConstraints];
        //[self resetMainView];
    }];
    
    // The view behind animation
    POPSpringAnimation *behindViewAnimation = [POPSpringAnimation animationWithPropertyNamed: kPOPLayerScaleXY];
    [behindViewAnimation setToValue: [NSValue valueWithCGSize: CGSizeMake(0.9f, 0.9f)]];
    [behindViewAnimation setSpringBounciness: 0.0f];
    
    // The view behind fade animation
    POPBasicAnimation *fadeAnimation = [POPBasicAnimation animationWithPropertyNamed: kPOPLayerOpacity];
    [fadeAnimation setFromValue: @(1.0)];
    [fadeAnimation setToValue: @(0.6)];
    
    [self.frontViewController.view.layer pop_addAnimation: frontViewAnimation forKey: @"frontOrigintalPositionSpringAnimation"];
    [self.behindViewController.view.layer pop_addAnimation: behindViewAnimation forKey: @"behindScaleDownSpringAnimation"];
    [self.behindViewController.view.layer pop_addAnimation: fadeAnimation forKey: @"fadeInBasicAnimation"];
}

- (void) moveFrontViewToBottom
{
    NSLog(@"moveFrontViewToBottom");
    [self.tapGestureRecognizer setEnabled: YES];

    UIView *childView = [self getViewBehind];
    [self.view sendSubviewToBack: childView];
    [self setupConstraintsForBehindView];
    
    // The front view animation
    POPSpringAnimation *frontViewAnimation = [POPSpringAnimation animationWithPropertyNamed: kPOPLayerPositionY];
    [frontViewAnimation setToValue: @(CGRectGetHeight(self.view.bounds) + CGRectGetMidY(self.frontViewController.view.bounds) - 64)];
    [frontViewAnimation setSpringBounciness: 4.0f];
    
    [frontViewAnimation setCompletionBlock: ^(POPAnimation *anim, BOOL finished){
        NSLog(@"Animation has completed.");
        NSLog(@"FrontView Y: %f", CGRectGetMinY(self.frontViewController.view.frame));
        [self updateViewConstraints];
    }];
    
    // The view behind animation
    POPSpringAnimation *behindViewAnimation = [POPSpringAnimation animationWithPropertyNamed: kPOPLayerScaleXY];
    [behindViewAnimation setFromValue: [NSValue valueWithCGSize: CGSizeMake(0.9f, 0.9f)]];
    [behindViewAnimation setToValue: [NSValue valueWithCGSize: CGSizeMake(1.0f, 1.0f)]];
    [behindViewAnimation setSpringBounciness: 0.0f];
    
    // The view behind fade animation
    POPBasicAnimation *fadeAnimation = [POPBasicAnimation animationWithPropertyNamed: kPOPLayerOpacity];
    [fadeAnimation setFromValue: @(0.6)];
    [fadeAnimation setToValue: @(1.0)];
    
    [self.frontViewController.view.layer pop_addAnimation: frontViewAnimation forKey: @"frontBottomPositionSpringAnimation"];
    [self.behindViewController.view.layer pop_addAnimation: behindViewAnimation forKey: @"behindScaleUpSpringAnimation"];
    [self.behindViewController.view.layer pop_addAnimation: fadeAnimation forKey: @"fadeInBasicAnimation"];
}

#pragma mark - Auto Layout Methods

- (void) setupConstraints
{
    // Front View Width
    [self.view addConstraint: [NSLayoutConstraint constraintWithItem: self.frontViewController.view
                                                           attribute: NSLayoutAttributeWidth
                                                           relatedBy: NSLayoutRelationEqual
                                                              toItem: self.view
                                                           attribute: NSLayoutAttributeWidth
                                                          multiplier: 1.0f
                                                            constant: 0.0f]];
    
    // Front View Height
    [self.view addConstraint: [NSLayoutConstraint constraintWithItem: self.frontViewController.view
                                                           attribute: NSLayoutAttributeHeight
                                                           relatedBy: NSLayoutRelationEqual
                                                              toItem: self.view
                                                           attribute: NSLayoutAttributeHeight
                                                          multiplier: 1.0f
                                                            constant: 0.0f]];
    
    // Front View Top
    NSLayoutConstraint *frontViewTopConstraint = [NSLayoutConstraint constraintWithItem: self.frontViewController.view
                                                                              attribute: NSLayoutAttributeTop
                                                                              relatedBy: NSLayoutRelationEqual
                                                                                 toItem: self.view
                                                                              attribute: NSLayoutAttributeTop
                                                                             multiplier: 1.0f
                                                                               constant: 0.0f];
    [self.view addConstraint: frontViewTopConstraint];
    [self setFrontViewTopConstraints: frontViewTopConstraint];
    
    // Front View Left
    [self.view addConstraint: [NSLayoutConstraint constraintWithItem: self.frontViewController.view
                                                           attribute: NSLayoutAttributeLeft
                                                           relatedBy: NSLayoutRelationEqual
                                                              toItem: self.view
                                                           attribute: NSLayoutAttributeLeft
                                                          multiplier: 1.0f
                                                            constant: 0.0f]];
}

- (void) setupConstraintsForBehindView
{
    // Behind View Width
    [self.view addConstraint: [NSLayoutConstraint constraintWithItem: self.behindViewController.view
                                                           attribute: NSLayoutAttributeWidth
                                                           relatedBy: NSLayoutRelationEqual
                                                              toItem: self.view
                                                           attribute: NSLayoutAttributeWidth
                                                          multiplier: 1.0f
                                                            constant: 0.0f]];
    
    // Behind View Height
    [self.view addConstraint: [NSLayoutConstraint constraintWithItem: self.behindViewController.view
                                                           attribute: NSLayoutAttributeHeight
                                                           relatedBy: NSLayoutRelationEqual
                                                              toItem: self.view
                                                           attribute: NSLayoutAttributeHeight
                                                          multiplier: 1.0f
                                                            constant: 0.0f]];
    
    // Behind View Center X
    [self.view addConstraint: [NSLayoutConstraint constraintWithItem: self.behindViewController.view
                                                           attribute: NSLayoutAttributeCenterX
                                                           relatedBy: NSLayoutRelationEqual
                                                              toItem: self.view
                                                           attribute: NSLayoutAttributeCenterX
                                                          multiplier: 1.0f
                                                            constant: 0.0f]];
    
    // Behind View Center Y
    [self.view addConstraint: [NSLayoutConstraint constraintWithItem: self.behindViewController.view
                                                           attribute: NSLayoutAttributeCenterY
                                                           relatedBy: NSLayoutRelationEqual
                                                              toItem: self.view
                                                           attribute: NSLayoutAttributeCenterY
                                                          multiplier: 1.0f
                                                            constant: 0.0f]];
}

- (void) updateViewConstraints
{
    if ([self showingViewBehind])
    {
        [self.view removeConstraint: self.frontViewTopConstraints];
        NSLayoutConstraint *frontViewTopConstraint = [NSLayoutConstraint constraintWithItem: self.frontViewController.view
                                                                                  attribute: NSLayoutAttributeTop
                                                                                  relatedBy: NSLayoutRelationEqual
                                                                                     toItem: self.view
                                                                                  attribute: NSLayoutAttributeBottom
                                                                                 multiplier: 1.0f
                                                                                   constant: -64.0f];
        [self.view addConstraint: frontViewTopConstraint];
        [self setFrontViewTopConstraints: frontViewTopConstraint];
    }
    else
    {
        [self.view removeConstraint: self.frontViewTopConstraints];
        NSLayoutConstraint *frontViewTopConstraint = [NSLayoutConstraint constraintWithItem: self.frontViewController.view
                                                                                  attribute: NSLayoutAttributeTop
                                                                                  relatedBy: NSLayoutRelationEqual
                                                                                     toItem: self.view
                                                                                  attribute: NSLayoutAttributeTop
                                                                                 multiplier: 1.0f
                                                                                   constant: 0.0f];
        [self.view addConstraint: frontViewTopConstraint];
        [self setFrontViewTopConstraints: frontViewTopConstraint];
    }
    
    
    [super updateViewConstraints];
}

#pragma mark - Notification Methods

- (void) userWantsPointsOfInterest
{
    NSLog(@"userWantsPointsOfInterest");
    
    // The front view animation
    POPSpringAnimation *frontViewAnimation = [POPSpringAnimation animationWithPropertyNamed: kPOPLayerPositionY];
    [frontViewAnimation setToValue: @(CGRectGetHeight(self.view.bounds) + CGRectGetMidY(self.frontViewController.view.bounds) + 32)];
    [frontViewAnimation setSpringBounciness: 4.0f];
    
    [frontViewAnimation setCompletionBlock: ^(POPAnimation *anim, BOOL finished){
        [[NSNotificationCenter defaultCenter] postNotificationName: kShowPointsOfInterestNotification object: nil];
        [self touchFrontView];
    }];
    
    [self.frontViewController.view.layer pop_addAnimation: frontViewAnimation forKey: @"frontOrigintalPositionSpringAnimation"];
}

- (void) userWantsMainCampusRegion
{
    NSLog(@"userWantsMainCampusRegion");
    
    // The front view animation
    POPSpringAnimation *frontViewAnimation = [POPSpringAnimation animationWithPropertyNamed: kPOPLayerPositionY];
    [frontViewAnimation setToValue: @(CGRectGetHeight(self.view.bounds) + CGRectGetMidY(self.frontViewController.view.bounds) + 32)];
    [frontViewAnimation setSpringBounciness: 4.0f];
    
    [frontViewAnimation setCompletionBlock: ^(POPAnimation *anim, BOOL finished){
        [[NSNotificationCenter defaultCenter] postNotificationName: kMapViewMainCampusRegionNotification object: nil];
        [self touchFrontView];
    }];
    
    [self.frontViewController.view.layer pop_addAnimation: frontViewAnimation forKey: @"frontOrigintalPositionSpringAnimation"];
}

- (void) userWantsSatelliteMapType
{
    NSLog(@"userWantsSatelliteMapType");
    
    // The front view animation
    POPSpringAnimation *frontViewAnimation = [POPSpringAnimation animationWithPropertyNamed: kPOPLayerPositionY];
    [frontViewAnimation setToValue: @(CGRectGetHeight(self.view.bounds) + CGRectGetMidY(self.frontViewController.view.bounds) + 32)];
    [frontViewAnimation setSpringBounciness: 4.0f];
    
    [frontViewAnimation setCompletionBlock: ^(POPAnimation *anim, BOOL finished){
        [[NSNotificationCenter defaultCenter] postNotificationName: kChangeMapTypeNotification object: nil];
        [self touchFrontView];
        [[NSNotificationCenter defaultCenter] postNotificationName: kMapTypeChangedNotification object: nil];
    }];
    
    [self.frontViewController.view.layer pop_addAnimation: frontViewAnimation forKey: @"frontOrigintalPositionSpringAnimation"];
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver: self forKeyPath: kUserWantsFrontViewNotification];
    [[NSNotificationCenter defaultCenter] removeObserver: self forKeyPath: kUserWantsViewBehindNotification];
    [[NSNotificationCenter defaultCenter] removeObserver: self forKeyPath: kUserWantsPointsOfInterestNotification];
    [[NSNotificationCenter defaultCenter] removeObserver: self forKeyPath: kUserWantsMainCampusNotification];
    [[NSNotificationCenter defaultCenter] removeObserver: self forKeyPath: kUserWantsMapTypeChangeNotification];
}

@end
