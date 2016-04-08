//
//  ItemCell.h
//  MapNav
//
//  Created by XuJian on 1/15/16.
//  Copyright (c) 2016 Jian (Kevin) Xu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ItemCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *serialNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *valueLabel;

@end
