//
//  ServiceDetailView.m
//  ServiCite
//
//  Created by Mathieu White on 2014-11-05.
//  Copyright (c) 2014 Mathieu White. All rights reserved.
//

#import "ServiceDetailView.h"

@interface ServiceDetailView ()

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *detail;

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UITextView *detailView;

@end

@implementation ServiceDetailView

#pragma mark - Initialization

- (instancetype) initWithTitle: (NSString *) title detail: (NSString *) detail
{
    self = [super init];
    
    if (self)
    {
        [self setTitle: title];
        [self setDetail: detail];
        [self initServiceDetailView];
    }
    
    return self;
}

- (void) initServiceDetailView
{
    [self setTranslatesAutoresizingMaskIntoConstraints: NO];
    
    // Initialize the title label
    UILabel *titleLabel = [[UILabel alloc] init];
    [titleLabel setText: [self title]];
    [titleLabel setTextColor: [UIColor colorWithWhite: 0.4f alpha: 0.6f]];
    [titleLabel setFont: [UIFont fontWithName: @"Avenir-Light" size: 16.0f]];
    [titleLabel setTranslatesAutoresizingMaskIntoConstraints: NO];
    
    // Initialize the detail label
    UITextView *detailView = [[UITextView alloc] init];
    [detailView setBackgroundColor: [UIColor clearColor]];
    [detailView setText: [self detail]];
    [detailView setTextColor: [UIColor blackColor]];
    [detailView setFont: [UIFont fontWithName: @"Avenir" size: 16.0f]];
    [detailView setTintColor: [UIColor colorWithRed: 0.0f/255.0f green: 172.0f/255.0f blue: 99.0f/255.0f alpha: 1.0f]];
    [detailView setEditable: NO];
    [detailView setScrollEnabled: NO];
    [detailView setTextContainerInset: UIEdgeInsetsMake(0, 0, 0, 0)];
    [detailView setContentInset: UIEdgeInsetsMake(0, 0, 0, 0)];
    [detailView setDataDetectorTypes: UIDataDetectorTypeAll];
    [detailView.textContainer setLineFragmentPadding: 0.0f];
    [detailView.textContainer setMaximumNumberOfLines: 1];
    [detailView.textContainer setLineBreakMode: NSLineBreakByTruncatingTail];
    [detailView setTranslatesAutoresizingMaskIntoConstraints: NO];
    
    // Add each component to the view
    [self addSubview: titleLabel];
    [self addSubview: detailView];
    
    // Set each component to a property
    [self setTitleLabel: titleLabel];
    [self setDetailView: detailView];
    
    // Auto Layout
    [self setupConstraints];
}

#pragma mark - Auto Layout Methods

- (void) setupConstraints
{
    // Title Label Height
    [self addConstraint: [NSLayoutConstraint constraintWithItem: self.titleLabel
                                                      attribute: NSLayoutAttributeHeight
                                                      relatedBy: NSLayoutRelationEqual
                                                         toItem: self
                                                      attribute: NSLayoutAttributeHeight
                                                     multiplier: 0.5f
                                                       constant: 0.0f]];
    
    // Title Label Top
    [self addConstraint: [NSLayoutConstraint constraintWithItem: self.titleLabel
                                                      attribute: NSLayoutAttributeTop
                                                      relatedBy: NSLayoutRelationEqual
                                                         toItem: self
                                                      attribute: NSLayoutAttributeTop
                                                     multiplier: 1.0f
                                                       constant: 0.0f]];
    
    // Title Label Left
    [self addConstraint: [NSLayoutConstraint constraintWithItem: self.titleLabel
                                                      attribute: NSLayoutAttributeLeft
                                                      relatedBy: NSLayoutRelationEqual
                                                         toItem: self
                                                      attribute: NSLayoutAttributeLeft
                                                     multiplier: 1.0f
                                                       constant: 0.0f]];
    
    // Title Label Right
    [self addConstraint: [NSLayoutConstraint constraintWithItem: self.titleLabel
                                                      attribute: NSLayoutAttributeRight
                                                      relatedBy: NSLayoutRelationEqual
                                                         toItem: self
                                                      attribute: NSLayoutAttributeRight
                                                     multiplier: 1.0f
                                                       constant: 0.0f]];
    
    // Detail View Height
    [self addConstraint: [NSLayoutConstraint constraintWithItem: self.detailView
                                                      attribute: NSLayoutAttributeHeight
                                                      relatedBy: NSLayoutRelationEqual
                                                         toItem: self
                                                      attribute: NSLayoutAttributeHeight
                                                     multiplier: 0.5f
                                                       constant: 0.0f]];
    
    // Detail View Bottom
    [self addConstraint: [NSLayoutConstraint constraintWithItem: self.detailView
                                                      attribute: NSLayoutAttributeBottom
                                                      relatedBy: NSLayoutRelationEqual
                                                         toItem: self
                                                      attribute: NSLayoutAttributeBottom
                                                     multiplier: 1.0f
                                                       constant: 0.0f]];
    
    // Detail View Left
    [self addConstraint: [NSLayoutConstraint constraintWithItem: self.detailView
                                                      attribute: NSLayoutAttributeLeft
                                                      relatedBy: NSLayoutRelationEqual
                                                         toItem: self
                                                      attribute: NSLayoutAttributeLeft
                                                     multiplier: 1.0f
                                                       constant: 0.0f]];
    
    // Detail View Right
    [self addConstraint: [NSLayoutConstraint constraintWithItem: self.detailView
                                                      attribute: NSLayoutAttributeRight
                                                      relatedBy: NSLayoutRelationEqual
                                                         toItem: self
                                                      attribute: NSLayoutAttributeRight
                                                     multiplier: 1.0f
                                                       constant: 0.0f]];
}

@end
