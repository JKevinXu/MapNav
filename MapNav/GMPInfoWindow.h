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
@property (weak, nonatomic) IBOutlet UILabel *likeNumberLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewMarker;
@property (weak, nonatomic) IBOutlet UIButton *buttonLike;
@property (weak, nonatomic) IBOutlet UIButton *buttondislike;
@property (weak, nonatomic) IBOutlet UILabel *dislikeNumberLabel;
@property int likeNumber;

@end
