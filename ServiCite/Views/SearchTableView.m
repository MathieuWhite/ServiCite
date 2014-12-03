//
//  SearchTableView.m
//  ServiCite
//
//  Created by Mathieu White on 2014-10-31.
//  Copyright (c) 2014 Mathieu White. All rights reserved.
//

#import "SearchTableView.h"
#import "SearchBar.h"
#import "SearchTableViewCell.h"

@interface SearchTableView ()

@property (nonatomic, strong) NSMutableArray *services;
@property (nonatomic, strong) NSMutableArray *searchResults;

@property (nonatomic, assign) BOOL noResultsToDisplay;

@end

@implementation SearchTableView

#pragma mark - Initialization

- (id) init
{
    self = [super init];
    
    if (self)
    {
        [self initSearchTableView];
    }
    
    return self;
}

- (void) initSearchTableView
{
    [self setBackgroundColor: [UIColor clearColor]];
    [self setSeparatorStyle: UITableViewCellSeparatorStyleNone];
    [self setDataSource: self];
    [self setDelegate: self];
    
    // Initialize the array to store all of the services on campus
    NSMutableArray *services = [[Services sharedServices] allServices];
    [self setServices: services];
    
    // Initialize the array to store the filtered services (search results)
    NSMutableArray *searchResults = [NSMutableArray array];
    [self setSearchResults: searchResults];
    
    // Auto Layout
    [self setTranslatesAutoresizingMaskIntoConstraints: NO];
    [self setupConstraints];
    
    // Notification for when the user is searching for services
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(filterServices:)
                                                 name: kUserIsSearchingForServicesNotification
                                               object: nil];
    
    // Notification for when the user clears the search field
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(reInitializeTableViewWithAllServices)
                                                 name: kUserClosedSearchNotification
                                               object: nil];
}

#pragma mark - Auto Layout Method

- (void) setupConstraints
{
}

#pragma mark - UITableViewDataSource Methods

- (NSInteger) numberOfSectionsInTableView: (UITableView *) tableView
{
    return 1;
}

- (NSInteger) tableView: (UITableView *) tableView numberOfRowsInSection: (NSInteger) section
{
    if ([self noResultsToDisplay]) return 1;
    else return [self.services count];
}

- (UITableViewCell *) tableView: (UITableView *) tableView cellForRowAtIndexPath: (NSIndexPath *) indexPath
{
    static NSString *cellIdentifier = @"SearchResultCell";
    
    // No results to display
    if ([self noResultsToDisplay])
    {
        SearchTableViewCell *noResult = [[SearchTableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier: @"noResult"];
        [noResult.titleLabel setText: NSLocalizedString(@"No Results", nil)];
        [noResult setLastCell: YES];
        return noResult;
    }
    
    SearchTableViewCell *cell = (SearchTableViewCell *) [tableView dequeueReusableCellWithIdentifier: cellIdentifier];
    
    if (cell == nil)
        cell = [[SearchTableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier: cellIdentifier];
    
    [cell.titleLabel setText: [[self.services objectAtIndex: [indexPath row]] name]];
    
    if ([indexPath row] == [tableView numberOfRowsInSection: 0] - 1)
    {
        SearchTableViewCell *lastCell = [[SearchTableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier: @"lastCell"];
        [lastCell.titleLabel setText: [[self.services lastObject] name]];
        [lastCell setLastCell: YES];
        return lastCell;
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate Methods

- (void) tableView: (UITableView *) tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath
{
    if (![self noResultsToDisplay])
    {
        Service *service = [self.services objectAtIndex: [indexPath row]];
        [[NSNotificationCenter defaultCenter] postNotificationName: kUserSelectedServiceFromSearchTableNotification object: service];
    }
}

- (CGFloat) tableView: (UITableView *) tableView heightForRowAtIndexPath: (NSIndexPath *) indexPath
{
    return 60.0f;
}

- (void) scrollViewWillBeginDragging: (UIScrollView *) scrollView
{
    [[NSNotificationCenter defaultCenter] postNotificationName: kUserDraggedSearchTableNotification object: nil];
}

#pragma mark - Notification Methods

- (void) filterServices: (NSNotification *) notification
{
    if ([[notification object] isKindOfClass: [NSString class]])
    {
        NSString *searchText = [notification object];
        
        [self setNoResultsToDisplay: NO];
        
        // Restore all services in the table view
        if ([searchText isEqualToString: @""])
        {
            [self reInitializeTableViewWithAllServices];
            return;
        }
        
        NSLog(@"searching for: %@", searchText);
        [self.searchResults removeAllObjects];
        
        // Filter the array using NSPredicate
        NSPredicate *predicate = [NSPredicate predicateWithFormat: @"SELF.name contains[c] %@", searchText];
        self.searchResults = [NSMutableArray arrayWithArray: [[[Services sharedServices] allServices] filteredArrayUsingPredicate: predicate]];
        
        for (NSUInteger index = 0; index < [self.searchResults count]; index++)
        {
            NSLog(@"Result: %@", [[self.searchResults objectAtIndex: index] name]);
        }
        
        [self setServices: self.searchResults];
        
        if ([self.services count] == 0)
        {
            [self setNoResultsToDisplay: YES];
            NSLog(@"setnoresultsto yes");
        }
        else
        {
            [self setNoResultsToDisplay: NO];
            NSLog(@"setnoresultsto no");
        }
        
        [self reloadData];
    }
    else
    {
        NSLog(@"Error, object not recognized.");
    }
}

- (void) reInitializeTableViewWithAllServices
{
    [self setNoResultsToDisplay: NO];
    [self setServices: [[Services sharedServices] allServices]];
    [self reloadData];
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver: self forKeyPath: kUserIsSearchingForServicesNotification];
    [[NSNotificationCenter defaultCenter] removeObserver: self forKeyPath: kUserClosedSearchNotification];
}

@end
