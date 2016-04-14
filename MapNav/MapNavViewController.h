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

@interface MapNavViewController : UIViewController

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic) GMSMapView *mapView_;
@property (nonatomic) CLLocation *myLocation;

- (CLLocation *)getLocationForNewMarker;

- (void)setMarkerWithMarkerImage:(UIImage *)markerItemImage
                    withLongitude:(double)markerLongitude
                     withLatitude:(double)markerLatitude;

- (IBAction)showMarker:(id)sender;

@end
