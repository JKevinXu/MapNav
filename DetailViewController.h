//
//  DetailViewController.h
//  Homepwner
//
//  Created by XuJian on 1/16/16.
//  Copyright (c) 2016 Jian (Kevin) Xu. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Item;
@class ImageStore;

@interface DetailViewController : UIViewController
    <UINavigationControllerDelegate, UIImagePickerControllerDelegate>
- (instancetype) initWithItem:(Item *)item imageStore:(ImageStore *)imgStore;
@end
