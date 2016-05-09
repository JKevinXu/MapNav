//
//  GMPInfoWindow.h
//  MapNav
//
//  Created by XuJian on 5/3/16.
//  Copyright © 2016 Jian (Kevin) Xu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GMPInfoWindow : UIView

@property (weak, nonatomic) IBOutlet UILabel *markerName;
@property (weak, nonatomic) IBOutlet UILabel *serialNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *valueLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewMarker;
@property (weak, nonatomic) IBOutlet UIButton *buttonLike;
@property int serialNumber;

@end
