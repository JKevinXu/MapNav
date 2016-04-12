//
//  DetailViewController.m
//  Homepwner
//
//  Created by XuJian on 1/16/16.
//  Copyright (c) 2016 Jian (Kevin) Xu. All rights reserved.
//

#import "DetailViewController.h"
#import "Item.h"
#import "ImageStore.h"

@interface DetailViewController ()
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *serialNumberField;
@property (weak, nonatomic) IBOutlet UITextField *valueField;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIToolbar *toolBar;

@property (nonatomic) Item *item;
@property (nonatomic) ImageStore *imageStore;
@end

@implementation DetailViewController

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

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // Clear first responder
    [self.view endEditing:YES];
    
    // Update the item with the text field contents
    self.item.name = self.nameField.text;
    self.item.serialNumber = self.serialNumberField.text;
    self.item.valueInDollars = [self.valueField.text intValue];
    
    // Display the items image, if there is one for it in the image store
    UIImage *itemImage = [self.imageStore imageForKey:self.item.itemKey];
    self.imageView.image = itemImage;
    
}
- (IBAction)pictureButtonPressed:(UIBarButtonItem *)sender {
    [self takePicture];
}



- (void)viewDidAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // import values from the current item to the UI
    self.nameField.text = self.item.name;
    self.serialNumberField.text = self.item.serialNumber;
    self.valueField.text =
    [NSString stringWithFormat:@"%d", self.item.valueInDollars];
    
    // represent the date created legibly
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateStyle = NSDateFormatterMediumStyle;
    dateFormatter.timeStyle = NSDateFormatterNoStyle;
    self.dateLabel.text = [dateFormatter stringFromDate:self.item.dateCreated];
    
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

@end
