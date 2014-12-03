//
//  MenuTableViewCell.h
//  ServiCite
//
//  Created by Mathieu White on 2014-11-03.
//  Copyright (c) 2014 Mathieu White. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MenuTableViewCell : UITableViewCell

@property (nonatomic, weak) UIImageView *cellImage;
@property (nonatomic, weak) UILabel *titleLabel;
@property (nonatomic, assign) BOOL lastCell;

@end
