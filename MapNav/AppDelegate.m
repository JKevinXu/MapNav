//
//  AppDelegate.m
//  MapNav
//
//  Created by XuJian on 1/15/16.
//  Copyright (c) 2016 Jian (Kevin) Xu. All rights reserved.
//

#import "AppDelegate.h"
#import "ItemsViewController.h"
#import "ItemStore.h"
#import "ImageStore.h"
#import "DetailViewController.h"
#import "MapNavViewController.h"

@import GoogleMaps;

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [GMSServices provideAPIKey:@"AIzaSyDOfNDNoAsy1Q3SlKmjzkK_hHyTy5odCRY"];
    
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    
    // Create an item store
    ItemStore *itemStore = [[ItemStore alloc] init];
    
    // Create the image store
    ImageStore *imageStore = [[ImageStore alloc] init];
    
    // Create an ItemViewController
//    ItemsViewController *ivc = [[ItemsViewController alloc] initWithItemStore: imageStore];
    ItemsViewController *itemViewController = [[ItemsViewController alloc] initWithItemStore:itemStore
                                                                   imageStore:imageStore];
    
    // Use the ItemViewController as the top-level view controller in the app
//    self.window.rootViewController = ivc;
    
    // Create a navigation controller and add the itemsviewcontroller to it
    UINavigationController *ItemNavController =
   [[UINavigationController alloc] initWithRootViewController:itemViewController];
    
    MapNavViewController *mapNavViewController = [[MapNavViewController alloc] init];
    
    
    UIImage *imageMapView = [UIImage imageNamed:@"MarkerPlay.png"];
    ImageStore *setImageSize = [[ImageStore alloc] init];
    UIImage *resizedImageMapView = [setImageSize imageWithImage:imageMapView scaledToSize:CGSizeMake(30, 30)];
    resizedImageMapView = [resizedImageMapView imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
//    UITabBarItem *item0 = [totalViewController.viewControllers objectAtIndex:0];
    
    mapNavViewController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Map View" image:resizedImageMapView selectedImage:resizedImageMapView];
    
    
    UIImage *imageMarkerSet = [UIImage imageNamed:@"MapMarker.png"];
    ImageStore *setImageSize_2 = [[ImageStore alloc] init];
    UIImage *resizedImageMarkerSet = [setImageSize_2 imageWithImage:imageMarkerSet scaledToSize:CGSizeMake(30, 30)];
    resizedImageMarkerSet = [resizedImageMarkerSet imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    //    UITabBarItem *item0 = [totalViewController.viewControllers objectAtIndex:0];
    
    ItemNavController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Marker Set" image:resizedImageMarkerSet selectedImage:resizedImageMarkerSet];
    
    // Use the Navigation controller as the top-level view controller in the app
    UITabBarController *totalViewController = [[UITabBarController alloc] init];
    totalViewController.viewControllers = @[mapNavViewController, ItemNavController];
    self.window.rootViewController = totalViewController;
    
//     item0.title = @"MapView";
//     [item0 setFinishedSelectedImage:image withFinishedUnselectedImage:image];
    
    /*
     UIImage *image = [UIImage imageNamed:@"MarkerPlay.png"];
     ImageStore *setImageSize = [[ImageStore alloc] init];
     self.tabBarItem.image = [setImageSize imageWithImage:image scaledToSize:CGSizeMake(30, 30)];
     
     if (self){
     self.tabBarItem.title = @"MapView";
     self.tabBarItem.image = [UIImage imageNamed:@"MarkerPlay.png"];
     }
     */
    
    
//    [item0 setFinishedSelectedImage:selectedImage0 withFinishedUnselectedImage:unselectedImage0];
    
//    self.window.rootViewController = navController;
    
    [self.window makeKeyAndVisible];
     
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
