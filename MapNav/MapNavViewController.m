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
#import "GMPInfoWindow.h"

#define ScreenHeight CGRectGetHeight([UIScreen mainScreen].bounds)
#define ScreenWidth CGRectGetWidth([UIScreen mainScreen].bounds)

@import GoogleMaps;

@interface MapNavViewController () <GMSMapViewDelegate>

@property (nonatomic) UIButton *buttonSendResponse;
@property (nonatomic) UIButton *buttonUserSendResponse;
@property (nonatomic) CLLocationManager *locationAuthorizationManager;
@property (nonatomic) NSString *markerItemName;
@property (nonatomic) UIImage *markerItemImage;
@property (nonatomic) BOOL *markerTapped;
@property (nonatomic) BOOL cameraMoving;
@property (nonatomic) BOOL idleAfterMovement;
@property (strong, nonatomic) GMPInfoWindow *displayedInfoWindow;
@property (strong, nonatomic) GMSMarker *currentlyTappedMarker;
@property int serialNumber;
@property (nonatomic) NSMutableSet *markerSet;

// @property (nonatomic) GMSMapView *mapView_;

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
    
    mapView_.delegate = self;
   
    
    // Listen to the myLocation property of GMSMapView.
    [mapView_ addObserver:self
               forKeyPath:@"myLocation"
                  options:NSKeyValueObservingOptionNew
                  context:NULL];
   
    self.view = mapView_;
    
//    [self.view addSubview: mapView_];

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
    [addButton addTarget:self action:@selector(showCarMarker:) forControlEvents:UIControlEventTouchUpInside];
    [mapView_ addSubview:addButton];
    
    // Add another button as clean marker.
    UIButton *cleanButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    cleanButton.frame = CGRectMake(mapView_.bounds.size.width - 200, mapView_.bounds.size.height - 100, 200, 20);
    cleanButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
    [cleanButton setTitle:@"UnMark" forState:UIControlStateNormal];
    
    // link the button with the marking adding and deletion.
    [cleanButton addTarget:self action:@selector(cleanMarker:) forControlEvents:UIControlEventTouchUpInside];
    [mapView_ addSubview:cleanButton];
    
    
    self.markerSet = [[NSMutableSet alloc] init];
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

- (CLLocation *)getLocationForNewMarker {
    [self enableMyLocation];
    [self viewDidLoad];    
    return self.mapView_.myLocation;
}

- (IBAction)presentSendResponse:(id)sender {
//    MLProductDescriptionViewController *productDescriptionViewController = [[[NSBundle mainBundle]loadNibNamed:@"MLProductDescriptionViewController" owner:nil options:NULL] firstObject];
    
    // Create an item store
    ItemStore *itemStore = [[ItemStore alloc] init];
    
    // Create the image store
    ImageStore *imageStore = [[ImageStore alloc] init];
    
    ItemsViewController *itemsViewController = [[ItemsViewController alloc] initWithItemStore:itemStore
                                                                   imageStore:imageStore];
    
//    itemsViewController = [[[NSBundle mainBundle]loadNibNamed:@"DetailViewController" owner:nil options:NULL] firstObject];
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
//    [productDescriptionViewController setupViewComponenetsForProductData:self.productData];
    UINavigationController *navController =
    [[UINavigationController alloc] initWithRootViewController:itemsViewController];

    [self.navigationController pushViewController:navController animated:YES];
}

