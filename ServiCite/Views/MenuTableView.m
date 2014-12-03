//
//  MenuTableView.m
//  ServiCite
//
//  Created by Mathieu White on 2014-10-31.
//  Copyright (c) 2014 Mathieu White. All rights reserved.
//

#import "MenuTableView.h"
#import "MenuTableViewCell.h"
#import "POP.h"

@interface MenuTableView ()

@property (nonatomic, strong) NSArray *menuItems;

@end

@implementation MenuTableView

#pragma mark - Initialization

- (id) init
{
    self = [super init];
    
    if (self)
    {
        [self initMenuTableView];
    }
    
    return self;
}

- (void) initMenuTableView
{
    NSLog(@"Language: %@", [[[NSBundle mainBundle] preferredLocalizations] objectAtIndex: 0]);
    NSLog(@"Region: %@", [[NSLocale currentLocale] objectForKey: NSLocaleCountryCode]);
    
    [self setBackgroundColor: [UIColor clearColor]];
    [self setSeparatorStyle: UITableViewCellSeparatorStyleNone];
    [self setScrollEnabled: NO];
    [self setDataSource: self];
    [self setDelegate: self];
    
    NSArray *menuItems = @[NSLocalizedString(@"Menu Item 1", nil), NSLocalizedString(@"Menu Item 2", nil),
                           NSLocalizedString(@"Menu Item 3", nil), NSLocalizedString(@"Menu Item 4", nil)];
    [self setMenuItems: menuItems];
    
    // Auto Layout
    [self setTranslatesAutoresizingMaskIntoConstraints: NO];
    [self setupConstraints];
    
    // Notification for when the map type changes
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(changeMapTypeMenuItem)
                                                 name: kMapTypeChangedNotification
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
    return 4;
}

- (UITableViewCell *) tableView: (UITableView *) tableView cellForRowAtIndexPath: (NSIndexPath *) indexPath
{
    static NSString *cellIdentifier = @"MenuItemCell";
    
    MenuTableViewCell *cell = (MenuTableViewCell *) [tableView dequeueReusableCellWithIdentifier: cellIdentifier];
    
    if (cell == nil)
        cell = [[MenuTableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier: cellIdentifier];
    
    [cell.titleLabel setText: [self.menuItems objectAtIndex: [indexPath row]]];
    
    if ([indexPath row] == [tableView numberOfRowsInSection: 0] - 1)
    {
        MenuTableViewCell *lastCell = [[MenuTableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier: @"lastCell"];
        [lastCell.titleLabel setText: [self.menuItems lastObject]];
        [lastCell setLastCell: YES];
        return lastCell;
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate Methods

- (void) tableView: (UITableView *) tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath
{
    NSLog(@"selected row: %ld", (long)[indexPath row]);
    
    // Points of Interest Menu Item
    if ([indexPath row] == 0)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName: kUserWantsPointsOfInterestNotification object: nil];
    }
    
    // Main Campus Menu Item
    if ([indexPath row] == 1)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName: kUserWantsMainCampusNotification object: nil];
    }
    
    // Satellite Menu Item
    if ([indexPath row] == 2)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName: kUserWantsMapTypeChangeNotification object: nil];
    }
}

- (CGFloat) tableView: (UITableView *) tableView heightForRowAtIndexPath: (NSIndexPath *) indexPath
{
    return (CGRectGetHeight([[UIScreen mainScreen] bounds]) - 128.0f) / 4.0f;
}

#pragma mark - Notification Methods

- (void) changeMapTypeMenuItem
{
    NSLog(@"change satellite to standard");
    
    // Get the third menu item
    MenuTableViewCell *mapTypeMenuItem = (MenuTableViewCell *)[self cellForRowAtIndexPath: [NSIndexPath indexPathForRow: 2 inSection: 0]];
    
    // Fade in animation
    POPBasicAnimation *fadeInAnimation = [POPBasicAnimation animationWithPropertyNamed: kPOPLayerOpacity];
    [fadeInAnimation setFromValue: @(0.0f)];
    [fadeInAnimation setToValue: @(1.0f)];
    [fadeInAnimation setDuration: 0.1];
    
    // Fade out animation
    POPBasicAnimation *fadeOutAnimation = [POPBasicAnimation animationWithPropertyNamed: kPOPLayerOpacity];
    [fadeOutAnimation setFromValue: @(1.0f)];
    [fadeOutAnimation setToValue: @(0.0f)];
    [fadeOutAnimation setDuration: 0.1];
    
    // Change the menu item content
    if ([mapTypeMenuItem.titleLabel.text isEqualToString: [self.menuItems objectAtIndex: 2]])
    {
        [fadeOutAnimation setCompletionBlock: ^(POPAnimation *anim, BOOL finished){
            [mapTypeMenuItem.titleLabel setText: NSLocalizedString(@"Menu Item 3 alt", nil)];
            [mapTypeMenuItem.layer pop_addAnimation: fadeInAnimation forKey: @"fadeInBasicAnimation"];
            
        }];
        
        [mapTypeMenuItem.layer pop_addAnimation: fadeOutAnimation forKey: @"fadeOutBasicAnimation"];
    }
    else
    {
        [fadeOutAnimation setCompletionBlock: ^(POPAnimation *anim, BOOL finished){
            [mapTypeMenuItem.titleLabel setText: [self.menuItems objectAtIndex: 2]];
            [mapTypeMenuItem.layer pop_addAnimation: fadeInAnimation forKey: @"fadeInBasicAnimation"];
            
        }];
        
        [mapTypeMenuItem.layer pop_addAnimation: fadeOutAnimation forKey: @"fadeOutBasicAnimation"];
    }
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver: self forKeyPath: kMapTypeChangedNotification];
}

@end
