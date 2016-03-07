//
//  TENRequestContext.h
//  TENURLSession
//
//  Created by 444ten on 3/7/16.
//  Copyright © 2016 444ten. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TENRequestModel;

@interface TENRequestContext : NSObject
@property (nonatomic, strong)   TENRequestModel *model;

- (void)execute;
- (void)cancel;

@end