- (IBAction)showCarMarker:(id)sender {
    // Do the marker function
    CLLocation *myLocation = mapView_.myLocation;
    CLLocationCoordinate2D position = CLLocationCoordinate2DMake(myLocation.coordinate.latitude, myLocation.coordinate.longitude);
    NSLog(@"Location longitude $%f, latitude $%f", myLocation.coordinate.longitude, myLocation.coordinate.latitude);
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


- (void)setMarkerWithItemName:(NSString *)markerItemName
              withMarkerImage:(UIImage *)markerItemImage
                withLongitude:(double)markerItemLongitude
                 withLatitude:(double)markerItemLatitude
{
    
    // [self.navigationController popViewControllerAnimated:YES];

//    [self viewDidLoad];
//    [super viewDidLoad];
    // Do the marker function
//    CLLocation *myLocation = mapView_.myLocation;
    
    self.markerItemName = markerItemName;
    self.markerItemImage = markerItemImage;
    self.serialNumber = 0;  // the initial like is 0.
    
    CLLocationCoordinate2D position = CLLocationCoordinate2DMake(markerItemLatitude, markerItemLongitude);
    GMSMarker *itemMarker = [GMSMarker markerWithPosition:position];
    itemMarker.title = markerItemName;
    itemMarker.snippet = markerItemName;
    NSLog(@"Location longitude $%f, latitude $%f", markerItemLongitude, markerItemLatitude);
    
    
    UIImage *itemIcon = markerItemImage;
    
    CGSize sacleSize = CGSizeMake(40, 30);
    UIGraphicsBeginImageContextWithOptions(sacleSize, NO, 0.0);
    [itemIcon drawInRect:CGRectMake(0, 0, sacleSize.width, sacleSize.height)];
    UIImage * resizedItemIcon = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    itemMarker.icon = resizedItemIcon;
    itemMarker.opacity = 0.8;
    itemMarker.flat = YES;
    itemMarker.map = mapView_;
    itemMarker.tracksInfoWindowChanges = YES;
    
    itemMarker.userData = @{@"serialNumber":[NSNumber numberWithInt:0]};  // used to store the serialNumber
    
    [self.markerSet addObject:itemMarker];
}


#pragma mark - GoogleMaps Delegate using googleMap API. 
// The infoWindow is a picture. No events can be triggered by tapped certainbutton in that.

/*
- (UIView *) mapView: (GMSMapView *)mapView markerInfoWindow:(GMSMarker *)marker
{
    
    
    GMPInfoWindow *infoWindow = [[[NSBundle mainBundle] loadNibNamed:@"InfoWindow"
                                                               owner:self
                                                             options:nil]
                                 objectAtIndex:0];
    infoWindow.markerName.text = self.markerItemName;
    infoWindow.imageViewMarker.image = self.markerItemImage;
    
    [infoWindow.buttonLike addTarget:infoWindow action:@selector(showCarMarker:) forControlEvents:UIControlEventTouchUpInside];
    
    return infoWindow;
    
}
*/


#pragma mark - GoogleMaps Delegate
// Since we want to display our custom info window when a marker is tapped, use this delegate method
- (BOOL)mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker *)marker{
    
    // A marker has been tapped, so set that state flag
    self.markerTapped = YES;
    
    // If a marker has previously been tapped and stored in currentlyTappedMarker, then nil it out
    if(self.currentlyTappedMarker) {
        self.currentlyTappedMarker = nil;
    }
    
    // make this marker our currently tapped marker
    self.currentlyTappedMarker = marker;
    
    // if our custom info window is already being displayed, remove it and nil the object out
    if([self.displayedInfoWindow isDescendantOfView:self.view]) {
        [self.displayedInfoWindow removeFromSuperview];
        self.displayedInfoWindow = nil;
    }
    
    /* animate the camera to center on the currently tapped marker, which causes
     mapView:didChangeCameraPosition: to be called */
    GMSCameraUpdate *cameraUpdate = [GMSCameraUpdate setTarget:marker.position];
    [mapView_ animateWithCameraUpdate:cameraUpdate];
    
    return YES;
}

- (void)mapView:(GMSMapView *)mapView didChangeCameraPosition:(GMSCameraPosition *)position{
    // cameraMoving state flag to YES
    if(self.markerTapped) {
        self.cameraMoving = YES;
    }
    
    //Move the custom info window with the map
    CGPoint markerPoint = [mapView_.projection pointForCoordinate:self.currentlyTappedMarker.position];
    CGRect frame = self.displayedInfoWindow.bounds;
    frame.origin.y = markerPoint.y - self.displayedInfoWindow.frame.size.height - 15 ;
    frame.origin.x = markerPoint.x - self.displayedInfoWindow.frame.size.width / 2;
    self.displayedInfoWindow.frame = frame;
}

/* If the map is tapped on any non-marker coordinate, reset the currentlyTappedMarker and remove our
 custom info window from self.view */
