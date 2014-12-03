//
//  PresentingAnimator.m
//  ServiCite
//
//  Created by Mathieu White on 2014-11-04.
//  Copyright (c) 2014 Mathieu White. All rights reserved.
//

#import "PresentingAnimator.h"
#import "POP.h"

@implementation PresentingAnimator

#pragma mark - UIViewControllerAnimatedTransitioning Methods

- (NSTimeInterval) transitionDuration: (id <UIViewControllerContextTransitioning>) transitionContext
{
    return 0.5f;
}

- (void) animateTransition: (id <UIViewControllerContextTransitioning>) transitionContext
{
    // The view behind the modal
    UIView *backView = [[transitionContext viewControllerForKey: UITransitionContextFromViewControllerKey] view];
    [backView setTintAdjustmentMode: UIViewTintAdjustmentModeDimmed];
    [backView setUserInteractionEnabled: NO];

    // The view overlayed on the back view
    //UIView *dimView = [[UIView alloc] initWithFrame: [backView bounds]];
    UIView *dimView = [[UIView alloc] init];
    [dimView setTranslatesAutoresizingMaskIntoConstraints: NO];
    [dimView setBackgroundColor: [UIColor blackColor]];
    [dimView.layer setOpacity: 0.0f];

    // The modal view
    UIView *modal = [[transitionContext viewControllerForKey: UITransitionContextToViewControllerKey] view];
    [modal setFrame: [transitionContext.containerView bounds]];
    [modal setCenter: CGPointMake(backView.center.x, CGRectGetMaxY(backView.bounds) * 2.0f)];

    // Add the views to the context
    [transitionContext.containerView addSubview: dimView];
    [transitionContext.containerView addSubview: modal];
    
    // Views Dictionary for Auto Layout
    NSDictionary *views = @{@"dimView" : dimView};
    
    // Dim View Horizontal Constraints
    NSArray *dimViewHorizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat: @"H:|[dimView]|"
                                                                                    options: 0
                                                                                    metrics: nil
                                                                                      views: views];
    // Dim View Vertical Constraints
    NSArray *dimViewVerticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat: @"V:|[dimView]|"
                                                                                  options: 0
                                                                                  metrics: nil
                                                                                    views: views];
    // Add the constraints to the context view
    [transitionContext.containerView addConstraints: dimViewHorizontalConstraints];
    [transitionContext.containerView addConstraints: dimViewVerticalConstraints];

    POPBasicAnimation *appearOnScreenAnimation = [POPBasicAnimation animationWithPropertyNamed: kPOPLayerPositionY];
    //[appearOnScreenAnimation setFromValue: @(CGRectGetMaxY(backView.bounds) * 2.0f)];
    [appearOnScreenAnimation setToValue: @(transitionContext.containerView.center.y)];
    [appearOnScreenAnimation setDuration: [self transitionDuration: transitionContext]];
    
    [appearOnScreenAnimation setCompletionBlock: ^(POPAnimation *anim, BOOL finished) {
        [transitionContext completeTransition: YES];
    }];

    POPBasicAnimation *dimmingAnimation = [POPBasicAnimation animationWithPropertyNamed: kPOPLayerOpacity];
    [dimmingAnimation setToValue: @(0.95)];
    [dimmingAnimation setDuration: [self transitionDuration: transitionContext]];

    [modal.layer pop_addAnimation: appearOnScreenAnimation forKey: @"appearOnScreenBasicAnimation"];
    [dimView.layer pop_addAnimation: dimmingAnimation forKey: @"dimmingBasicAnimation"];
}

@end
