//
//  TENStartViewController.m
//  TENURLSession
//
//  Created by 444ten on 3/3/16.
//  Copyright © 2016 444ten. All rights reserved.
//

#import "TENStartViewController.h"

#import "TENStartModel.h"
#import "TENBackgroundServerContext.h"

@interface TENStartViewController ()
@property (nonatomic, strong)   TENBackgroundServerContext  *backgroundServerContext;

@end

@implementation TENStartViewController

#pragma mark -
#pragma mark View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    TENBackgroundServerContext *backgroundServerContext = [TENBackgroundServerContext new];
    backgroundServerContext.model = [TENStartModel new];
    [backgroundServerContext execute];
    
    self.backgroundServerContext = backgroundServerContext;
}


@end
