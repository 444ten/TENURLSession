//
//  TENBackgroundServerContext.m
//  TENURLSession
//
//  Created by 444ten on 3/4/16.
//  Copyright © 2016 444ten. All rights reserved.
//

#import "TENBackgroundServerContext.h"

#import "AppDelegate.h"

static NSString * const kTENBackgroundSessionIdentifier = @"kTENBackgroundSessionIdentifier";

static const NSUInteger kTENStartImageNumber    = 166645;

@interface TENBackgroundServerContext () <NSURLSessionDownloadDelegate>
@property (nonatomic, assign)   NSUInteger  count;
@property (nonatomic, strong)   NSURLSessionDownloadTask *downloadTask;

@end

@implementation TENBackgroundServerContext

#pragma mark -
#pragma mark Public Methods

- (NSURLSession *)backgroundSession {
//    static NSURLSession *session = nil;
//    
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        NSURLSessionConfiguration *configuration =
//            [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:kTENBackgroundSessionIdentifier];
//        configuration.allowsCellularAccess = YES;
//        
//        session = [NSURLSession sessionWithConfiguration:configuration
//                                                delegate:self
//                                           delegateQueue:nil];
//    });
//    
//    return session;

    NSString *identifier = [NSString stringWithFormat:@"%@%d", kTENBackgroundSessionIdentifier, 0]; //self.imageNumber
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:identifier];
    configuration.allowsCellularAccess = YES;
    
    return  [NSURLSession sessionWithConfiguration:configuration
                                          delegate:self
                                     delegateQueue:nil];
}

- (void)execute {
    NSString *stringURL =
        [NSString stringWithFormat:@"http://www.nastol.com.ua/large/201603/%lu.jpg", self.imageNumber + kTENStartImageNumber];
    
    NSURLSessionDownloadTask *downloadTask = [[self backgroundSession] downloadTaskWithURL:[NSURL URLWithString:stringURL]];
    [downloadTask resume];
    
    self.downloadTask = downloadTask;
}

- (void)cancel {
    
}

#pragma mark -
#pragma mark NSURLSessionDownloadDelegate

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    if (error) {
        NSLog(@"error: %@ - %@", task, error);
    } else {
        NSLog(@"success: %@", task);
    }
        
    self.downloadTask = nil;
    
    self.model.state = PDTModelLoaded;
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    if (appDelegate.backgroundSessionCompletionHandler == nil) {
        return;
    }
    
    void (^comletionHandler)() = appDelegate.backgroundSessionCompletionHandler;
    appDelegate.backgroundSessionCompletionHandler = nil;
    comletionHandler();
}

- (void)        URLSession:(NSURLSession *)session
              downloadTask:(NSURLSessionDownloadTask *)downloadTask
 didFinishDownloadingToURL:(NSURL *)location
{
    NSData *data = [NSData dataWithContentsOfFile:location.path];
    UIImage *image = [UIImage imageWithData:data];
    
    TENStartModel *model = self.model;
    [model addStartImage:image];
}

@end
