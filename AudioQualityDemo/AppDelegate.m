//
//  AppDelegate.m
//  AudioQualityDemo
//
//  Created by 党玉华 on 2020/1/10.
//  Copyright © 2020 Linkdom. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    self.window.rootViewController = [[UINavigationController alloc]initWithRootViewController:ViewController.new];
    [self.window makeKeyAndVisible];
    
    return YES;
}


@end
