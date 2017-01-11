//
//  ItemStore.m
//  MapNav
//
//  Created by XuJian on 1/15/16.
//  Copyright (c) 2016 Jian (Kevin) Xu. All rights reserved.
//

#import "ItemStore.h"
#import "Item.h"
#import <UIKit/UIKit.h>

@interface ItemStore ()
@property (nonatomic) NSMutableArray *items;
@end

@implementation ItemStore

- (instancetype)init {
    self = [super init];
    if (self) {
    _items = [NSMutableArray array];
    NSString *archivePath = [self itemArchivePath];
    NSArray *archivedItems =
    [NSKeyedUnarchiver unarchiveObjectWithFile:archivePath];
    [_items addObjectsFromArray:archivedItems];
        
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self
           selector:@selector(observeAppEnteredBackgroundNotification:)
               name:UIApplicationDidEnterBackgroundNotification
             object:[UIApplication sharedApplication]];
    }

    return self;
}

- (NSArray *)allItems {
    return [self.items copy];
}

#pragma mark - items creation, deletion and moving

- (Item *)createItem {
//    Item *newItem = [Item randomItem];
    Item *newItem = [Item new];
    [self.items addObject:newItem];
    return newItem;
}

- (void)removeItem:(Item *)item {
    [self.items removeObject:item];
}

- (void)moveItemAtIndex:(NSInteger)source
                toIndex:(NSInteger)destination {
    if (source == destination){
        return;
    }
    
    // Get a pointer to the object being removed so you can re-insert it
    id movedItem = self.items[source];
    
    // Remove the item from the array
    [self.items removeObjectIdenticalTo:movedItem];
    
    // Insert the item at its new location
    [self.items insertObject:movedItem atIndex:destination];
}

- (NSString *)itemArchivePath {
    NSArray *documentsDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                                        NSUserDomainMask,
                                                                        YES);
    NSString *documentDirectory = [documentsDirectories firstObject];
    NSString *documentPath =
    [documentDirectory stringByAppendingPathComponent:@"items.archive"];
    return documentPath;
}

- (BOOL)saveChanges {
    NSLog(@"Saving items to %@", [self itemArchivePath]);
    BOOL success = [NSKeyedArchiver archiveRootObject:self.items
                                               toFile:[self itemArchivePath]];
    return success;
}

// MARK: Notifications
- (void)observeAppEnteredBackgroundNotification:(NSNotification *)note {
    BOOL success = [self saveChanges];
    if (success) {
        NSLog(@"Saved all of the items.");
    } else {
        NSLog(@"Couldn't save the items.");
    }
}


@end
