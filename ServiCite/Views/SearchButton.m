//
//  SearchButton.m
//  ServiCite
//
//  Created by Mathieu White on 2014-10-27.
//  Copyright (c) 2014 Mathieu White. All rights reserved.
//

#import "SearchButton.h"
#import "POP.h"

@interface SearchButton()

@property (nonatomic) CALayer *topLayer;
@property (nonatomic) CALayer *middleLayer;
@property (nonatomic) CALayer *bottomLayer;

@property (nonatomic) BOOL showMenu;

@end

@implementation SearchButton

#pragma mark - Initialization

+ (instancetype) button
{
    return [[self alloc] initWithFrame: CGRectMake(0, 0, 24, 17)];
}

- (id) initWithFrame: (CGRect) frame
{
    self = [super initWithFrame: frame];
    
    if (self)
    {
        [self initSearchButton];
    }
    
    return self;
}

- (void) initSearchButton
{
    // Top Line
    CALayer *topLayer = [CALayer layer];
    [topLayer setFrame: CGRectMake(0, CGRectGetMinY(self.bounds), CGRectGetWidth(self.bounds), 2.0f)];
    [topLayer setCornerRadius: 1.0f];
    [topLayer setBackgroundColor: [self.tintColor CGColor]];
    
    // Middle Line
    CALayer *middleLayer = [CALayer layer];
    [middleLayer setFrame: CGRectMake(0, CGRectGetMidY(self.bounds) - 1.0f, CGRectGetWidth(self.bounds), 2.0f)];
    [middleLayer setCornerRadius: 1.0f];
    [middleLayer setBackgroundColor: [self.tintColor CGColor]];
    
    // Bottom Line
    CALayer *bottomLayer = [CALayer layer];
    [bottomLayer setFrame: CGRectMake(0, CGRectGetMaxY(self.bounds) - 2.0f, CGRectGetWidth(self.bounds), 2.0f)];
    [bottomLayer setCornerRadius: 1.0f];
    [bottomLayer setBackgroundColor: [self.tintColor CGColor]];
    
    [self.layer addSublayer: topLayer];
    [self.layer addSublayer: middleLayer];
    [self.layer addSublayer: bottomLayer];
    [self setTranslatesAutoresizingMaskIntoConstraints: NO];
    [self addTarget: self action: @selector(touchUpInsideHandler:) forControlEvents: UIControlEventTouchUpInside];
    
    [self setTopLayer: topLayer];
    [self setMiddleLayer: middleLayer];
    [self setBottomLayer: bottomLayer];
    
    // Notification for when the user whants to open search
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(userOpenedSearch)
                                                 name: kUserStartedEditingSearchFieldNotification
                                               object: nil];
}

#pragma mark - Instance Methods

- (void) tintColorDidChange
{
    [self.topLayer setBackgroundColor: [self.tintColor CGColor]];
    [self.middleLayer setBackgroundColor: [self.tintColor CGColor]];
    [self.bottomLayer setBackgroundColor: [self.tintColor CGColor]];
}

#pragma mark - Animation Methods

- (void) animateToListButton
{
    [self removeAllAnimations];
    
    CGFloat height = CGRectGetHeight(self.topLayer.bounds);
    
    POPBasicAnimation *fadeAnimation = [POPBasicAnimation animationWithPropertyNamed: kPOPLayerOpacity];
    [fadeAnimation setToValue: @(1.0)];
    [fadeAnimation setDuration: 0.4];
    
    POPBasicAnimation *positionTopAnimation = [POPBasicAnimation animationWithPropertyNamed: kPOPLayerPosition];
    [positionTopAnimation setToValue: [NSValue valueWithCGPoint: CGPointMake(CGRectGetMidX(self.bounds),
                                                                             roundf(CGRectGetMinY(self.bounds)+(height/2)))]];
    [positionTopAnimation setDuration: 0.4];
    
    POPBasicAnimation *positionBottomAnimation = [POPBasicAnimation animationWithPropertyNamed: kPOPLayerPosition];
    [positionBottomAnimation setToValue: [NSValue valueWithCGPoint: CGPointMake(CGRectGetMidX(self.bounds),
                                                                                roundf(CGRectGetMaxY(self.bounds)-(height/2)))]];
    [positionBottomAnimation setDuration: 0.4];
    
    POPSpringAnimation *rotateTopAnimation = [POPSpringAnimation animationWithPropertyNamed: kPOPLayerRotation];
    [rotateTopAnimation setToValue: @(0.0)];
    [rotateTopAnimation setSpringBounciness: 20.0f];
    [rotateTopAnimation setSpringSpeed: 20.0f];
    [rotateTopAnimation setDynamicsTension: 1000.0f];
    
    POPSpringAnimation *rotateBottomAnimation = [POPSpringAnimation animationWithPropertyNamed: kPOPLayerRotation];
    [rotateBottomAnimation setToValue: @(0.0)];
    [rotateBottomAnimation setSpringBounciness: 20.0f];
    [rotateBottomAnimation setSpringSpeed: 20.0f];
    [rotateBottomAnimation setDynamicsTension: 1000.0f];
    
    [self.topLayer pop_addAnimation: positionTopAnimation forKey:@"positionTopSpringAnimation"];
    [self.topLayer pop_addAnimation: rotateTopAnimation forKey:@"rotateTopSpringAnimation"];
    [self.middleLayer pop_addAnimation: fadeAnimation forKey: @"fadeBasicAnimation"];
    [self.bottomLayer pop_addAnimation: positionBottomAnimation forKey: @"positionBottomSpringAnimation"];
    [self.bottomLayer pop_addAnimation: rotateBottomAnimation forKey: @"rotateBottomSpringAnimation"];
}

