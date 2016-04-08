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

@interface ItemsViewController ()

@property (nonatomic) ItemStore *itemStore;
@property (nonatomic) ImageStore *imageStore;

// - (instancetype) initWithItem:(Item *)item imageStore:(ImageStore *)imageStore;
// - (instancetype) initWithItemStore: imageStore;

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
    cell.valueLabel.text = [NSString stringWithFormat:@"$%d", item.valueInDollars];
    
    return cell;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Load the ItemCell nib
    UINib *itemCellNib = [UINib nibWithNibName:@"ItemCell" bundle:nil];
    
    // Register this nib as the template for new ItemCells
    [self.tableView registerNib:itemCellNib forCellReuseIdentifier:@"ItemCell"];
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












