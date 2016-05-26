//
//  MapNavViewController.m
//  MapNav
//
//  Created by XuJian on 2/8/16.
//  Copyright (c) 2016 Jian (Kevin) Xu. All rights reserved.
//

#import "MapNavViewController.h"
#import "ItemsViewController.h"
#import "RankItemsViewController.h"
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
@property int likeNumber;
@property (nonatomic) UIButton *buttonViewRank;
@property int totalLike;
@property int totalDislike;
@property int numOfMarkers;
// @property (nonatomic) GMSMapView *mapView_;

@end

@implementation MapNavViewController {
    
    GMSMapView *mapView_;
    BOOL firstLocationUpdate_;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tabBarController.delegate = self;
    self.firstMutable = [[NSMutableArray alloc] initWithObjects:@"item 1", @"item 2", nil];
    
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
    
    self.markerArray = [[NSMutableArray alloc] init];
    
    self.totalLike = 0;
    self.totalDislike = 0;
    self.numOfMarkers = 0;
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
    self.markerItemName = markerItemName;
    self.markerItemImage = markerItemImage;
    self.likeNumber = 0;  // the initial like is 0.
    
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
    
    // get the currentTime when the marker is created.
    NSString *markingTime = [self getCurrentTime];
    NSLog(@"The marking time is: %@", markingTime);
    
    NSMutableArray *likesTimeStampArray = [[NSMutableArray alloc] init];
    NSMutableArray *dislikesTimeStampArray = [[NSMutableArray alloc] init];
    
    itemMarker.userData = @{@"likeNumber": [NSNumber numberWithInt:0],
                            @"dislikeNumber": [NSNumber numberWithInt:0],
                            @"markerImage": markerItemImage,
                            @"bRatingNumber": [NSNumber numberWithInt:0],
                            @"lBWScoreNumber": [NSNumber numberWithInt:0],
                            @"markingTime": markingTime,
                            @"likesTimeStampArray": likesTimeStampArray,
                            @"dislikesTimeStampArray": dislikesTimeStampArray
                            };
    // used to store the likeNumber
    
    [self.markerArray addObject:itemMarker];
    self.numOfMarkers ++;
    NSLog(@"num of markers in map: %d", self.numOfMarkers);
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
        
        self.displayedInfoWindow.markerName.text = self.currentlyTappedMarker.snippet;
        self.displayedInfoWindow.imageViewMarker.image = [self.currentlyTappedMarker.userData objectForKey:@"markerImage"];
        // self.displayedInfoWindow.likeNumberLabel.text = [NSString stringWithFormat:@"%d", self.likeNumber];
        self.displayedInfoWindow.likeNumberLabel.text = [NSString stringWithFormat:@"%@", [self.currentlyTappedMarker.userData objectForKey:@"likeNumber"]];
        self.displayedInfoWindow.dislikeNumberLabel.text = [NSString stringWithFormat:@"%@", [self.currentlyTappedMarker.userData objectForKey:@"dislikeNumber"]];
        [self.displayedInfoWindow.buttonLike addTarget:self action:@selector(likeTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self.displayedInfoWindow.buttondislike addTarget:self action:@selector(dislikeTapped:) forControlEvents:UIControlEventTouchUpInside];
        
        
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
    NSNumber *displayedlikeNumber = [[NSNumber alloc] init];
    NSNumber *displayedDislikeNumber = [[NSNumber alloc] init];
    UIImage  *markerImage = [[UIImage alloc] init];
    NSNumber *bRatingNumber = [[NSNumber alloc] init];
    NSNumber *lBWScoreNumber = [[NSNumber alloc] init];
    NSString *markingTime = [[NSString alloc] init];
    NSMutableArray *likesTimeStampArray = [[NSMutableArray alloc] init];
    NSMutableArray *dislikesTimeStampArray = [[NSMutableArray alloc] init];

    // increase likeNumber by 1.
    displayedlikeNumber = [self.currentlyTappedMarker.userData objectForKey:@"likeNumber"];
    displayedlikeNumber = @([displayedlikeNumber integerValue] + 1);
    
    // temperarily store markerImage.
    markerImage = [self.currentlyTappedMarker.userData objectForKey:@"markerImage"];
    
    // temperarily store dislikeNumber.
    displayedDislikeNumber = [self.currentlyTappedMarker.userData objectForKey:@"dislikeNumber"];
    
    // calculate bRating.
    CGFloat bRating = [self getBratingWithNumOfLikeForOneMarker: [displayedlikeNumber integerValue]
                                     withNumOfDislikeForOneMarker: [displayedDislikeNumber integerValue]];
    bRatingNumber = @(bRating);
    
    
    // calculate lBWScore.
    CGFloat lBWScore = [self getLBWScoreWithNumOfLikeForOneMarker: [displayedlikeNumber integerValue]
                                   withNumOfDislikeForOneMarker: [displayedDislikeNumber integerValue]];
    lBWScoreNumber = @(lBWScore);
    
    // temperarily store markingTime.
    markingTime = [self.currentlyTappedMarker.userData objectForKey:@"markingTime"];
    
    // get the likeTappedTime time, and store it in the like array.
    NSString *likeTappedTime = [self getCurrentTime];
    NSLog(@"The likeTappedTime time is: %@", likeTappedTime);
    likesTimeStampArray = [self.currentlyTappedMarker.userData objectForKey:@"likesTimeStampArray"];
    [likesTimeStampArray addObject:likeTappedTime];
    NSLog(@"The likesTimeStampArray is: %@", likesTimeStampArray);
    
    // temperarily store dislikesTimeStampArray.
    dislikesTimeStampArray = [self.currentlyTappedMarker.userData objectForKey:@"dislikesTimeStampArray"];
    
    
    self.currentlyTappedMarker.userData = @{@"likeNumber": displayedlikeNumber,
                                            @"dislikeNumber": displayedDislikeNumber,
                                            @"markerImage": markerImage,
                                            @"bRatingNumber": bRatingNumber,
                                            @"lBWScoreNumber": lBWScoreNumber,
                                            @"markingTime": markingTime,
                                            @"likesTimeStampArray": likesTimeStampArray,
                                            @"dislikesTimeStampArray": dislikesTimeStampArray
                                           };
    
    self.displayedInfoWindow.likeNumberLabel.text = [NSString stringWithFormat:@"%@", displayedlikeNumber];
    self.displayedInfoWindow.dislikeNumberLabel.text = [NSString stringWithFormat:@"%@", displayedDislikeNumber];
    
    self.totalLike ++;
    NSLog(@"num of total likes: %d", self.totalLike);
    NSLog(@"bRating is: %@", bRatingNumber);
    NSLog(@"lBWScore is: %@", lBWScoreNumber);
}

- (IBAction)dislikeTapped:(id)sender {
    NSNumber *displayedlikeNumber = [[NSNumber alloc] init];
    NSNumber *displayedDislikeNumber = [[NSNumber alloc] init];
    UIImage  *markerImage = [[UIImage alloc] init];
    NSNumber *bRatingNumber = [[NSNumber alloc] init];
    NSNumber *lBWScoreNumber = [[NSNumber alloc] init];
    NSString *markingTime = [[NSString alloc] init];
    NSMutableArray *likesTimeStampArray = [[NSMutableArray alloc] init];
    NSMutableArray *dislikesTimeStampArray = [[NSMutableArray alloc] init];
    
    // increase dislikeNumber by 1.
    displayedDislikeNumber = [self.currentlyTappedMarker.userData objectForKey:@"dislikeNumber"];
    displayedDislikeNumber = @([displayedDislikeNumber integerValue] + 1);
    
    // temperarily store markerImage and displayedlikeNumber.
    markerImage = [self.currentlyTappedMarker.userData objectForKey:@"markerImage"];
    displayedlikeNumber = [self.currentlyTappedMarker.userData objectForKey:@"likeNumber"];
    
    // calculate bRating.
    CGFloat bRating = [self getBratingWithNumOfLikeForOneMarker: [displayedlikeNumber integerValue]
                               withNumOfDislikeForOneMarker: [displayedDislikeNumber integerValue]];
    bRatingNumber = @(bRating);
    
    
    // calculate lBWScore.
    CGFloat lBWScore = [self getLBWScoreWithNumOfLikeForOneMarker: [displayedlikeNumber integerValue]
                                     withNumOfDislikeForOneMarker: [displayedDislikeNumber integerValue]];
    lBWScoreNumber = @(lBWScore);
    
    // temperarily store markingTime.
    markingTime = [self.currentlyTappedMarker.userData objectForKey:@"markingTime"];
    
    // temperarily store likesTimeStampArray.
    likesTimeStampArray = [self.currentlyTappedMarker.userData objectForKey:@"likesTimeStampArray"];
    
    // get the dislikeTappedTime time, and store it in the like array.
    NSString *dislikeTappedTime = [self getCurrentTime];
    NSLog(@"The dislikeTappedTime time is: %@", dislikeTappedTime);
    dislikesTimeStampArray = [self.currentlyTappedMarker.userData objectForKey:@"dislikesTimeStampArray"];
    [dislikesTimeStampArray addObject:dislikeTappedTime];
    NSLog(@"The dislikesTimeStampArray is: %@", dislikesTimeStampArray);
    
    self.currentlyTappedMarker.userData = @{@"likeNumber": displayedlikeNumber,
                                            @"dislikeNumber": displayedDislikeNumber,
                                            @"markerImage": markerImage,
                                            @"bRatingNumber": bRatingNumber,
                                            @"lBWScoreNumber": lBWScoreNumber,
                                            @"markingTime": markingTime,
                                            @"likesTimeStampArray": likesTimeStampArray,
                                            @"dislikesTimeStampArray": dislikesTimeStampArray
                                            };
    
    self.displayedInfoWindow.likeNumberLabel.text = [NSString stringWithFormat:@"%@", displayedlikeNumber];
    self.displayedInfoWindow.dislikeNumberLabel.text = [NSString stringWithFormat:@"%@", displayedDislikeNumber];
    
    self.totalDislike ++;
    NSLog(@"num of total disLikes: %d", self.totalDislike);
    NSLog(@"bRating is: %@", bRatingNumber);
    NSLog(@"lBWScore is: %@", lBWScoreNumber);
    
}


- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    if ([viewController isKindOfClass:[RankItemsViewController class]]){
        RankItemsViewController *rankItemsViewController = (RankItemsViewController *) viewController;
        NSMutableArray *sortedMarkerArrayByLike = [self sortMarkerArrayByLike:self.markerArray];
        rankItemsViewController.markerArray = sortedMarkerArrayByLike;
        
        // NSMutableArray *sortedMarkerArrayBydislike = [self sortMarkerArrayByUnike:self.markerArray];
        // rankItemsViewController.markerdislikeArray = sortedMarkerArrayBydislike;
        
        NSMutableArray *sortedMarkerArrayByLBWScore = [self sortMarkerArrayByLBWScore:self.markerArray];
        rankItemsViewController.markerLBWScoreArray = sortedMarkerArrayByLBWScore;
        
        NSMutableArray *sortedMarkerArrayByBRating = [self sortMarkerArrayByBRating:self.markerArray];
        rankItemsViewController.markerBRatingArray = sortedMarkerArrayByBRating;
    }
    return TRUE;
}

