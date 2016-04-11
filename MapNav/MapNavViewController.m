//
//  MapNavViewController.m
//  MapNav
//
//  Created by XuJian on 2/8/16.
//  Copyright (c) 2016 Jian (Kevin) Xu. All rights reserved.
//

#import "MapNavViewController.h"
#import "ItemsViewController.h"
#import "ItemStore.h"
#import "ImageStore.h"
#import "DetailViewController.h"
#import "MapNavViewController.h"
#import <GoogleMaps/GoogleMaps.h>

#define ScreenHeight CGRectGetHeight([UIScreen mainScreen].bounds)
#define ScreenWidth CGRectGetWidth([UIScreen mainScreen].bounds)

@import GoogleMaps;

@interface MapNavViewController ()

@property (nonatomic) UIButton *buttonSendResponse;
@property (nonatomic) UIButton *buttonUserSendResponse;
@property (nonatomic) CLLocationManager *locationAuthorizationManager;

@end



@implementation MapNavViewController {
    GMSMapView *mapView_;
    BOOL firstLocationUpdate_;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGFloat screenWidth = CGRectGetWidth([UIScreen mainScreen].bounds);
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:38.5382
                                                            longitude:-121.7617
                                                                 zoom:40];
    
   
    mapView_ = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    mapView_.settings.compassButton = YES;
//    mapView_.padding = UIEdgeInsetsMake(200, 0, 200, 0);
    mapView_.padding =  UIEdgeInsetsMake (mapView_.frame.size.height - 200, 0, 200, 40);
    mapView_.settings.myLocationButton = YES;
    mapView_.myLocationEnabled = YES;
    
   
    
    // Listen to the myLocation property of GMSMapView.
    [mapView_ addObserver:self
               forKeyPath:@"myLocation"
                  options:NSKeyValueObservingOptionNew
                  context:NULL];
   
    self.view = mapView_;
    
    // Ask for My Location data after the map has already been added to the UI.
    dispatch_async(dispatch_get_main_queue(), ^{
        mapView_.myLocationEnabled = YES;
    });
    
     NSLog(@"User's location: %@", mapView_.myLocation);
    
    // Add a button in the main screen for set marker.
    UIButton *addButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    addButton.frame = CGRectMake(mapView_.bounds.size.width - 350, mapView_.bounds.size.height - 100, 100, 20);
    addButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
    [addButton setTitle:@"Mark Parking" forState:UIControlStateNormal];
    
    // link the button with the marking adding and deletion.
    [addButton addTarget:self action:@selector(showMarker:) forControlEvents:UIControlEventTouchUpInside];
    [mapView_ addSubview:addButton];
    
    // Add another button as clean marker.
    UIButton *cleanButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    cleanButton.frame = CGRectMake(mapView_.bounds.size.width - 200, mapView_.bounds.size.height - 100, 200, 20);
    cleanButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
    [cleanButton setTitle:@"UnMark" forState:UIControlStateNormal];
    
    // link the button with the marking adding and deletion.
    [cleanButton addTarget:self action:@selector(cleanMarker:) forControlEvents:UIControlEventTouchUpInside];
    [mapView_ addSubview:cleanButton];
    
/*
    // Add the Send Response Button.
    self.buttonSendResponse = [[UIButton alloc] initWithFrame:CGRectMake(20, 500, screenWidth, 30)];
    self.buttonSendResponse.text = @"MORE LIKE THIS";
    self.buttonSendResponse.numberOfLines = 0;
    self.buttonSendResponse.font = [UIFont boldSystemFontOfSize:16];
    self.buttonSendResponse.textAlignment = NSTextAlignmentCenter;
*/
    _buttonSendResponse = [[UIButton alloc] initWithFrame:CGRectMake(100, 80, (ScreenWidth - 10 * 3) / 2.0, 40)];
    [self.buttonSendResponse setTitle:NSLocalizedString(@"Create Spots", nil) forState:UIControlStateNormal];
    [self.buttonSendResponse setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.buttonSendResponse.backgroundColor = [UIColor colorWithRed:10.0/255.0 green:186.0/255.0 blue:181.0/255.0 alpha:0.7];
    self.buttonSendResponse.layer.cornerRadius = 4.0f;
    self.buttonSendResponse.layer.masksToBounds = YES;
    [self.buttonSendResponse addTarget:self action:@selector(presentSendResponse) forControlEvents:UIControlEventTouchUpInside];
    self.buttonSendResponse.showsTouchWhenHighlighted = YES;
    [self.view addSubview:self.buttonSendResponse];
}

