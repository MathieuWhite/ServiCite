//
//  BehindViewController.m
//  ServiCite
//
//  Created by Mathieu White on 2014-10-28.
//  Copyright (c) 2014 Mathieu White. All rights reserved.
//

#import "BehindViewController.h"
#import "ServiceInfoViewController.h"
#import "PresentingAnimator.h"
#import "DismissingAnimator.h"
#import "SearchBar.h"
#import "SearchTableView.h"
#import "POP.h"

@interface BehindViewController ()

@property (nonatomic, weak) SearchBar *searchBar;

@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic, weak) MenuTableView *menuTableView;
@property (nonatomic, weak) SearchTableView *searchTableView;

@property (nonatomic, strong) NSLayoutConstraint *menuLeftConstraint;
@property (nonatomic, strong) NSLayoutConstraint *searchLeftConstraint;

@property (nonatomic, getter = isSearching) BOOL searching;

@end

@implementation BehindViewController

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    // Set the background image
    //[self.view setBackgroundColor: [UIColor colorWithPatternImage: [UIImage imageNamed: @"viewBehindBackground"]]];
    [self.view.layer setContents: (id) [UIImage imageNamed: @"viewBehindBackground"].CGImage];
    
    // Initialize the search bar
    SearchBar *searchBar = [SearchBar sharedSearchBar];
    
    // Initialize the scroll view
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    [scrollView setMinimumZoomScale: 1.0f];
    [scrollView setMaximumZoomScale: 1.0f];
    [scrollView setShowsHorizontalScrollIndicator: NO];
    [scrollView setShowsVerticalScrollIndicator: NO];
    [scrollView setScrollEnabled: YES];
    [scrollView setPagingEnabled: YES];
    [scrollView setTranslatesAutoresizingMaskIntoConstraints: NO];
    [scrollView setDelegate: self];
    
    // Menu View
    MenuTableView *menuTableView = [[MenuTableView alloc] init];
    
    // Search View
    SearchTableView *searchTableView = [[SearchTableView alloc] init];
    
    // Add test views to the scroll view
    [scrollView addSubview: menuTableView];
    [scrollView addSubview: searchTableView];
    
    // Add each component to the view
    [self.view addSubview: searchBar];
    [self.view addSubview: scrollView];
    
    // Set each component to a property
    [self setSearchBar: searchBar];
    [self setScrollView: scrollView];
    [self setMenuTableView: menuTableView];
    [self setSearchTableView: searchTableView];
    
    // Auto Layout
    [self setupConstraints];
    
    // Notification for when the user opens search
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(showSearchOptions)
                                                 name: kUserOpenedSearchNotification
                                               object: nil];
    
    // Notification for when the user closes search
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(showMenuOptions)
                                                 name: kUserClosedSearchNotification
                                               object: nil];
    
    // Notification for when the user selects a service from the search table
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(showServiceInformation:)
                                                 name: kUserSelectedServiceFromSearchTableNotification
                                               object: nil];
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

#pragma mark - Auto Layout Method

- (void) updateViewConstraints
{
    [self.scrollView removeConstraint: self.menuLeftConstraint];
    [self.scrollView removeConstraint: self.searchLeftConstraint];
    
    NSLayoutConstraint *menuLeftConstraint;
    NSLayoutConstraint *searchLeftConstraint;
    
    if ([self isSearching])
    {
        searchLeftConstraint = [NSLayoutConstraint constraintWithItem: self.searchTableView
                                                            attribute: NSLayoutAttributeLeft
                                                            relatedBy: NSLayoutRelationEqual
                                                               toItem: self.scrollView
                                                            attribute: NSLayoutAttributeLeft
                                                           multiplier: 1.0f
                                                             constant: 0.0f];
        
        menuLeftConstraint = [NSLayoutConstraint constraintWithItem: self.menuTableView
                                                          attribute: NSLayoutAttributeRight
                                                          relatedBy: NSLayoutRelationEqual
                                                             toItem: self.searchTableView
                                                          attribute: NSLayoutAttributeLeft
                                                         multiplier: 1.0f
                                                           constant: 0.0f];
    }
    
    else
    {
        menuLeftConstraint = [NSLayoutConstraint constraintWithItem: self.menuTableView
                                                          attribute: NSLayoutAttributeLeft
                                                          relatedBy: NSLayoutRelationEqual
                                                             toItem: self.scrollView
                                                          attribute: NSLayoutAttributeLeft
                                                         multiplier: 1.0f
                                                           constant: 0.0f];
        
        searchLeftConstraint = [NSLayoutConstraint constraintWithItem: self.searchTableView
                                                            attribute: NSLayoutAttributeLeft
                                                            relatedBy: NSLayoutRelationEqual
                                                               toItem: self.menuTableView
                                                            attribute: NSLayoutAttributeRight
                                                           multiplier: 1.0f
                                                             constant: 0.0f];
    }
    
    [self.scrollView addConstraint: menuLeftConstraint];
    [self.scrollView addConstraint: searchLeftConstraint];
    
    [self setMenuLeftConstraint: menuLeftConstraint];
    [self setSearchLeftConstraint: searchLeftConstraint];
    
    [super updateViewConstraints];
}

