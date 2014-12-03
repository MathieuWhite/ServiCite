//
//  ActionBar.m
//  ServiCite
//
//  Created by Mathieu White on 2014-10-28.
//  Copyright (c) 2014 Mathieu White. All rights reserved.
//

#import "ActionBar.h"
#import "ActionButton.h"

@interface ActionBar()

@property (nonatomic, weak) ActionButton *menuButton;
@property (nonatomic, weak) ActionButton *trackLocationButton;

@property (nonatomic, assign) BOOL viewingViewBehind;

@end

@implementation ActionBar

#pragma mark - Initialization

+ (ActionBar *) sharedActionBar
{
    static ActionBar *_sharedActionBar;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _sharedActionBar = [[self alloc] init];
    });
    
    return _sharedActionBar;
}

- (id) init
{
    self = [super init];
    
    if (self)
    {
        [self initActionBar];
    }
    
    return self;
}

- (void) initActionBar
{
    // Set the background image
    [self setBackgroundColor: [UIColor colorWithPatternImage: [UIImage imageNamed: @"actionBarOverlay"]]];
    
    // Create the toggle button
    ActionButton *menuButton = [ActionButton button];
    [menuButton setBackgroundColor: [UIColor clearColor]];
    [menuButton setBackgroundImage: [UIImage imageNamed: @"menuButton"] forState: UIControlStateNormal];
    [menuButton setBackgroundImage: [UIImage imageNamed: @"menuButton"] forState: UIControlStateHighlighted];
    [menuButton addTarget: self action: @selector(touchUpMenuButton) forControlEvents: UIControlEventTouchUpInside];
    
    // Create the track location button
    ActionButton *trackLocationButton = [ActionButton button];
    [trackLocationButton setBackgroundColor: [UIColor clearColor]];
    [trackLocationButton setBackgroundImage: [UIImage imageNamed: @"locationInactiveButton"] forState: UIControlStateNormal];
    [trackLocationButton setBackgroundImage: [UIImage imageNamed: @"locationInactiveButton"] forState: UIControlStateHighlighted];
    [trackLocationButton addTarget: self action: @selector(touchUpTrackLocationButton) forControlEvents: UIControlEventTouchUpInside];
    
    // Add the components to the view
    [self addSubview: menuButton];
    [self addSubview: trackLocationButton];
    
    // Set each component to a property
    [self setMenuButton: menuButton];
    [self setTrackLocationButton: trackLocationButton];
    
    // Auto Layout
    [self setTranslatesAutoresizingMaskIntoConstraints: NO];
    [self setupConstraints];
    
    // Notification for when the user hides the view behind with the gesture recognizer
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(enableButtons)
                                                 name: kUserTappedFrontViewNotification
                                               object: nil];
    
    // Notification for when the user location tracking is on
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(changeLocationTrackingButton:)
                                                 name: kUserLocationTrackingStateChanged
                                               object: nil];
}

#pragma mark - Button Methods

- (void) touchUpMenuButton
{
    if ([self viewingViewBehind])
    {
        [self.trackLocationButton setEnabled: YES];
        [[NSNotificationCenter defaultCenter] postNotificationName: kUserWantsFrontViewNotification object: nil];
        [self setViewingViewBehind: !self.viewingViewBehind];
    }
    else
    {
        [self.trackLocationButton setEnabled: NO];
        [[NSNotificationCenter defaultCenter] postNotificationName: kUserWantsViewBehindNotification object: nil];
        [self setViewingViewBehind: !self.viewingViewBehind];
    }
}

- (void) touchUpTrackLocationButton
{
    [[NSNotificationCenter defaultCenter] postNotificationName: kUserWantsLocationTrackingNotification object: nil];
}

#pragma mark - Auto Layout Method

