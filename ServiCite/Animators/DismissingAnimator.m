//
//  DismissingAnimator.m
//  ServiCite
//
//  Created by Mathieu White on 2014-11-04.
//  Copyright (c) 2014 Mathieu White. All rights reserved.
//

#import "DismissingAnimator.h"
#import "POP.h"

@implementation DismissingAnimator

#pragma mark - UIViewControllerAnimatedTransitioning Methods

- (NSTimeInterval) transitionDuration: (id <UIViewControllerContextTransitioning>) transitionContext
{
    return 0.5f;
}

- (void) animateTransition: (id <UIViewControllerContextTransitioning>) transitionContext
{
    UIViewController *backView = [transitionContext viewControllerForKey: UITransitionContextToViewControllerKey];
    [backView.view setTintAdjustmentMode: UIViewTintAdjustmentModeNormal];
    [backView.view setUserInteractionEnabled: YES];

    UIViewController *modal = [transitionContext viewControllerForKey: UITransitionContextFromViewControllerKey];

    // Removing the dim on the background view
    __block UIView *dimView;
    [transitionContext.containerView.subviews enumerateObjectsUsingBlock: ^(UIView *view, NSUInteger index, BOOL *stop) {
        if (view.layer.opacity < 1.0f)
        {
            dimView = view;
            *stop = YES;
        }
    }];
    
    POPBasicAnimation *enlightenAnimation = [POPBasicAnimation animationWithPropertyNamed: kPOPLayerOpacity];
    [enlightenAnimation setToValue: @(0.0)];
    [enlightenAnimation setDuration: [self transitionDuration: transitionContext]];

    POPBasicAnimation *fallOffScreenAnimation = [POPBasicAnimation animationWithPropertyNamed: kPOPLayerPositionY];
    [fallOffScreenAnimation setToValue: @(CGRectGetMaxY(backView.view.bounds) * 2.0f)];
    [fallOffScreenAnimation setDuration: [self transitionDuration: transitionContext]];
    
    // Stop the enlighting animation when the modal is off screen
    [fallOffScreenAnimation setCompletionBlock: ^(POPAnimation *anim, BOOL finished) {
        [transitionContext completeTransition: YES];
    }];
    
    [modal.view.layer pop_addAnimation: fallOffScreenAnimation forKey: @"fallOffScreenBasicAnimation"];
    [dimView.layer pop_addAnimation: enlightenAnimation forKey: @"enlightenBasicAnimation"];
}

@end