- (void) animateToCloseButton
{
    [self removeAllAnimations];
    
    CGPoint center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    
    POPBasicAnimation *fadeAnimation = [POPBasicAnimation animationWithPropertyNamed: kPOPLayerOpacity];
    [fadeAnimation setToValue: @(0.0)];
    [fadeAnimation setDuration: 0.4];
    
    POPBasicAnimation *positionTopAnimation = [POPBasicAnimation animationWithPropertyNamed: kPOPLayerPosition];
    [positionTopAnimation setToValue: [NSValue valueWithCGPoint: center]];
    [positionTopAnimation setDuration: 0.4];
    
    POPBasicAnimation *positionBottomAnimation = [POPBasicAnimation animationWithPropertyNamed: kPOPLayerPosition];
    [positionBottomAnimation setToValue: [NSValue valueWithCGPoint: center]];
    [positionBottomAnimation setDuration: 0.4];
    
    POPSpringAnimation *rotateTopAnimation = [POPSpringAnimation animationWithPropertyNamed: kPOPLayerRotation];
    [rotateTopAnimation setToValue: @(M_PI_4)];
    [rotateTopAnimation setSpringBounciness: 20.0f];
    [rotateTopAnimation setSpringSpeed: 20.0f];
    [rotateTopAnimation setDynamicsTension: 1000.0f];
    
    POPSpringAnimation *rotateBottomAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerRotation];
    [rotateBottomAnimation setToValue: @(-M_PI_4)];
    [rotateBottomAnimation setSpringBounciness: 20.0f];
    [rotateBottomAnimation setSpringSpeed: 20.0f];
    [rotateBottomAnimation setDynamicsTension: 1000.0f];
    
    [self.topLayer pop_addAnimation: positionTopAnimation forKey: @"positionTopSpringAnimation"];
    [self.topLayer pop_addAnimation: rotateTopAnimation forKey: @"rotateTopSpringAnimation"];
    [self.middleLayer pop_addAnimation: fadeAnimation forKey: @"fadeMiddleBasicAnimation"];
    [self.bottomLayer pop_addAnimation: positionBottomAnimation forKey: @"positionBottomSpringAnimation"];
    [self.bottomLayer pop_addAnimation: rotateBottomAnimation forKey: @"rotateBottomSpringAnimation"];
}

- (void) removeAllAnimations
{
    [self.topLayer pop_removeAllAnimations];
    [self.middleLayer pop_removeAllAnimations];
    [self.bottomLayer pop_removeAllAnimations];
}

#pragma mark - Touch Methods

- (void) touchUpInsideHandler: (SearchButton *) button
{
    if ([self showMenu])
    {
        [self animateToListButton];
        [[NSNotificationCenter defaultCenter] postNotificationName: kUserWantsToCloseSearchNotification object: nil];
    }
    else
    {
        [self animateToCloseButton];
        [[NSNotificationCenter defaultCenter] postNotificationName: kUserWantsToOpenSearchNotification object: nil];
    }
    
    [self setShowMenu: !self.showMenu];
}

#pragma mark - Notification Methods

- (void) userOpenedSearch
{
    NSLog(@"userOpenedSearch");
    [self animateToCloseButton];
    [self setShowMenu: !self.showMenu];
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver: self forKeyPath: kUserStartedEditingSearchFieldNotification];
}

@end
