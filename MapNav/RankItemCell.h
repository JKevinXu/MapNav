//
//  RankItemCell.h
//  MapNav
//
//  Created by XuJian on 5/9/16.
//  Copyright © 2016 Jian (Kevin) Xu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RankItemCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *likeNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *dislikeNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *rankLabel;
@property (weak, nonatomic) IBOutlet UILabel *bRatingLabel;
@property (weak, nonatomic) IBOutlet UILabel *lBWScoreLabel;
@property (strong, nonatomic) IBOutlet UIImageView *imageViewMarker;


@end
