//
//  Item.h
//  Randomitems
//
//  Created by XuJian on 12/20/15.
//  Copyright (c) 2015 XuJian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MapNavViewController.h"
#import <GoogleMaps/GoogleMaps.h>


@interface Item : NSObject <NSCoding>

@property (nonatomic, strong) Item *containedItem;
@property (nonatomic, weak) Item *container;

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *serialNumber;
@property (nonatomic) CLLocationCoordinate2D *location;
@property (nonatomic) double longitude;
@property (nonatomic) double latitude;
@property (nonatomic) int valueInDollars;
@property (nonatomic, readonly, strong) NSDate *dateCreated;

@property (nonatomic, copy) NSString *itemKey;

+ (instancetype)randomItem;

- (instancetype)initWithName:(NSString *)name
                   longitude:(double) longitude
                    latitude:(double) latitude
                serialNumber:(NSString *)sNumber NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithName:(NSString *)name;

- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_DESIGNATED_INITIALIZER;

@end
