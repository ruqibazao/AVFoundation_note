//
//  AppDelegate.m
//  LearningAVFoundation
//
//  Created by nenhall on 2020/1/4.
//  Copyright © 2020 nenhall. All rights reserved.
//

#import "AppDelegate.h"
#import <AVFoundation/AVFoundation.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    AVAudioSession *session = [AVAudioSession sharedInstance];
    NSError *error;
    BOOL setCategory = [session setCategory:AVAudioSessionCategoryPlayback error:&error];
    if (setCategory == NO) {
        NSLog(@"setCategory:%@", error.localizedDescription);
    }
    
    BOOL setActives = [session setActive:YES error:&error];
    if (setActives == NO) {
        NSLog(@"setActives:%@", error.localizedDescription);
    }

    return YES;
}


#pragma mark - UISceneSession lifecycle


- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}


- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
}


@end