- (void) setupConstraints
{
    // Menu Button Width
    [self addConstraint: [NSLayoutConstraint constraintWithItem: self.menuButton
                                                      attribute: NSLayoutAttributeWidth
                                                      relatedBy: NSLayoutRelationEqual
                                                         toItem: self
                                                      attribute: NSLayoutAttributeWidth
                                                     multiplier: 0.0f
                                                       constant: 44.0f]];
    
    // Menu Button Height
    [self addConstraint: [NSLayoutConstraint constraintWithItem: self.menuButton
                                                      attribute: NSLayoutAttributeHeight
                                                      relatedBy: NSLayoutRelationEqual
                                                         toItem: self
                                                      attribute: NSLayoutAttributeHeight
                                                     multiplier: 0.0f
                                                       constant: 44.0f]];
    
    // Menu Button Top
    [self addConstraint: [NSLayoutConstraint constraintWithItem: self.menuButton
                                                      attribute: NSLayoutAttributeTop
                                                      relatedBy: NSLayoutRelationEqual
                                                         toItem: self
                                                      attribute: NSLayoutAttributeTop
                                                     multiplier: 1.0f
                                                       constant: 10.0f]];
    
    // Menu Button Right
    [self addConstraint: [NSLayoutConstraint constraintWithItem: self.menuButton
                                                      attribute: NSLayoutAttributeRight
                                                      relatedBy: NSLayoutRelationEqual
                                                         toItem: self
                                                      attribute: NSLayoutAttributeRight
                                                     multiplier: 1.0f
                                                       constant: -10.0f]];
    
    // Track Location Button Width
    [self addConstraint: [NSLayoutConstraint constraintWithItem: self.trackLocationButton
                                                      attribute: NSLayoutAttributeWidth
                                                      relatedBy: NSLayoutRelationEqual
                                                         toItem: self
                                                      attribute: NSLayoutAttributeWidth
                                                     multiplier: 0.0f
                                                       constant: 44.0f]];
    
    // Track Location Button Height
    [self addConstraint: [NSLayoutConstraint constraintWithItem: self.trackLocationButton
                                                      attribute: NSLayoutAttributeHeight
                                                      relatedBy: NSLayoutRelationEqual
                                                         toItem: self
                                                      attribute: NSLayoutAttributeHeight
                                                     multiplier: 0.0f
                                                       constant: 44.0f]];
    
    // Track Location Button Top
    [self addConstraint: [NSLayoutConstraint constraintWithItem: self.trackLocationButton
                                                      attribute: NSLayoutAttributeTop
                                                      relatedBy: NSLayoutRelationEqual
                                                         toItem: self
                                                      attribute: NSLayoutAttributeTop
                                                     multiplier: 1.0f
                                                       constant: 10.0f]];
    
    // Track Location Button Right
    [self addConstraint: [NSLayoutConstraint constraintWithItem: self.trackLocationButton
                                                      attribute: NSLayoutAttributeRight
                                                      relatedBy: NSLayoutRelationEqual
                                                         toItem: self.menuButton
                                                      attribute: NSLayoutAttributeLeft
                                                     multiplier: 1.0f
                                                       constant: -5.0f]];
}

#pragma mark - Notification Methods

- (void) enableButtons
{
    [self.trackLocationButton setEnabled: YES];
    [self setViewingViewBehind: NO];
}

- (void) changeLocationTrackingButton: (NSNotification *) notification
{
    BOOL locationTracking = [[notification object] boolValue];
    
    if (locationTracking)
    {
        [self.trackLocationButton setBackgroundImage: [UIImage imageNamed: @"locationActiveButton"] forState: UIControlStateNormal];
        [self.trackLocationButton setBackgroundImage: [UIImage imageNamed: @"locationActiveButton"] forState: UIControlStateHighlighted];
    }
    else
    {
        [self.trackLocationButton setBackgroundImage: [UIImage imageNamed: @"locationInactiveButton"] forState: UIControlStateNormal];
        [self.trackLocationButton setBackgroundImage: [UIImage imageNamed: @"locationInactiveButton"] forState: UIControlStateHighlighted];
    }
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver: self forKeyPath: kUserTappedFrontViewNotification];
    [[NSNotificationCenter defaultCenter] removeObserver: self forKeyPath: kUserLocationTrackingStateChanged];
}

@end