- (CGFloat)getBratingWithNumOfLikeForOneMarker: (NSInteger) numLike
              withNumOfDislikeForOneMarker: (NSInteger) numDislike {
    
    CGFloat aveTotalVotes = (self.totalLike + self.totalDislike) / self.numOfMarkers;
    CGFloat aveRating = (self.totalLike - self.totalDislike) / self.numOfMarkers;
    NSInteger thisMarkerTotalVotes = (numLike + numDislike);
    NSInteger thisMarkerRating = (numLike - numDislike);
    CGFloat bRating = (aveTotalVotes * aveRating + thisMarkerTotalVotes * thisMarkerRating)/(aveTotalVotes + thisMarkerTotalVotes);
    
    // bRating = numLike + numDislike;
    
    return bRating;
}

- (CGFloat)getLBWScoreWithNumOfLikeForOneMarker: (NSInteger) numLike
                  withNumOfDislikeForOneMarker: (NSInteger) numDislike {
    
    CGFloat LBWScore = ((numLike + 1.9208) / (numLike + numDislike) -
     1.96 * sqrt((numLike * numDislike) / (numLike + numDislike) + 0.9604) /
     (numLike + numDislike)) / (1 + 3.8416 / (numLike + numDislike));
    
    return LBWScore;
}

/*
- (void) sortMarkerArray:(NSMutableArray *) markerArray {
    GMSMarker *marker;
    NSSortDescriptor *sorter = [[NSSortDescriptor alloc] initWithKey:[marker.userData objectForKey:@"likeNumber"]  ascending:NO];
    [self.markerArray sortUsingDescriptors:[NSArray arrayWithObject:sorter]];
}
*/

