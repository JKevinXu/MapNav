//
//  ItemsViewController.h
//  MapNav
//
//  Created by XuJian on 1/15/16.
//  Copyright (c) 2016 Jian (Kevin) Xu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class ItemStore;
@class ImageStore;

@interface ItemsViewController : UITableViewController

- (instancetype)initWithItemStore:(ItemStore *)store imageStore:(ImageStore *)imageStore;
// - (instancetype)initWithItemStore:(ItemStore *)imageStore;

@end
