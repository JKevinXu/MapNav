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
    ItemsViewController *ivc = [[ItemsViewController alloc] initWithItemStore:itemStore
                                                                   imageStore:imageStore];
    
    // Use the ItemViewController as the top-level view controller in the app
//    self.window.rootViewController = ivc;
    
    // Create a navigation controller and add the itemsviewcontroller to it
    UINavigationController *navController =
   [[UINavigationController alloc] initWithRootViewController:ivc];
    
    // Use the Navigation controller as the top-level view controller in the app
    
    

    MapNavViewController *mapNavViewController = [[MapNavViewController alloc] init];
//    UITabBarController *tvc = [[UITabBarController alloc] init];
//    tvc.viewControllers = @[mapNavViewController, navController];
//    self.window.rootViewController = tvc;
    self.window.rootViewController = mapNavViewController;
    
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
