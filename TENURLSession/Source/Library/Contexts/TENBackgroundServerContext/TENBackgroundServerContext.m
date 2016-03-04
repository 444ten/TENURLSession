//
//  TENBackgroundServerContext.m
//  TENURLSession
//
//  Created by 444ten on 3/4/16.
//  Copyright © 2016 444ten. All rights reserved.
//

#import "TENBackgroundServerContext.h"

static NSString * const kTENBackgroundSessionIdentifier = @"kTENBackgroundSessionIdentifier";
//static NSString * const kTENDownloadURLTop              = @"http://img-d.photosight.ru/457/6214458_xlarge.jpg";
//static NSString * const kTENDownloadURLMiddle           = @"http://img-c.photosight.ru/ed1/6214812_xlarge.jpg";
//static NSString * const kTENDownloadURLBottom           = @"http://img-3.photosight.ru/78f/5890550_xlarge.jpg";

//static NSString * const kTENDownloadURLTop              = @"http://www.nastol.com.ua/large/201603/166645.jpg";
//static NSString * const kTENDownloadURLMiddle           = @"http://www.nastol.com.ua/large/201603/166646.jpg";
//static NSString * const kTENDownloadURLBottom           = @"http://www.nastol.com.ua/large/201603/166647.jpg";

static const NSUInteger kTENStartImageNumber    = 166645;
static const NSUInteger kTENMaxCount            = 62;

@interface TENBackgroundServerContext () <NSURLSessionDownloadDelegate>
@property (nonatomic, assign)   NSUInteger  count;
@property (nonatomic, strong)   NSURLSessionDownloadTask *downloadTask;

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
    NSString *stringURL =
        [NSString stringWithFormat:@"http://www.nastol.com.ua/large/201603/%lu.jpg", self.count + kTENStartImageNumber];
    
    NSURLSessionDownloadTask *downloadTask = [[self backgroundSession] downloadTaskWithURL:[NSURL URLWithString:stringURL]];
    [downloadTask resume];
    
    self.downloadTask = downloadTask;
}

- (void)cancel {
    
}

#pragma mark -
#pragma mark Private Methods

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
    [model addStartImage:image];
    
    self.count += 1;

    model.state = PDTModelLoaded;
    
    if (self.count < kTENMaxCount) {
        [self execute];
    }    
}

@end
