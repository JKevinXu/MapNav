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
        NSString *imagePath = [self imagePathForKey:key];
        NSData *imageData = UIImageJPEGRepresentation(image, 0.5);
        [imageData writeToFile:imagePath atomically:YES];
        
    } else { // nil was passed, indicating desire to delete the image
        [self.imageDictionary removeObjectForKey:key];
        NSString *imagePath = [self imagePathForKey:key];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        [fileManager removeItemAtPath:imagePath error:nil];
    }
}

- (UIImage *)imageForKey:(NSString *)key {
    UIImage *image = self.imageDictionary[key];
    if (!image) {
        NSString *imagePath = [self imagePathForKey:key];
        image = [UIImage imageWithContentsOfFile:imagePath];
        if (image) {
            self.imageDictionary[key] = image;
        }
    }
    return image;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _imageDictionary = [NSMutableDictionary dictionary];
        
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self
               selector:@selector(observeMemoryWarningNotification:)
                   name:UIApplicationDidReceiveMemoryWarningNotification
                 object:[UIApplication sharedApplication]];
    }
    return self;
}


- (NSString *)imagePathForKey:(NSString *)key {
    NSArray *directories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                               NSUserDomainMask,
                                                               YES);
    NSString *documentDirectory = [directories firstObject];
    NSString *imagePath = [documentDirectory stringByAppendingPathComponent:key];
    return imagePath;
}


// MARK: Notifications
- (void)observeMemoryWarningNotification:(NSNotification *)note {
    // Clear the cache
    NSLog(@"flushing %ld images from the image store", self.imageDictionary.count);
    [self.imageDictionary removeAllObjects];
}

@end
