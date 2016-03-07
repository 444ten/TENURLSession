//
//  AppDelegate.h
//  TENURLSession
//
//  Created by 444ten on 3/3/16.
//  Copyright © 2016 444ten. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>
@property (strong, nonatomic)   UIWindow    *window;
@property (nonatomic, copy)     void        (^backgroundSessionCompletionHandler)();

@end

