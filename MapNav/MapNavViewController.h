//
//  MapNavViewController.h
//  MapNav
//
//  Created by XuJian on 2/8/16.
//  Copyright (c) 2016 Jian (Kevin) Xu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>
@class locationAuthorizationManager;
@class ItemStore;
@class ImageStore;

@interface MapNavViewController : UIViewController <GMSMapViewDelegate, UITabBarControllerDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic) GMSMapView *mapView_;
@property (nonatomic) CLLocation *myLocation;
@property (strong, nonatomic) NSMutableArray *firstMutable;
@property (strong, nonatomic) NSMutableArray *markerArray;


- (CLLocation *)getLocationForNewMarker;

- (void)setMarkerWithItemName:(NSString *)markerItemName
              withMarkerImage:(UIImage *)markerItemImage
                withLongitude:(double)markerItemLongitude
                 withLatitude:(double)markerItemLatitude;

- (IBAction)showMarker:(id)sender;
- (IBAction)likeTapped:(id)sender;

- (instancetype)initWithItemStore:(ItemStore *)store imageStore:(ImageStore *)imageStore;

@end
