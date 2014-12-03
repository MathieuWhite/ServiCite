//
//  SearchBar.m
//  ServiCite
//
//  Created by Mathieu White on 2014-10-29.
//  Copyright (c) 2014 Mathieu White. All rights reserved.
//

#import "SearchBar.h"
#import "SearchButton.h"

@interface SearchBar ()

@property (nonatomic, weak) UIView *bottomStroke;
@property (nonatomic, weak) UITextField *searchField;
@property (nonatomic, weak) SearchButton *searchButton;

@property (nonatomic, assign) BOOL tappedInSearchField;
@property (nonatomic, assign) BOOL searchActive;

@end

@implementation SearchBar

#pragma mark - Initialization

+ (SearchBar *) sharedSearchBar
{
    static SearchBar *_sharedSearchBar;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _sharedSearchBar = [[self alloc] init];
    });
    
    return _sharedSearchBar;
}

- (id) init
{
    self = [super init];
    
    if (self)
    {
        [self initSearchBar];
    }
    
    return self;
}

- (void) initSearchBar
{
    // Bottom Stroke
    UIView *bottomStroke = [[UIView alloc] init];
    [bottomStroke setBackgroundColor: [UIColor colorWithWhite: 1.0f alpha: 0.3f]];
    [bottomStroke setTranslatesAutoresizingMaskIntoConstraints: NO];
    
    // Initialize the search field
    UITextField *searchField = [[UITextField alloc] init];
    [searchField setTextColor: [UIColor whiteColor]];
    [searchField setTintColor: [UIColor whiteColor]];
    [searchField setFont: [UIFont fontWithName: @"Avenir-Light" size: 24.0f]];
    [searchField setContentVerticalAlignment: UIControlContentVerticalAlignmentCenter];
    [searchField setAutocorrectionType: UITextAutocorrectionTypeNo];
    [searchField setTranslatesAutoresizingMaskIntoConstraints: NO];
    [searchField setReturnKeyType: UIReturnKeyDefault];
    [searchField setDelegate: self];
    [searchField setAttributedPlaceholder: [[NSAttributedString alloc] initWithString: NSLocalizedString(@"Search", nil)
                                                                           attributes: @{NSForegroundColorAttributeName : [UIColor colorWithWhite: 1.0f alpha: 0.3f]}]];
    
    // Initialize the search button
    SearchButton *searchButton = [SearchButton button];
    [searchButton setTintColor: [UIColor whiteColor]];
    
    // Add the components to the view
    [self addSubview: bottomStroke];
    [self addSubview: searchField];
    [self addSubview: searchButton];
    
    // Set each component to a property
    [self setBottomStroke: bottomStroke];
    [self setSearchField: searchField];
    [self setSearchButton: searchButton];
    [self setTappedInSearchField: YES];
    
    // Auto Layout
    [self setTranslatesAutoresizingMaskIntoConstraints: NO];
    [self setupConstraints];
    
    // Notification for when the user whants to open search
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(userTouchedSearchButton)
                                                 name: kUserWantsToOpenSearchNotification
                                               object: nil];
    
    // Notification for when the user whants to close search
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(userTouchedCloseButton)
                                                 name: kUserWantsToCloseSearchNotification
                                               object: nil];
    
    // Notification for when the user drags the search table
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(userDraggedSearchTable)
                                                 name: kUserDraggedSearchTableNotification
                                               object: nil];
}

#pragma mark - Auto Layout Method

