//
//  ActionButton.m
//  ServiCite
//
//  Created by Mathieu White on 2014-10-28.
//  Copyright (c) 2014 Mathieu White. All rights reserved.
//

#import "ActionButton.h"
#import "POP.h"

@implementation ActionButton

#pragma mark - Initialization

+ (instancetype) button
{
    return [self buttonWithType: UIButtonTypeCustom];
}

- (id) initWithFrame: (CGRect) frame
{
    self = [super initWithFrame: frame];
    
    if (self)
    {
        [self initButton];
    }
    
    return self;
}

- (void) initButton
{
    [self setBackgroundColor: self.tintColor];
    [self setTitleColor: [UIColor blackColor] forState: UIControlStateNormal];
    [self setTranslatesAutoresizingMaskIntoConstraints: NO];
    
    [self addTarget: self action: @selector(scaleToSmall) forControlEvents: UIControlEventTouchDown | UIControlEventTouchDragEnter];
    [self addTarget: self action: @selector(scaleAnimation) forControlEvents: UIControlEventTouchUpInside];
    [self addTarget: self action: @selector(scaleToDefault) forControlEvents: UIControlEventTouchDragExit];
}

#pragma mark - Instance methods

/*
- (UIEdgeInsets) titleEdgeInsets
{
    return UIEdgeInsetsMake(4.0f, 28.0f, 4.0f, 28.0f);
}

- (CGSize)intrinsicContentSize
{
    CGSize s = [super intrinsicContentSize];
    
    return CGSizeMake(s.width + self.titleEdgeInsets.left + self.titleEdgeInsets.right,
                      s.height + self.titleEdgeInsets.top + self.titleEdgeInsets.bottom);
}
 */

#pragma mark - Animation Methods

- (void) scaleToSmall
{
    POPBasicAnimation *scaleAnimation = [POPBasicAnimation animationWithPropertyNamed: kPOPLayerScaleXY];
    [scaleAnimation setToValue: [NSValue valueWithCGSize: CGSizeMake(0.9f, 0.9f)]];
    [self.layer pop_addAnimation: scaleAnimation forKey: @"layerScaleSmallAnimation"];
}

- (void) scaleAnimation
{
    POPSpringAnimation *scaleAnimation = [POPSpringAnimation animationWithPropertyNamed: kPOPLayerScaleXY];
    [scaleAnimation setVelocity: [NSValue valueWithCGSize: CGSizeMake(3.0f, 3.0f)]];
    [scaleAnimation setToValue: [NSValue valueWithCGSize: CGSizeMake(1.0f, 1.0f)]];
    [scaleAnimation setSpringBounciness: 18.0f];
    [self.layer pop_addAnimation: scaleAnimation forKey: @"layerScaleSpringAnimation"];
}

- (void) scaleToDefault
{
    POPBasicAnimation *scaleAnimation = [POPBasicAnimation animationWithPropertyNamed: kPOPLayerScaleXY];
    [scaleAnimation setToValue: [NSValue valueWithCGSize: CGSizeMake(1.0f, 1.0f)]];
    [self.layer pop_addAnimation: scaleAnimation forKey: @"layerScaleDefaultAnimation"];
}

@end
