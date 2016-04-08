//
//  ImageStore.m
//  MapNav
//
//  Created by XuJian on 1/17/16.
//  Copyright (c) 2016 Jian (Kevin) Xu. All rights reserved.
//

#import "ImageStore.h"

@interface ImageStore ()
@property (nonatomic) NSMutableDictionary *imageDictionary;
@end

@implementation ImageStore

- (void)setImage:(UIImage *)image forKey:(NSString *)key {
    if (image) {  // we're setting a new image
        self.imageDictionary[key] = image;
    } else { // nil was passed, indicating desire to delete the image
        [self.imageDictionary removeObjectForKey:key];
    }
}

- (UIImage *)imageForKey:(NSString *)key {
    return self.imageDictionary[key];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _imageDictionary = [NSMutableDictionary dictionary];
    }
    return self;
}

@end
