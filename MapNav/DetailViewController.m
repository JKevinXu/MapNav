//
//  DetailViewController.m
//  Homepwner
//
//  Created by XuJian on 1/16/16.
//  Copyright (c) 2016 Jian (Kevin) Xu. All rights reserved.
//

#import "DetailViewController.h"
#import "MapNavViewController.h"
#import "Item.h"
#import "ImageStore.h"
#import <GoogleMaps/GoogleMaps.h>

@import GoogleMaps;

@interface DetailViewController ()
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *likeNumberField;
@property (weak, nonatomic) IBOutlet UITextField *longitudeField;
@property (weak, nonatomic) IBOutlet UITextField *latitudeField;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIToolbar *toolBar;
@property (nonatomic) CLLocationManager *locationAuthorizationManager;

// @property (nonatomic) Item *item;
@property (nonatomic) ImageStore *imageStore;
@end

@implementation DetailViewController {
   GMSMapView *mapView_;
   BOOL firstLocationUpdate_;
}

- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    // Get the chosen image from the info dictionary
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    
    // Store the image in the image store
    [self.imageStore setImage:image forKey:self.item.itemKey];
    
    // Put the image into the image view
    self.imageView.image = image;
    
    // Dismiss teh image picker
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}


- (IBAction)backgroundTapped:(id)sender {
    [self.view endEditing:YES];
}

- (void)takePicture {
    UIImagePickerController *ipc = [[UIImagePickerController alloc] init];
    
    // If the device has a camara, take a picture
    // Otherwise, pick from library
    if ([UIImagePickerController
           isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        ipc.sourceType = UIImagePickerControllerSourceTypeCamera;
    } else {
        ipc.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    
    ipc.delegate = self;
    
    // put the image picker on the screen
    [self presentViewController:ipc animated:YES completion:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // Clear first responder
    [self.view endEditing:YES];
    
    // Update the item with the text field contents
    self.item.name = self.nameField.text;
    self.item.likeNumber = self.likeNumberField.text;
    self.item.longitude = [self.longitudeField.text doubleValue];
    self.item.latitude = [self.latitudeField.text doubleValue];
}

// do a mapViewController and use the 
- (IBAction)pictureButtonPressed:(UIBarButtonItem *)sender {
    [self takePicture];
//    MapNavViewController *mapNavViewController = [[MapNavViewController alloc] init];
//    CLLocation *myLocation = [mapNavViewController getLocationForNewMarker];
    
    CLLocation *myLocation = mapView_.myLocation;

    //    CLLocationCoordinate2D position = CLLocationCoordinate2DMake(myLocation.coordinate.latitude, myLocation.coordinate.longitude);
    
    // store position in the array.
    self.item.longitude = myLocation.coordinate.longitude;
    self.item.latitude = myLocation.coordinate.latitude;
    
    // update location in the box.
    self.longitudeField.text =
    [NSString stringWithFormat:@"%f", self.item.longitude];
    self.latitudeField.text =
    [NSString stringWithFormat:@"%f", self.item.latitude];
}




- (void)viewDidAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // import values from the current item to the UI
    self.nameField.text = self.item.name;
    self.likeNumberField.text = self.item.likeNumber;
    self.longitudeField.text =
    [NSString stringWithFormat:@"%f", self.item.longitude];
    self.latitudeField.text =
    [NSString stringWithFormat:@"%f", self.item.latitude];
    
    // represent the date created legibly
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateStyle = NSDateFormatterMediumStyle;
    dateFormatter.timeStyle = NSDateFormatterNoStyle;
    self.dateLabel.text = [dateFormatter stringFromDate:self.item.dateCreated];
    
    // Display the items image, if there is one for it in the image store
    UIImage *itemImage = [self.imageStore imageForKey:self.item.itemKey];
    self.imageView.image = itemImage;
}


- (instancetype)initWithItem:(Item *)item
                  imageStore:(ImageStore *)imgStore {
    
    self = [super initWithNibName:@"DetailViewController" bundle:nil];
    if (self) {
        _item = item;
        self.navigationItem.title = item.name;
        _imageStore = imgStore;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:38.5382
                                                            longitude:-121.7617
                                                                 zoom:40];
    
    
    mapView_ = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    mapView_.myLocationEnabled = YES;
    
    /*
    // Listen to the myLocation property of GMSMapView.
    [mapView_ addObserver:self
               forKeyPath:@"myLocation"
                  options:NSKeyValueObservingOptionNew
                  context:NULL];
    
    */
    
    // Ask for My Location data after the map has already been added to the UI.
    dispatch_async(dispatch_get_main_queue(), ^{
        mapView_.myLocationEnabled = YES;
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

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
