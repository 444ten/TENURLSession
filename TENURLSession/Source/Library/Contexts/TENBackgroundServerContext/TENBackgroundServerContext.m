//
//  TENBackgroundServerContext.m
//  TENURLSession
//
//  Created by 444ten on 3/4/16.
//  Copyright © 2016 444ten. All rights reserved.
//

#import "TENBackgroundServerContext.h"

static NSString * const kTENBackgroundSessionIdentifier = @"kTENBackgroundSessionIdentifier";
static NSString * const kTENDownloadURL                 = @"https://discussions.apple.com/servlet/JiveServlet/showImage/2-20930244-204399/iPhone%2B5%2BProblem2.jpg";

@interface TENBackgroundServerContext () <NSURLSessionDownloadDelegate>
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
    NSURLSessionDownloadTask *downloadTask = [[self backgroundSession] downloadTaskWithURL:[NSURL URLWithString:kTENDownloadURL]];
    [downloadTask resume];
    
    self.downloadTask = downloadTask;
}

- (void)cancel {
    
}

#pragma mark -
#pragma mark NSURLSessionDownloadDelegate

- (void)        URLSession:(NSURLSession *)session
              downloadTask:(NSURLSessionDownloadTask *)downloadTask
 didFinishDownloadingToURL:(NSURL *)location
{
    UIImage *image = [UIImage imageWithContentsOfFile:location.path];
 
    TENStartModel *model = self.model;
    model.startImage = image;
    model.state = PDTModelLoaded;
}

@end
