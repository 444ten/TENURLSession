//
//  PDTObservableObject.m
//  Pocodot
//
//  Created by Andrey Ten on 5/27/15.
//  Copyright (c) 2015 444ten. All rights reserved.
//

#import "PDTObservableObject.h"

@interface PDTObservableObject ()
@property (nonatomic, retain)   NSHashTable     *observerHashTable;
@property (nonatomic, assign)   BOOL            shouldNotify;

- (void)notifyOfStateChange:(NSUInteger)state withObject:(id)object;

@end

@implementation PDTObservableObject

@synthesize state = _state;

@dynamic observerSet;

#pragma mark -
#pragma mark Initializations and Deallocations

- (instancetype)init {
    self = [super init];
    if (self) {
        self.observerHashTable = [NSHashTable weakObjectsHashTable];
        self.shouldNotify = YES;
    }
    
    return self;
}

#pragma mark -
#pragma mark Accessors

- (void)setState:(NSUInteger)state {
    [self setState:state withObject:nil];
}

- (void)setState:(NSUInteger)state withObject:(id)object {
    @synchronized (self) {
        dispatch_async(dispatch_get_main_queue(), ^{
            _state = state;
            
            if (self.shouldNotify) {
                [self notifyOfStateChange:state withObject:object];
            }            
        });
    }
}

- (NSUInteger)state {
    @synchronized (self) {
        return _state;
    }
}

- (NSSet *)observerSet {
    @synchronized (self) {
        return self.observerHashTable.setRepresentation;
    }
}

#pragma mark -
#pragma mark Public

- (void)addObserver:(id)observer {
    @synchronized (self) {
        [self.observerHashTable addObject:observer];
    }
}

- (void)removeObserver:(id)observer {
    @synchronized (self) {
        [self.observerHashTable removeObject:observer];
    }
}

- (BOOL)isObservedByObserver:(id)observer {
    @synchronized (self) {
        return [self.observerHashTable containsObject:observer];
    }
}

- (void)performBlockWithoutNotification:(void(^)(void))block {
    self.shouldNotify = NO;
    block();
    self.shouldNotify = YES;
}

- (SEL)selectorForState:(NSUInteger)state {
    return NULL;
}

#pragma mark -
#pragma mark Private

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"

- (void)notifyOfStateChange:(NSUInteger)state withObject:(id)object {
    SEL selector = [self selectorForState:_state];
    NSSet *observerSet = self.observerSet;
    
    for (id observer in observerSet) {
        if ([observer respondsToSelector:selector]) {
            [observer performSelector:selector withObject:self withObject:object];
        }
    }
}

#pragma clang diagnostic pop

@end
