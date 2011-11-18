//
//  FBLiveBoardAppDelegate.h
//  FBLiveBoard
//
//  Created by Angelo Kaichen Huang on 11/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#import "FBConnect.h"

@interface FBLiveBoardAppDelegate : NSObject <UIApplicationDelegate, FBSessionDelegate>
{
    UIWindow* _window;
    UIViewController* _rootController;
    Facebook *facebook;
}

@property (nonatomic, readwrite, retain) UIWindow* window;
@property (nonatomic, retain) Facebook *facebook;

@end