- (void) setupConstraints
{
    // Search Bar Width
    [self.view addConstraint: [NSLayoutConstraint constraintWithItem: self.searchBar
                                                           attribute: NSLayoutAttributeWidth
                                                           relatedBy: NSLayoutRelationEqual
                                                              toItem: self.view
                                                           attribute: NSLayoutAttributeWidth
                                                          multiplier: 1.0f
                                                            constant: 0.0f]];
    
    // Search Bar Height
    [self.view addConstraint: [NSLayoutConstraint constraintWithItem: self.searchBar
                                                           attribute: NSLayoutAttributeHeight
                                                           relatedBy: NSLayoutRelationEqual
                                                              toItem: self.view
                                                           attribute: NSLayoutAttributeHeight
                                                          multiplier: 0.0f
                                                            constant: 64.0f]];
    
    // Search Bar Top
    [self.view addConstraint: [NSLayoutConstraint constraintWithItem: self.searchBar
                                                           attribute: NSLayoutAttributeTop
                                                           relatedBy: NSLayoutRelationEqual
                                                              toItem: self.view
                                                           attribute: NSLayoutAttributeTop
                                                          multiplier: 1.0f
                                                            constant: 0.0f]];
    
    // Scroll View Top
    [self.view addConstraint: [NSLayoutConstraint constraintWithItem: self.scrollView
                                                           attribute: NSLayoutAttributeTop
                                                           relatedBy: NSLayoutRelationEqual
                                                              toItem: self.view
                                                           attribute: NSLayoutAttributeTop
                                                          multiplier: 1.0f
                                                            constant: 64.0f]];
    
    // Scroll View Left
    [self.view addConstraint: [NSLayoutConstraint constraintWithItem: self.scrollView
                                                           attribute: NSLayoutAttributeLeft
                                                           relatedBy: NSLayoutRelationEqual
                                                              toItem: self.view
                                                           attribute: NSLayoutAttributeLeft
                                                          multiplier: 1.0f
                                                            constant: 0.0f]];
    
    // Scroll View Right
    [self.view addConstraint: [NSLayoutConstraint constraintWithItem: self.scrollView
                                                           attribute: NSLayoutAttributeRight
                                                           relatedBy: NSLayoutRelationEqual
                                                              toItem: self.view
                                                           attribute: NSLayoutAttributeRight
                                                          multiplier: 1.0f
                                                            constant: 0.0f]];
    
    // Scroll View Bottom
    [self.view addConstraint: [NSLayoutConstraint constraintWithItem: self.scrollView
                                                           attribute: NSLayoutAttributeBottom
                                                           relatedBy: NSLayoutRelationEqual
                                                              toItem: self.view
                                                           attribute: NSLayoutAttributeBottom
                                                          multiplier: 1.0f
                                                            constant: -64.0f]];
    
    // Menu View Width
    [self.scrollView addConstraint: [NSLayoutConstraint constraintWithItem: self.menuTableView
                                                                 attribute: NSLayoutAttributeWidth
                                                                 relatedBy: NSLayoutRelationEqual
                                                                    toItem: self.scrollView
                                                                 attribute: NSLayoutAttributeWidth
                                                                multiplier: 1.0f
                                                                  constant: 0.0f]];
    
    // Menu View Height
    [self.scrollView addConstraint: [NSLayoutConstraint constraintWithItem: self.menuTableView
                                                                 attribute: NSLayoutAttributeHeight
                                                                 relatedBy: NSLayoutRelationEqual
                                                                    toItem: self.scrollView
                                                                 attribute: NSLayoutAttributeHeight
                                                                multiplier: 1.0f
                                                                  constant: 0.0f]];
    
    // Menu View Top
    [self.scrollView addConstraint: [NSLayoutConstraint constraintWithItem: self.menuTableView
                                                                 attribute: NSLayoutAttributeTop
                                                                 relatedBy: NSLayoutRelationEqual
                                                                    toItem: self.scrollView
                                                                 attribute: NSLayoutAttributeTop
                                                                multiplier: 1.0f
                                                                  constant: 0.0f]];
    
    // Menu View Left
    NSLayoutConstraint *menuLeftConstraint = [NSLayoutConstraint constraintWithItem: self.menuTableView
                                                                          attribute: NSLayoutAttributeLeft
                                                                          relatedBy: NSLayoutRelationEqual
                                                                             toItem: self.scrollView
                                                                          attribute: NSLayoutAttributeLeft
                                                                         multiplier: 1.0f
                                                                           constant: 0.0f];
    [self.scrollView addConstraint: menuLeftConstraint];
    [self setMenuLeftConstraint: menuLeftConstraint];
    
    // Search View Width
    [self.scrollView addConstraint: [NSLayoutConstraint constraintWithItem: self.searchTableView
                                                                 attribute: NSLayoutAttributeWidth
                                                                 relatedBy: NSLayoutRelationEqual
                                                                    toItem: self.scrollView
                                                                 attribute: NSLayoutAttributeWidth
                                                                multiplier: 1.0f
                                                                  constant: 0.0f]];
    
    // Search View Height
    [self.scrollView addConstraint: [NSLayoutConstraint constraintWithItem: self.searchTableView
                                                                 attribute: NSLayoutAttributeHeight
                                                                 relatedBy: NSLayoutRelationEqual
                                                                    toItem: self.scrollView
                                                                 attribute: NSLayoutAttributeHeight
                                                                multiplier: 1.0f
                                                                  constant: 0.0f]];
    
    // Search View Top
    [self.scrollView addConstraint: [NSLayoutConstraint constraintWithItem: self.searchTableView
                                                                 attribute: NSLayoutAttributeTop
                                                                 relatedBy: NSLayoutRelationEqual
                                                                    toItem: self.scrollView
                                                                 attribute: NSLayoutAttributeTop
                                                                multiplier: 1.0f
                                                                  constant: 0.0f]];
    
    // Search View Left
    NSLayoutConstraint *searchLeftConstraint =  [NSLayoutConstraint constraintWithItem: self.searchTableView
                                                                             attribute: NSLayoutAttributeLeft
                                                                             relatedBy: NSLayoutRelationEqual
                                                                                toItem: self.menuTableView
                                                                             attribute: NSLayoutAttributeRight
                                                                            multiplier: 1.0f
                                                                              constant: 0.0f];
    [self.scrollView addConstraint: searchLeftConstraint];
    [self setSearchLeftConstraint: searchLeftConstraint];
}

