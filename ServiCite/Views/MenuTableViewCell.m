//
//  MenuTableViewCell.m
//  ServiCite
//
//  Created by Mathieu White on 2014-11-03.
//  Copyright (c) 2014 Mathieu White. All rights reserved.
//

#import "MenuTableViewCell.h"
#import "POP.h"

@interface MenuTableViewCell ()

@property (nonatomic, weak) UIView *cellSeparator;

@end

@implementation MenuTableViewCell

#pragma mark - Initialization

- (id) initWithStyle: (UITableViewCellStyle) style reuseIdentifier: (NSString *) reuseIdentifier
{
    self = [super initWithStyle: style reuseIdentifier: reuseIdentifier];
    
    if (self)
    {
        [self initMenuTableViewCell];
    }
    
    return self;
}

- (void) initMenuTableViewCell
{
    // Initialize the title label
    UILabel *titleLabel = [[UILabel alloc] init];
    [titleLabel setTextColor: [UIColor whiteColor]];
    [titleLabel setFont: [UIFont fontWithName: @"Avenir-Light" size: 22.0f]];
    [titleLabel setTranslatesAutoresizingMaskIntoConstraints: NO];
    
    // Initialize the cell separator
    UIView *cellSeparator = [[UIView alloc] init];
    [cellSeparator setBackgroundColor: [UIColor colorWithWhite: 1.0f alpha: 0.3f]];
    [cellSeparator setTranslatesAutoresizingMaskIntoConstraints: NO];
    
    [self.contentView addSubview: titleLabel];
    [self.contentView addSubview: cellSeparator];
    
    [self setBackgroundColor: [UIColor clearColor]];
    [self setSelectionStyle: UITableViewCellSelectionStyleNone];
    
    [self setTitleLabel: titleLabel];
    [self setCellSeparator: cellSeparator];
    
    [self setupConstraints];
}

- (void) setLastCell: (BOOL) lastCell
{
    if (lastCell)
        [self.cellSeparator removeFromSuperview];
}

#pragma mark - UITableViewCell Methods

- (void) setHighlighted: (BOOL) highlighted animated: (BOOL) animated
{
    [self.titleLabel.layer pop_removeAllAnimations];
    
    if (highlighted)
        [self scaleToSmall];
    else
        [self scaleToOriginal];
}

- (void) setSelected:(BOOL) selected animated: (BOOL) animated
{
    [super setSelected: selected animated: animated];
}

#pragma mark - Cell Animation Methods

- (void) scaleToSmall
{
    [self.titleLabel setTextColor: [UIColor colorWithWhite: 1.0f alpha: 0.6f]];
    
    POPSpringAnimation *scaleAnimation = [POPSpringAnimation animationWithPropertyNamed: kPOPLayerScaleXY];
    [scaleAnimation setToValue: [NSValue valueWithCGSize: CGSizeMake(0.9f, 0.9f)]];
    [scaleAnimation setSpringBounciness: 12.0f];
    [self.titleLabel.layer pop_addAnimation: scaleAnimation forKey: @"scaleToSmallSpringAnimation"];
}

- (void) scaleToOriginal
{
    [self.titleLabel setTextColor: [UIColor whiteColor]];
    
    POPSpringAnimation *scaleAnimation = [POPSpringAnimation animationWithPropertyNamed: kPOPLayerScaleXY];
    [scaleAnimation setVelocity: [NSValue valueWithCGSize: CGSizeMake(3.0f, 3.0f)]];
    [scaleAnimation setToValue: [NSValue valueWithCGSize: CGSizeMake(1.0f, 1.0f)]];
    [scaleAnimation setSpringBounciness: 12.0f];
    [self.titleLabel.layer pop_addAnimation: scaleAnimation forKey: @"scaleToOriginalSpringAnimation"];
}

#pragma mark - Auto Layout Method

- (void) setupConstraints
{
    // Title Tabel Top
    [self.contentView addConstraint: [NSLayoutConstraint constraintWithItem: self.titleLabel
                                                                  attribute: NSLayoutAttributeTop
                                                                  relatedBy: NSLayoutRelationEqual
                                                                     toItem: self.contentView
                                                                  attribute: NSLayoutAttributeTop
                                                                 multiplier: 1.0f
                                                                   constant: 0.0f]];
    
    // Title Label Left
    [self.contentView addConstraint: [NSLayoutConstraint constraintWithItem: self.titleLabel
                                                                  attribute: NSLayoutAttributeLeft
                                                                  relatedBy: NSLayoutRelationEqual
                                                                     toItem: self.contentView
                                                                  attribute: NSLayoutAttributeLeft
                                                                 multiplier: 1.0f
                                                                   constant: 36.0f]];
    
    // Title Label Right
    [self.contentView addConstraint: [NSLayoutConstraint constraintWithItem: self.titleLabel
                                                                  attribute: NSLayoutAttributeRight
                                                                  relatedBy: NSLayoutRelationEqual
                                                                     toItem: self.contentView
                                                                  attribute: NSLayoutAttributeRight
                                                                 multiplier: 1.0f
                                                                   constant: -16.0f]];
    
    // Title Label Bottom
    [self.contentView addConstraint: [NSLayoutConstraint constraintWithItem: self.titleLabel
                                                                  attribute: NSLayoutAttributeBottom
                                                                  relatedBy: NSLayoutRelationEqual
                                                                     toItem: self.contentView
                                                                  attribute: NSLayoutAttributeBottom
                                                                 multiplier: 1.0f
                                                                   constant: 0.0f]];
    
    // Cell Separator Height
    [self.contentView addConstraint: [NSLayoutConstraint constraintWithItem: self.cellSeparator
                                                                  attribute: NSLayoutAttributeHeight
                                                                  relatedBy: NSLayoutRelationEqual
                                                                     toItem: self.contentView
                                                                  attribute: NSLayoutAttributeHeight
                                                                 multiplier: 0.0f
                                                                   constant: 1.0f]];
    
    // Cell Separator Left
    [self.contentView addConstraint: [NSLayoutConstraint constraintWithItem: self.cellSeparator
                                                                  attribute: NSLayoutAttributeLeft
                                                                  relatedBy: NSLayoutRelationEqual
                                                                     toItem: self.contentView
                                                                  attribute: NSLayoutAttributeLeft
                                                                 multiplier: 1.0f
                                                                   constant: 16.0f]];
    
    // Cell Separator Right
    [self.contentView addConstraint: [NSLayoutConstraint constraintWithItem: self.cellSeparator
                                                                  attribute: NSLayoutAttributeRight
                                                                  relatedBy: NSLayoutRelationEqual
                                                                     toItem: self.contentView
                                                                  attribute: NSLayoutAttributeRight
                                                                 multiplier: 1.0f
                                                                   constant: -16.0f]];
    
    // Cell Separator Bottom
    [self.contentView addConstraint: [NSLayoutConstraint constraintWithItem: self.cellSeparator
                                                                  attribute: NSLayoutAttributeBottom
                                                                  relatedBy: NSLayoutRelationEqual
                                                                     toItem: self.contentView
                                                                  attribute: NSLayoutAttributeBottom
                                                                 multiplier: 1.0f
                                                                   constant: 0.0f]];
}

@end
