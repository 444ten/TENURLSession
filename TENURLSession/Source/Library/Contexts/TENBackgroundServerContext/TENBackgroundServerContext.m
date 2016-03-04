//
//  TENBackgroundServerContext.m
//  TENURLSession
//
//  Created by 444ten on 3/4/16.
//  Copyright © 2016 444ten. All rights reserved.
//

#import "TENBackgroundServerContext.h"

static NSString * const kTENBackgroundSessionIdentifier = @"kTENBackgroundSessionIdentifier";
static NSString * const kTENDownloadURLTop              = @"http://img-d.photosight.ru/457/6214458_xlarge.jpg";
static NSString * const kTENDownloadURLMiddle           = @"http://img-c.photosight.ru/ed1/6214812_xlarge.jpg";
static NSString * const kTENDownloadURLBottom           = @"http://img-3.photosight.ru/78f/5890550_xlarge.jpg";

@interface TENBackgroundServerContext () <NSURLSessionDownloadDelegate>
@property (nonatomic, strong)   NSURLSessionDownloadTask *downloadTaskTop;
@property (nonatomic, strong)   NSURLSessionDownloadTask *downloadTaskMiddle;
@property (nonatomic, strong)   NSURLSessionDownloadTask *downloadTaskBottom;

@property (nonatomic, strong)   NSTimer                  *timer;
@end

@implementation TENBackgroundServerContext

#pragma mark -
#pragma mark Public Methods

- (NSURLSession *)backgroundSession {
    static NSURLSession *session = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURLSessionConfiguration *configuration =
            [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:kTENBackgroundSessionIdentifier];
        configuration.allowsCellularAccess = YES;
        
        session = [NSURLSession sessionWithConfiguration:configuration
                                                delegate:self
                                           delegateQueue:nil];
    });
    
    return session;
}

- (void)execute {
    NSURLSessionDownloadTask *downloadTaskTop = [[self backgroundSession] downloadTaskWithURL:[NSURL URLWithString:kTENDownloadURLTop]];
    [downloadTaskTop resume];
    
    self.downloadTaskTop = downloadTaskTop;
}

- (void)cancel {
    
}

#pragma mark -
#pragma mark Private Methods

- (void)contextLog {
    NSLog(@"don't sleep");
}

- (void)executeMiddle {
    NSURLSessionDownloadTask *downloadTaskMiddle = [[self backgroundSession] downloadTaskWithURL:[NSURL URLWithString:kTENDownloadURLMiddle]];
    [downloadTaskMiddle resume];
    
    self.downloadTaskMiddle = downloadTaskMiddle;    
}

- (void)executeBootom {
    NSURLSessionDownloadTask *downloadTaskBottom = [[self backgroundSession] downloadTaskWithURL:[NSURL URLWithString:kTENDownloadURLBottom]];
    [downloadTaskBottom resume];
    
    self.downloadTaskBottom = downloadTaskBottom;
}

#pragma mark -
#pragma mark NSURLSessionDownloadDelegate

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    if (error) {
        NSLog(@"error: %@ - %@", task, error);
    } else {
        NSLog(@"success: %@", task);
    }
        
//    self.downloadTask = nil;
}


- (void)        URLSession:(NSURLSession *)session
              downloadTask:(NSURLSessionDownloadTask *)downloadTask
 didFinishDownloadingToURL:(NSURL *)location
{
    NSData *data = [NSData dataWithContentsOfFile:location.path];
    UIImage *image = [UIImage imageWithData:data];
    
    TENStartModel *model = self.model;

    if (downloadTask == self.downloadTaskTop) {
        model.topImage = image;
        [self executeMiddle];
    } else if (downloadTask == self.downloadTaskMiddle) {
        model.middleImage = image;
        [self executeBootom];
    } else if (downloadTask == self.downloadTaskBottom) {
        model.bottomImage = image;
    }
    
    model.state = PDTModelLoaded;
}

@end
