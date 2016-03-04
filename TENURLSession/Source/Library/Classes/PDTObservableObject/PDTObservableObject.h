//
//  PDTObservableObject.h
//  Pocodot
//
//  Created by Andrey Ten on 5/27/15.
//  Copyright (c) 2015 444ten. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PDTObservableObject : NSObject
@property (atomic, assign)      NSUInteger  state;
@property (nonatomic, readonly) NSSet       *observerSet;
@property (nonatomic, readonly) BOOL        shouldNotify;


- (void)setState:(NSUInteger)state withObject:(id)object;

- (void)addObserver:(id)observer;
- (void)removeObserver:(id)observer;
- (BOOL)isObservedByObserver:(id)observer;

- (void)performBlockWithoutNotification:(void(^)(void))block;

// This methods is intended for subclassing. Never call its directly.
- (SEL)selectorForState:(NSUInteger)state;

@end
