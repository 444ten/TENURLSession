//
//  TENStartViewController.m
//  TENURLSession
//
//  Created by 444ten on 3/3/16.
//  Copyright © 2016 444ten. All rights reserved.
//

#import "TENStartViewController.h"

#import "PDTMacro.h"
#import "TENStartModel.h"
#import "TENBackgroundServerContext.h"

@interface TENStartViewController () <PDTModelObserver>
@property (strong, nonatomic)   IBOutlet UIImageView        *startImageView;

@property (nonatomic, strong)   TENBackgroundServerContext  *backgroundServerContext;

@end

@implementation TENStartViewController

#pragma mark -
#pragma mark View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    TENStartModel *model = [TENStartModel new];
    self.model = model;
    
    TENBackgroundServerContext *backgroundServerContext = [TENBackgroundServerContext new];
    backgroundServerContext.model = model;
    [backgroundServerContext execute];
    
    self.backgroundServerContext = backgroundServerContext;
}

#pragma mark -
#pragma mark Accessors

- (void)setModel:(TENStartModel *)model {
    PDTObserverSetter(model)
}

#pragma mark -
#pragma mark PDTModelObserver

- (void)modelDidLoad:(id)model {
    if (model == self.model) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.startImageView.image = self.model.startImage;            
        });

    }
}

@end
