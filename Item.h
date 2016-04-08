//
//  Item.h
//  Randomitems
//
//  Created by XuJian on 12/20/15.
//  Copyright (c) 2015 XuJian. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Item : NSObject

@property (nonatomic, strong) Item *containedItem;
@property (nonatomic, weak) Item *container;

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *serialNumber;
@property (nonatomic) int valueInDollars;
@property (nonatomic, readonly, strong) NSDate *dateCreated;

@property (nonatomic, copy) NSString *itemKey;

+ (instancetype)randomItem;

- (instancetype)initWithName:(NSString *)name
              valueInDollars:(int)value
                serialNumber:(NSString *)sNumber NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithName:(NSString *)name;

@end
