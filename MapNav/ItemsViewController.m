//
//  ItemsViewController.m
//  MapNav
//
//  Created by XuJian on 1/15/16.
//  Copyright (c) 2016 Jian (Kevin) Xu. All rights reserved.
//

#import "ItemsViewController.h"
#import "ItemStore.h"
#import "Item.h"
#import "ItemCell.h"
#import "DetailViewController.h"
#import "ImageStore.h"
#import "MapNavViewController.h"

@interface ItemsViewController ()

@property (nonatomic) ItemStore *itemStore;
@property (nonatomic) ImageStore *imageStore;
@property (nonatomic) UIButton *buttonSendResponse;

@end

@implementation ItemsViewController


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.tableView reloadData];
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Get the item for the selected row
    Item *itemToShow = self.itemStore.allItems[indexPath.row];
    
    // Create a detail view controller
    DetailViewController *dvc =
    [[DetailViewController alloc] initWithItem:itemToShow
                                  imageStore:self.imageStore];
    
    
    // Push it onto the navigation stack
    [self showViewController:dvc sender:self];
}


- (instancetype)initWithItemStore:(ItemStore *)store imageStore:(ImageStore *)imageStore {
// - (instancetype)initWithItemStore:imageStore {
    self = [super initWithStyle:UITableViewStylePlain]; // call super's designated init
    if (self) {
        _itemStore = store;
        _imageStore = imageStore;
        self.navigationItem.title = @"MapNav";
   
    // Create a new bar button item that will send addNewItem: to this VC
    UIBarButtonItem *barItem =
         [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                       target:self
                                                       action:@selector(addNewItem:)];
    
    // Set barItem as the rightmost button in the nav bar for this VC
        self.navigationItem.rightBarButtonItem = barItem;
        
        self.navigationItem.leftBarButtonItem = [self editButtonItem];
    }
    return self;
}

- (instancetype)initWithStyle:(UITableViewStyle)style { // override super's designated init
    [NSException raise:@"Wrong Initializer"
                format:@"Use initWithItemStore: instead of initWithStyle:!"];
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    return self.itemStore.allItems.count;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 281.0f;
}


- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Get a new or recycled cell
    ItemCell *cell =
       [self.tableView dequeueReusableCellWithIdentifier:@"ItemCell"
                                            forIndexPath:indexPath];
    
    // Set the text on the cell with the description of an item at
    // the nth index of the item array, where n = this cell's row number
    // Configure the cell with the Item's properties
    Item *item = self.itemStore.allItems[indexPath.row];
    cell.nameLabel.text = item.name;
    cell.serialNumberLabel.text = item.serialNumber;
    
    UIImage *itemImage = [self.imageStore imageForKey:item.itemKey];
    cell.imageViewMarker.image = itemImage;
    
    
  
    [cell.buttonPutMarkerInMap setTag:indexPath.row];
//    [self setMarker:cell.buttonPutMarkerInMap];
    
    [cell.buttonPutMarkerInMap addTarget:self action:@selector(setMarker:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
    
}

- (IBAction)setMarker:(id)sender {
//    MapNavViewController *mapNavViewController = [[MapNavViewController alloc] init];
//    VC1 *myVC1ref = (VC1 *)[self.tabBarController.viewControllers objectAtIndex:0];
    
     MapNavViewController *mapNavViewController = (MapNavViewController *)[self.tabBarController.viewControllers objectAtIndex:0];

     NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[sender tag] inSection:0];
     Item *itemForCell = self.itemStore.allItems[indexPath.row];
     double itemLongitude = itemForCell.longitude;
     double itemLatitude = itemForCell.latitude;
     NSString *itemName = itemForCell.name;
     UIImage *itemImage = [self.imageStore imageForKey:itemForCell.itemKey];
    [mapNavViewController setMarkerWithItemName:itemName
                                withMarkerImage:itemImage
                                  withLongitude:itemLongitude
                                   withLatitude:itemLatitude];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Load the ItemCell nib
    UINib *itemCellNib = [UINib nibWithNibName:@"ItemCell" bundle:nil];
    
    // Register this nib as the template for new ItemCells
    [self.tableView registerNib:itemCellNib forCellReuseIdentifier:@"ItemCell"];    
/*
    UIButton *buttonSendResponse = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    buttonSendResponse.frame = CGRectMake(80, 300, 100, 40);
    buttonSendResponse.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;

    
    [buttonSendResponse setTitle:NSLocalizedString(@"Set Markers", nil) forState:UIControlStateNormal];
    [buttonSendResponse setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    buttonSendResponse.backgroundColor = [UIColor colorWithRed:10.0/255.0 green:186.0/255.0 blue:181.0/255.0 alpha:0.7];
    buttonSendResponse.layer.cornerRadius = 4.0f;
    buttonSendResponse.layer.masksToBounds = YES;
    
//    MapNavViewController *mapNavViewController = [[MapNavViewController alloc] init];
//    [buttonSendResponse addTarget:mapNavViewController action:@selector(helloWorld:) forControlEvents:UIControlEventTouchUpInside];
    
//    [mapNavViewController showMarker:buttonSendResponse];
    
    buttonSendResponse.showsTouchWhenHighlighted = YES;
    [self.view addSubview:buttonSendResponse];
    
    UIImage *image = [UIImage imageNamed:@"MapMarker.png"];
    ImageStore *setImageSize = [[ImageStore alloc] init];
    self.tabBarItem.image = [setImageSize imageWithImage:image scaledToSize:CGSizeMake(30, 30)];
    
    if (self){
        self.tabBarItem.title = @"Set Markers";
        self.tabBarItem.image = [UIImage imageNamed:@"MapMarker.png"];
    }
*/
}

- (IBAction)helloWorld:(id)sender {
    NSLog(@"Hello World!");
}

- (IBAction)addNewItem:(id)sender {
    // Create a new item and add it to the store
    Item *newItem = [self.itemStore createItem];
    
    // Figure out the item's index in the items array
    NSInteger index = [self.itemStore.allItems indexOfObjectIdenticalTo:newItem];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection: 0];

    // Insert a row at this indexpath in the table
    [self.tableView insertRowsAtIndexPaths:@[indexPath]
                          withRowAnimation:UITableViewRowAnimationTop];
}

- (void)tableView:(UITableView *)tableView
moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath
      toIndexPath:(NSIndexPath *)destinationIndexPath {
    // Update the array
    [self.itemStore moveItemAtIndex:sourceIndexPath.row
                            toIndex:destinationIndexPath.row];
}

- (void)tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath {
    // If the table is asking to commit a delete operation...
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        // Find the item to delete and remove it from the ItemStore
        Item *item = self.itemStore.allItems[indexPath.row];
        [self.itemStore removeItem:item];
        
        // Also remove its image from the image store
        [self.imageStore setImage:nil forKey:item.itemKey];
        
        // Also, remove the deleted row from the table
        [self.tableView deleteRowsAtIndexPaths:@[indexPath]
                              withRowAnimation:UITableViewRowAnimationFade];
        
    }
}


@end