#pragma mark - Notification Methods

- (void) showSearchOptions
{
    NSLog(@"showSearchOptions");
    [self animateToSearch];
}

- (void) showMenuOptions
{
    NSLog(@"showMenuOptions");
    [self animateToMenu];
}

- (void) animateToSearch
{
    POPBasicAnimation *menuAnimation = [POPBasicAnimation animationWithPropertyNamed: kPOPLayerPositionX];
    [menuAnimation setToValue: @(-CGRectGetMidX(self.view.bounds) - 20.0f)];
    [menuAnimation setDuration: 0.4];
    
    POPBasicAnimation *searchAnimation = [POPBasicAnimation animationWithPropertyNamed: kPOPLayerPositionX];
    [searchAnimation setToValue: @(CGRectGetMidX(self.view.bounds))];
    [searchAnimation setDuration: 0.4];
    
    [searchAnimation setCompletionBlock: ^(POPAnimation *anim, BOOL finished){
        [self setSearching: YES];
        [self updateViewConstraints];
    }];
    
    [self.menuTableView.layer pop_addAnimation: menuAnimation forKey: @"menuOutBasicAnimation"];
    [self.searchTableView.layer pop_addAnimation: searchAnimation forKey: @"searchInBasicAnimation"];
}

- (void) animateToMenu
{
    POPBasicAnimation *menuAnimation = [POPBasicAnimation animationWithPropertyNamed: kPOPLayerPositionX];
    [menuAnimation setToValue: @(CGRectGetMidX(self.view.bounds))];
    [menuAnimation setDuration: 0.4];
    
    POPBasicAnimation *searchAnimation = [POPBasicAnimation animationWithPropertyNamed: kPOPLayerPositionX];
    [searchAnimation setToValue: @(CGRectGetMaxX(self.view.bounds) * 2.0f + 20.0f)];
    [searchAnimation setDuration: 0.4];
    
    [searchAnimation setCompletionBlock: ^(POPAnimation *anim, BOOL finished){
        [self setSearching: NO];
        [self updateViewConstraints];
    }];
    
    [self.menuTableView.layer pop_addAnimation: menuAnimation forKey: @"menuInBasicAnimation"];
    [self.searchTableView.layer pop_addAnimation: searchAnimation forKey: @"SearchOutBasicAnimation"];
}

- (void) showServiceInformation: (NSNotification *) notification
{
    if ([notification.object isKindOfClass: [Service class]])
    {
        Service *service = [notification object];
        NSLog(@"showServiceInformation: %@", [service name]);
        [[NSNotificationCenter defaultCenter] postNotificationName: kUserDraggedSearchTableNotification object: nil];
        
        ServiceInfoViewController *serviceInformationViewController = [[ServiceInfoViewController alloc] initWithService: service];
        [serviceInformationViewController setTransitioningDelegate: self];
        [serviceInformationViewController setModalPresentationStyle: UIModalPresentationCustom];
        
        [self.navigationController presentViewController: serviceInformationViewController animated: YES completion: nil];
        NSLog(@"modal presented");
    }
    else
    {
        NSLog(@"Error, object not recognized.");
    }
}

- (void) viewDidDisappear: (BOOL) animated
{
    [super viewDidDisappear: animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}

@end