- (void) setupConstraints
{
    // Search Button Width
    [self addConstraint: [NSLayoutConstraint constraintWithItem: self.searchButton
                                                      attribute: NSLayoutAttributeWidth
                                                      relatedBy: NSLayoutRelationEqual
                                                         toItem: self
                                                      attribute: NSLayoutAttributeWidth
                                                     multiplier: 0.0f
                                                       constant: 24.0f]];
    
    // Search Button Height
    [self addConstraint: [NSLayoutConstraint constraintWithItem: self.searchButton
                                                      attribute: NSLayoutAttributeHeight
                                                      relatedBy: NSLayoutRelationEqual
                                                         toItem: self
                                                      attribute: NSLayoutAttributeHeight
                                                     multiplier: 0.0f
                                                       constant: 17.0f]];
    
    // Search Button Top
    [self addConstraint: [NSLayoutConstraint constraintWithItem: self.searchButton
                                                      attribute: NSLayoutAttributeTop
                                                      relatedBy: NSLayoutRelationEqual
                                                         toItem: self
                                                      attribute: NSLayoutAttributeTop
                                                     multiplier: 1.0f
                                                       constant: 26.0f]];
    
    // Search Button Right
    [self addConstraint: [NSLayoutConstraint constraintWithItem: self.searchButton
                                                      attribute: NSLayoutAttributeRight
                                                      relatedBy: NSLayoutRelationEqual
                                                         toItem: self
                                                      attribute: NSLayoutAttributeRight
                                                     multiplier: 1.0f
                                                       constant: -16.0f]];
    
    // Search Text Field Top
    [self addConstraint: [NSLayoutConstraint constraintWithItem: self.searchField
                                                      attribute: NSLayoutAttributeTop
                                                      relatedBy: NSLayoutRelationEqual
                                                         toItem: self
                                                      attribute: NSLayoutAttributeTop
                                                     multiplier: 1.0f
                                                       constant: 20.0f]];
    
    // Search Text Field Bottom
    [self addConstraint: [NSLayoutConstraint constraintWithItem: self.searchField
                                                      attribute: NSLayoutAttributeBottom
                                                      relatedBy: NSLayoutRelationEqual
                                                         toItem: self
                                                      attribute: NSLayoutAttributeBottom
                                                     multiplier: 1.0f
                                                       constant: -10.0f]];
    
    // Search Text Field Left
    [self addConstraint: [NSLayoutConstraint constraintWithItem: self.searchField
                                                      attribute: NSLayoutAttributeLeft
                                                      relatedBy: NSLayoutRelationEqual
                                                         toItem: self
                                                      attribute: NSLayoutAttributeLeft
                                                     multiplier: 1.0f
                                                       constant: 24.0f]];
    
    // Search Text Field Right
    [self addConstraint: [NSLayoutConstraint constraintWithItem: self.searchField
                                                      attribute: NSLayoutAttributeRight
                                                      relatedBy: NSLayoutRelationEqual
                                                         toItem: self.searchButton
                                                      attribute: NSLayoutAttributeLeft
                                                     multiplier: 1.0f
                                                       constant: -20.0f]];

    // Bottom Stroke Height
    [self addConstraint: [NSLayoutConstraint constraintWithItem: self.bottomStroke
                                                      attribute: NSLayoutAttributeHeight
                                                      relatedBy: NSLayoutRelationEqual
                                                         toItem: self
                                                      attribute: NSLayoutAttributeHeight
                                                     multiplier: 0.0f
                                                       constant: 1.0f]];
    
    // Bottom Stroke Bottom
    [self addConstraint: [NSLayoutConstraint constraintWithItem: self.bottomStroke
                                                      attribute: NSLayoutAttributeBottom
                                                      relatedBy: NSLayoutRelationEqual
                                                         toItem: self
                                                      attribute: NSLayoutAttributeBottom
                                                     multiplier: 1.0f
                                                       constant: 0.0f]];
    
    // Bottom Stroke Left
    [self addConstraint: [NSLayoutConstraint constraintWithItem: self.bottomStroke
                                                      attribute: NSLayoutAttributeLeft
                                                      relatedBy: NSLayoutRelationEqual
                                                         toItem: self
                                                      attribute: NSLayoutAttributeLeft
                                                     multiplier: 1.0f
                                                       constant: 16.0f]];
    
    // Bottom Stroke Right
    [self addConstraint: [NSLayoutConstraint constraintWithItem: self.bottomStroke
                                                      attribute: NSLayoutAttributeRight
                                                      relatedBy: NSLayoutRelationEqual
                                                         toItem: self
                                                      attribute: NSLayoutAttributeRight
                                                     multiplier: 1.0f
                                                       constant: -16.0f]];
}

#pragma mark - UITextFieldDelegate Methods

- (BOOL) textField: (UITextField *) textField shouldChangeCharactersInRange: (NSRange) range replacementString: (NSString *) string
{
    NSString *searchText = [textField.text stringByReplacingCharactersInRange: range withString: string];
    //NSLog(@"Searching for: %@", value);
    [[NSNotificationCenter defaultCenter] postNotificationName: kUserIsSearchingForServicesNotification object: searchText];
    return YES;
}

- (void) textFieldDidBeginEditing: (UITextField *) textField
{
    if ([self searchActive]) return;
    
    [[NSNotificationCenter defaultCenter] postNotificationName: kUserOpenedSearchNotification object: nil];
    
    if ([self tappedInSearchField])
        [[NSNotificationCenter defaultCenter] postNotificationName: kUserStartedEditingSearchFieldNotification object: nil];
}

#pragma mark - Notification Methods

- (void) userTouchedSearchButton
{
    NSLog(@"userTouchedSearchButton");
    
    // This is kind of dirty but it works
    [self setTappedInSearchField: NO];
    [self.searchField becomeFirstResponder];
    [self setTappedInSearchField: YES];
}

- (void) userTouchedCloseButton
{
    NSLog(@"userTouchedCloseButton");
    [self setSearchActive: NO];
    
    [self.searchField resignFirstResponder];
    [self.searchField setText: @""];
    
    [[NSNotificationCenter defaultCenter] postNotificationName: kUserClosedSearchNotification object: nil];
}

- (void) userDraggedSearchTable
{
    [self setSearchActive: YES];
    [self.searchField resignFirstResponder];
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver: self forKeyPath: kUserWantsToOpenSearchNotification];
    [[NSNotificationCenter defaultCenter] removeObserver: self forKeyPath: kUserWantsToCloseSearchNotification];
    [[NSNotificationCenter defaultCenter] removeObserver: self forKeyPath: kUserDraggedSearchTableNotification];
}

@end
