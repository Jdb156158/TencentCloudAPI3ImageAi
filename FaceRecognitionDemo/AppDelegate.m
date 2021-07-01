//
//  AppDelegate.m
//  FaceRecognitionDemo
//
//  Created by 彭新凯 on 2021/5/10.
//

#import "AppDelegate.h"
#import "GIFMakingNaviViewController.h"
#import "ViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    GIFMakingNaviViewController* navigationController = [[GIFMakingNaviViewController alloc] initWithRootViewController:[[ViewController alloc]init]];
    [self.window setRootViewController:navigationController];
    [self.window makeKeyAndVisible];
    return YES;
}


@end
