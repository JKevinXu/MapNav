//
//  ItemStore.m
//  MapNav
//
//  Created by XuJian on 1/15/16.
//  Copyright (c) 2016 Jian (Kevin) Xu. All rights reserved.
//

#import "ItemStore.h"
#import "Item.h"

@interface ItemStore ()
@property (nonatomic) NSMutableArray *items;
@end

@implementation ItemStore

- (instancetype)init {
    self = [super init];
    if (self) {
        _items = [NSMutableArray array];
    }
    return self;
}

- (NSArray *)allItems {
    return [self.items copy];
}

- (Item *)createItem {
    Item *newItem = [Item randomItem];
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

@end
