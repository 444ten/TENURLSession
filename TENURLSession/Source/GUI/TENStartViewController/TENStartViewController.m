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

static const NSUInteger kTENMaxCount    = 62;

@interface TENStartViewController () <PDTModelObserver>
@property (nonatomic, strong)   IBOutlet UIImageView    *topImageView;
@property (nonatomic, strong)   IBOutlet UIImageView    *middleImageView;
@property (nonatomic, strong)   IBOutlet UIImageView    *bottomImageView;

@property (nonatomic, strong)   IBOutlet UILabel        *countLabel;
@property (strong, nonatomic)   IBOutlet UILabel        *currentLabel;

@property (nonatomic, assign)   NSUInteger              currentIndexImage;
@property (nonatomic, assign)   NSUInteger              imageNumber;

@property (nonatomic, strong)   TENBackgroundServerContext  *backgroundServerContext;

- (void)loadImage:(NSUInteger)imageNumber;

@end

@implementation TENStartViewController

#pragma mark -
#pragma mark View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.model = [TENStartModel new];
    self.imageNumber = 0;
}

#pragma mark -
#pragma mark Accessors

- (void)setModel:(TENStartModel *)model {
    PDTObserverSetter(model)
}

#pragma mark -
#pragma mark Action Handling

- (IBAction)onLoad:(UIButton *)sender {
    [self loadImage:self.imageNumber];
}

- (IBAction)onNavigation:(UIButton *)sender {
    NSInteger index = self.currentIndexImage + sender.tag;
    NSArray *startImages = self.model.startImages;

    if (index >= 0 && index < startImages.count) {
        self.currentIndexImage = index;
        self.middleImageView.image = startImages[index];
        self.currentLabel.text = [NSString stringWithFormat:@"< %lu >", index];
    }
}

- (void)loadImage:(NSUInteger)imageNumber {
    TENBackgroundServerContext *backgroundServerContext = [TENBackgroundServerContext new];
    backgroundServerContext.model = self.model;
    backgroundServerContext.imageNumber = imageNumber;
    [backgroundServerContext execute];
    
    self.backgroundServerContext = backgroundServerContext;
}

#pragma mark -
#pragma mark PDTModelObserver

- (void)modelDidLoad:(id)model {
    if (model == self.model) {
        TENStartModel *model = self.model;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.topImageView.image = model.startImages.lastObject;
            self.countLabel.text = [NSString stringWithFormat:@"< %lu >", self.model.startImages.count];
        });

        NSUInteger imageNumber = self.imageNumber + 1;
        if (imageNumber < kTENMaxCount) {
            [self loadImage:imageNumber];
            
            self.imageNumber = imageNumber;
        }
    }
}

@end