- (NSMutableArray *) sortMarkerArrayByLike:(NSMutableArray *) markerArray {
    NSMutableArray *sortedMarkerArray = [markerArray sortedArrayUsingComparator:^(id obj1, id obj2){
        if ([obj1 isKindOfClass:[GMSMarker class]] && [obj2 isKindOfClass:[GMSMarker class]]) {
            GMSMarker *m1 = obj1;
            GMSMarker *m2 = obj2;
            NSNumber *like_m1 = [m1.userData objectForKey:@"likeNumber"];
            NSNumber *like_m2 = [m2.userData objectForKey:@"likeNumber"];
            if (like_m1 > like_m2) {
                return (NSComparisonResult)NSOrderedAscending;
            } else if (like_m1 < like_m2) {
                return (NSComparisonResult)NSOrderedDescending;
            }
        }
        // TODO: default is the same?
        return (NSComparisonResult) NSOrderedSame;
    }];
    return sortedMarkerArray;
}

- (NSMutableArray *) sortMarkerArrayByUnike:(NSMutableArray *) markerArray {
    NSMutableArray *sortedMarkerArray = [markerArray sortedArrayUsingComparator:^(id obj1, id obj2){
        if ([obj1 isKindOfClass:[GMSMarker class]] && [obj2 isKindOfClass:[GMSMarker class]]) {
            GMSMarker *m1 = obj1;
            GMSMarker *m2 = obj2;
            NSNumber *like_m1 = [m1.userData objectForKey:@"dislikeNumber"];
            NSNumber *like_m2 = [m2.userData objectForKey:@"dislikeNumber"];
            if (like_m1 > like_m2) {
                return (NSComparisonResult)NSOrderedAscending;
            } else if (like_m1 < like_m2) {
                return (NSComparisonResult)NSOrderedDescending;
            }
        }
        // TODO: default is the same?
        return (NSComparisonResult) NSOrderedSame;
    }];
    return sortedMarkerArray;
}