- (void)mapView:(GMSMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate{
    if(self.currentlyTappedMarker) {
        self.currentlyTappedMarker = nil;
    }
    
    if([self.displayedInfoWindow isDescendantOfView:self.view]) {
        [self.displayedInfoWindow removeFromSuperview];
        self.displayedInfoWindow = nil;
    }
}



#pragma mark create infoWindow
// This method gets called whenever the map was moving but has now stopped
- (void)mapView:(GMSMapView *)mapView idleAtCameraPosition:(GMSCameraPosition *)position{
    /* if we got here and a marker was tapped and our animate method was called, then it means we're ready
     to show our custom info window */
    if(self.markerTapped && self.cameraMoving) {
        
        // infosMarker = self.currentlyTappedMarker.userData;
        
        // reset our state first
        self.cameraMoving = NO;
        self.markerTapped = NO;
        self.idleAfterMovement = YES;
        
        
        //CREATE YOUR INFO WINDOW VIEW (CustomInfoWindow : UIView)and load it
        self.displayedInfoWindow = [[[NSBundle mainBundle] loadNibNamed:@"InfoWindow" owner:self options:nil] objectAtIndex:0];
        CGPoint markerPoint = [mapView_.projection pointForCoordinate:self.currentlyTappedMarker.position];
        CGRect frame = self.displayedInfoWindow.bounds;
        frame.origin.y = markerPoint.y - self.displayedInfoWindow.frame.size.height - 15;
        frame.origin.x = markerPoint.x - self.displayedInfoWindow.frame.size.width / 2;
        self.displayedInfoWindow.frame = frame;
        
        self.displayedInfoWindow.markerName.text = self.markerItemName;
        self.displayedInfoWindow.imageViewMarker.image = self.markerItemImage;
        // self.displayedInfoWindow.serialNumberLabel.text = [NSString stringWithFormat:@"%d", self.serialNumber];
        self.displayedInfoWindow.serialNumberLabel.text = [NSString stringWithFormat:@"%@", [self.currentlyTappedMarker.userData objectForKey:@"serialNumber"]];
        [self.displayedInfoWindow.buttonLike addTarget:self action:@selector(likeTapped:) forControlEvents:UIControlEventTouchUpInside];
        
        
        [self.view addSubview:self.displayedInfoWindow];
    }
}


- (IBAction) cleanMarker:(id)sender {
    [mapView_ clear];
}

- (void)dealloc {
    [mapView_ removeObserver:self
                  forKeyPath:@"myLocation"
                     context:NULL];
}

- (void)listSubviewsOfView:(UIView *)view {
    
    // Get the subviews of the view
    NSArray *subviews = [view subviews];
    
    // Return if there are no subviews
    if ([subviews count] == 0) return; // COUNT CHECK LINE
    
    for (UIView *subview in subviews) {
        
        if (subview == mapView_) {
           // Do what you want to do with the subview
           NSLog(@"%@", subview);
        }
        
        // List the subviews of subview
        [self listSubviewsOfView:subview];
    }
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

#pragma mark - Function of Like button in the infoWindow

- (IBAction)likeTapped:(id)sender {
    NSNumber *displayedSerialNumber = [[NSNumber alloc] init];
    NSLog(@"self.displayedInfoWindow.serialNumberLabel.text: %@", self.displayedInfoWindow.serialNumberLabel.text);
    
    displayedSerialNumber = [self.currentlyTappedMarker.userData objectForKey:@"serialNumber"];
    displayedSerialNumber = @([displayedSerialNumber integerValue] + 1);
    self.currentlyTappedMarker.userData = @{@"serialNumber":displayedSerialNumber};
    
    /*  no need to travere the markerSetArray.
    for(GMSMarker *marker in self.markerSet) {
        NSLog(@"SetMarkerName: %@", marker.snippet);
        NSLog(@"displayedInfoWindow.markerName: %@", self.displayedInfoWindow.markerName.text);
        if ([marker.snippet isEqualToString: self.displayedInfoWindow.markerName.text]) {
            displayedSerialNumber = [marker.userData objectForKey:@"serialNumber"];
            displayedSerialNumber = @([displayedSerialNumber integerValue] + 1);
            marker.userData = @{@"serialNumber":displayedSerialNumber};
            break;
        }
    }
    */
    self.displayedInfoWindow.serialNumberLabel.text = [NSString stringWithFormat:@"%@", displayedSerialNumber];
}


@end