// Rather than setting -myLocationEnabled to YES directly,
// call this method:

- (void)enableMyLocation
{
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    
    if (status == kCLAuthorizationStatusNotDetermined)
        [self requestLocationAuthorization];
    else if (status == kCLAuthorizationStatusDenied || status == kCLAuthorizationStatusRestricted)
        return; // we weren't allowed to show the user's location so don't enable
    else
        [mapView_ setMyLocationEnabled:YES];
}

// Ask the CLLocationManager for location authorization,
// and be sure to retain the manager somewhere on the class

- (void)requestLocationAuthorization
{
    _locationAuthorizationManager = [[CLLocationManager alloc] init];
    _locationAuthorizationManager.delegate = self;
    
    [_locationAuthorizationManager requestAlwaysAuthorization];
}

// Handle the authorization callback. This is usually
// called on a background thread so go back to main.

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (status != kCLAuthorizationStatusNotDetermined) {
        [self performSelectorOnMainThread:@selector(enableMyLocation) withObject:nil waitUntilDone:[NSThread isMainThread]];
        
        _locationAuthorizationManager.delegate = nil;
        _locationAuthorizationManager = nil;
    }
}


- (UIButton *)buttonUserSendResponse {
    if (!_buttonUserSendResponse) {
        _buttonUserSendResponse = [[UIButton alloc] initWithFrame:CGRectMake(10, ScreenHeight - 8 - 40, (ScreenWidth - 10 * 3) / 2.0, 40)];
        [_buttonUserSendResponse setTitle:NSLocalizedString(@"Send Response", nil) forState:UIControlStateNormal];
        [_buttonUserSendResponse.titleLabel setFont:[UIFont boldSystemFontOfSize:14.0]];
        [_buttonUserSendResponse setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _buttonUserSendResponse.backgroundColor = [UIColor whiteColor];
        _buttonUserSendResponse.layer.cornerRadius = 4.0f;
        _buttonUserSendResponse.layer.masksToBounds = YES;
        [_buttonUserSendResponse addTarget:self action:@selector(presentSendResponse) forControlEvents:UIControlEventTouchUpInside];
        _buttonUserSendResponse.showsTouchWhenHighlighted = YES;
    }
    return _buttonUserSendResponse;
}

- (IBAction)showMarker:(id)sender {
    // Do the marker function
    CLLocation *myLocation = mapView_.myLocation;
    CLLocationCoordinate2D position = CLLocationCoordinate2DMake(myLocation.coordinate.latitude, myLocation.coordinate.longitude);
    GMSMarker *carMarker = [GMSMarker markerWithPosition:position];
    carMarker.title = @"Your car is here";
    UIImage *carIcon = [UIImage imageNamed:@"car.png"];
    CGSize sacleSize = CGSizeMake(20, 20);
    UIGraphicsBeginImageContextWithOptions(sacleSize, NO, 0.0);
    [carIcon drawInRect:CGRectMake(0, 0, sacleSize.width, sacleSize.height)];
    UIImage * resizedCarIcon = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    carMarker.icon = resizedCarIcon;
    carMarker.opacity = 0.6;
    carMarker.flat = YES;
    
    carMarker.map = mapView_;
}

- (IBAction) cleanMarker:(id)sender {
    [mapView_ clear];
}

- (void)dealloc {
    [mapView_ removeObserver:self
                  forKeyPath:@"myLocation"
                     context:NULL];
}

#pragma mark - KVO updates

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if (!firstLocationUpdate_) {
        // If the first location update has not yet been recieved, then jump to that
        // location.
        firstLocationUpdate_ = YES;
        CLLocation *location = [change objectForKey:NSKeyValueChangeNewKey];
        mapView_.camera = [GMSCameraPosition cameraWithTarget:location.coordinate
                                                         zoom:14];
    }
}


@end