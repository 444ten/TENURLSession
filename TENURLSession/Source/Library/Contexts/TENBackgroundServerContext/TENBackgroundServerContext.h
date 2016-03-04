//
//  TENBackgroundServerContext.h
//  TENURLSession
//
//  Created by 444ten on 3/4/16.
//  Copyright © 2016 444ten. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TENStartModel.h"

@interface TENBackgroundServerContext : NSObject
@property (nonatomic, strong)   TENStartModel   *model;

- (void)execute;
- (void)cancel;

@end
