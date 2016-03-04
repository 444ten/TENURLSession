//
//  PDTModel.h
//  Pocodot
//
//  Created by Andrey Ten on 7/22/15.
//  Copyright (c) 2015 444ten. All rights reserved.
//

#import "PDTObservableObject.h"

typedef NS_ENUM(NSUInteger, PDTModelState) {
    PDTModelUnloaded,
    PDTModelWillLoad,
    PDTModelLoaded,
    PDTModelDidFailLoad,
    PDTModelChanged
};

@protocol PDTModelObserver

@optional
- (void)modelDidUnload:(id)model;
- (void)modelWillLoad:(id)model;
- (void)modelDidLoad:(id)model;
- (void)modelDidFailLoad:(id)model;
- (void)model:(id)model didChangeWithUsersInfo:(id)userInfo;

@end

@interface PDTModel : PDTObservableObject

- (void)load;

// This method's is intended for subclassing. Never call it's directly.
- (void)setupLoading;

// This method is intended for subclassing. Never call it directly.
// You should set state
- (void)performLoadingInBackground;

@end
