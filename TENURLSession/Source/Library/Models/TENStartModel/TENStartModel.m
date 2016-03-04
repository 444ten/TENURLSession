//
//  TENStartModel.m
//  TENURLSession
//
//  Created by 444ten on 3/4/16.
//  Copyright © 2016 444ten. All rights reserved.
//

#import "TENStartModel.h"

@interface TENStartModel ()
@property (nonatomic, strong)   NSMutableArray<UIImage *> *images;

@end

@implementation TENStartModel

@dynamic startImages;

#pragma mark -
#pragma mark Initializations and Deallocations

- (instancetype)init {
    self = [super init];
    if (self) {
        self.images = [NSMutableArray new];
    }
    
    return self;
}

#pragma mark -
#pragma mark Accessors

- (NSArray<UIImage *> *)startImages {
    return [NSArray arrayWithArray:self.images];
}

- (void)addStartImage:(UIImage *)image {
    if (image) {
        [self.images addObject:image];
    }
}

@end
