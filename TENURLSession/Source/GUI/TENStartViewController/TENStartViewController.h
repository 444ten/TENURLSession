//
//  TENStartViewController.h
//  TENURLSession
//
//  Created by 444ten on 3/3/16.
//  Copyright © 2016 444ten. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TENStartModel;
@class TENRequestModel;

@interface TENStartViewController : UIViewController
@property (nonatomic, strong)   TENStartModel   *model;
@property (nonatomic, strong)   TENRequestModel *requestModel;

@end
