//
//  E20AppDelegate.h
//  First-try
//
//  Created by E-Twenty Janahan on 1/6/14.
//  Copyright (c) 2014 E-Twenty Dev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>

@interface E20AppDelegate : UIResponder <UIApplicationDelegate>
{
    CMMotionManager *motionManager;
}

@property (strong, nonatomic) UIWindow *window;
@property (readonly) CMMotionManager *motionManager;
@property (strong, nonatomic) UIViewController *View2;

@end
