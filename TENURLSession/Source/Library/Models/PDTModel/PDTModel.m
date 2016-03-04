//
//  PDTModel.m
//  Pocodot
//
//  Created by Andrey Ten on 7/22/15.
//  Copyright (c) 2015 444ten. All rights reserved.
//

#import "PDTModel.h"

@implementation PDTModel

#pragma mark -
#pragma mark Public

- (void)load {
    @synchronized (self) {
        PDTModelState state = self.state;
        if (PDTModelWillLoad == state || PDTModelLoaded == state) {
            self.state = state;
            return;
        }
        
        self.state = PDTModelWillLoad;
    }
    
    [self setupLoading];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [self performLoadingInBackground];
    });
}

- (void)setupLoading {
    
}

- (void)performLoadingInBackground {
    
}

#pragma mark -
#pragma mark Overload

- (SEL)selectorForState:(NSUInteger)state {
    switch (state) {
        case PDTModelUnloaded:
            return @selector(modelDidUnload:);
        case PDTModelWillLoad:
            return @selector(modelWillLoad:);
        case PDTModelLoaded:
            return @selector(modelDidLoad:);
        case PDTModelDidFailLoad:
            return @selector(modelDidFailLoad:);
        case PDTModelChanged:
            return @selector(model:didChangeWithUsersInfo:);

        default:
            [super selectorForState:state];
    }
    
    return NULL;
}

@end