- (NSMutableArray *) sortMarkerArrayByBRating:(NSMutableArray *) markerArray {
    NSMutableArray *sortedMarkerArray = [markerArray sortedArrayUsingComparator:^(id obj1, id obj2){
        if ([obj1 isKindOfClass:[GMSMarker class]] && [obj2 isKindOfClass:[GMSMarker class]]) {
            GMSMarker *m1 = obj1;
            GMSMarker *m2 = obj2;
            NSNumber *like_m1 = [m1.userData objectForKey:@"bRatingNumber"];
            NSNumber *like_m2 = [m2.userData objectForKey:@"bRatingNumber"];
            CGFloat bRating_1 = [like_m1 floatValue];
            CGFloat bRating_2 = [like_m2 floatValue];
            
            if (bRating_1 > bRating_2) {
                return (NSComparisonResult)NSOrderedAscending;
            } else if (bRating_1 < bRating_2) {
                return (NSComparisonResult)NSOrderedDescending;
            }
        }
        // TODO: default is the same?
        return (NSComparisonResult) NSOrderedSame;
    }];
    return sortedMarkerArray;
}

- (NSMutableArray *) sortMarkerArrayByLBWScore:(NSMutableArray *) markerArray {
    NSMutableArray *sortedMarkerArray = [markerArray sortedArrayUsingComparator:^(id obj1, id obj2){
        if ([obj1 isKindOfClass:[GMSMarker class]] && [obj2 isKindOfClass:[GMSMarker class]]) {
            GMSMarker *m1 = obj1;
            GMSMarker *m2 = obj2;
            NSNumber *like_m1 = [m1.userData objectForKey:@"lBWScoreNumber"];
            NSNumber *like_m2 = [m2.userData objectForKey:@"lBWScoreNumber"];
            CGFloat lBWScore_1 = [like_m1 floatValue];
            CGFloat lBWScore_2 = [like_m2 floatValue];
            
            if (lBWScore_1 > lBWScore_2) {
                return (NSComparisonResult)NSOrderedAscending;
            } else if (lBWScore_1 < lBWScore_2) {
                return (NSComparisonResult)NSOrderedDescending;
            }
        }
        // TODO: default is the same?
        return (NSComparisonResult) NSOrderedSame;
    }];
    return sortedMarkerArray;
}


#pragma mark - Convert the current time to "yyyy-MM-dd'T'HH:mm:ss.SSS'Z" format.
- (NSString *)toStringFromDateTime:(NSDate*)datetime {
    // Purpose: Return a string of the specified date-time in UTC (Zulu) time zone in ISO 8601 format.
    // Example: 2013-10-25T06:59:43.431Z
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
    NSString* dateTimeInIsoFormatForZuluTimeZone = [dateFormatter stringFromDate:datetime];
    return dateTimeInIsoFormatForZuluTimeZone;
}


- (NSString *) getCurrentTime {
    // Purpose: Return a string of the current date-time in UTC (Zulu) time zone in ISO 8601 format.
    return [self toStringFromDateTime:[NSDate date]];
}

/*
 - (IBAction)viewRank:(id)sender {
 // Create an item store
 ItemStore *itemStore = [[ItemStore alloc] init];
 
 // Create the image store
 ImageStore *imageStore = [[ImageStore alloc] init];
 
 // RankItemsViewController *rankItemsViewController = [[[NSBundle mainBundle] loadNibNamed:@"MLProductDescriptionViewController" owner:nil options:NULL] firstObject];
 
 // Create an RankItemsViewController
 RankItemsViewController *rankItemsViewController = [[RankItemsViewController alloc] initWithItemStore:itemStore
 imageStore:imageStore];
 
 
 // [rankItemsViewController setupRankForMarkerArray:self.markerSet];
 [self showViewController:rankItemsViewController sender:self];
 
 }
 */


@end