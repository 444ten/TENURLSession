//
//  TENRequestContext.m
//  TENURLSession
//
//  Created by 444ten on 3/7/16.
//  Copyright © 2016 444ten. All rights reserved.
//

#import "TENRequestContext.h"
#import <UIKit/UIKit.h>

#import "PDTMacro.h"
#import "TENRequestModel.h"

static NSString * const kTENBackgroundSessionIdentifier = @"kTENBackgroundSessionIdentifier";

typedef void (^PDTBaseUrlCompletionHandler)(NSData *data, NSURLResponse *response, NSError *error);

@interface TENRequestContext () <NSURLSessionDataDelegate>
@property (nonatomic, strong)   NSURLSessionDownloadTask    *sessionDataTask;

- (PDTBaseUrlCompletionHandler)completionHandler;
- (NSData *)postData;
- (NSURLRequest *)request;

@end

@implementation TENRequestContext

#pragma mark -
#pragma mark Public Methods

- (void)execute {
    [self.sessionDataTask resume];
}

- (void)cancel {
    [self.sessionDataTask cancel];
}


#pragma mark -
#pragma mark Accessors

- (NSURLSessionDownloadTask *)sessionDataTask {
    if (nil == _sessionDataTask) {
//        _sessionDataTask = [[NSURLSession sharedSession] dataTaskWithRequest:[self request]
//                                                           completionHandler:[self completionHandler]];
        
        NSString *identifier = [NSString stringWithFormat:@"%@%lu",
                                kTENBackgroundSessionIdentifier, self.model.requestCount];
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:identifier];
        configuration.allowsCellularAccess = YES;
        
        NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration
                                                              delegate:self
                                                         delegateQueue:nil];

        
        
//        _sessionDataTask = [session dataTaskWithRequest:[self request]];
        _sessionDataTask = [session downloadTaskWithRequest:[self request]];

    }
    
    return _sessionDataTask;
}

#pragma mark -
#pragma mark Private Methods

- (NSDictionary *)postDictionary {
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    
    NSDictionary *result = @{@"ent_sess_token"  : @"123", //tourist.serverToken,
                             @"ent_dev_id"      : @"456", //tourist.deviceID,
                             @"ent_user_type"   : @"2",
                             @"ent_tour_key"    : @"789", //tour.tourKey,
                             @"ent_date_time"   : [dateFormatter stringFromDate:[NSDate date]],
                             @"ent_utc_offset"  : @"7200" //[[APTimeZones sharedInstance] secondsFromGMTForCurrentLocation]
                             };
    
    return result;
}

- (NSString *)postMethod {
    return @"getTourStatus";
}

- (BOOL)parseResult:(NSDictionary *)result {
    NSLog(@"Request #%lu", self.model.requestCount);
    
    return YES;
}

- (PDTBaseUrlCompletionHandler)completionHandler {
    PDTWeakify(self)
    return ^(NSData *data, NSURLResponse *response, NSError *error) {
        PDTStrongify(self)
        
        if (!self) {
            NSLog(@"Warning! Context nil");
            
            return;
        }
        
        NSError *parseError = nil;
        NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
        
        BOOL success = !error && !parseError && dictionary && [self parseResult:dictionary];
        
        TENRequestModel *model = self.model;
        model.requestCount += 1;
        
        model.state = success ? PDTModelLoaded : PDTModelDidFailLoad;
        if (!success) {
            NSLog(@"! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! %@ error ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! !", NSStringFromClass([self class]));
        }
    };
}

- (NSData *)postData {
    NSDictionary *postDictionary = [self postDictionary];
    NSMutableString *string = [NSMutableString new];
    
    [postDictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [string appendFormat:@"&%@=%@", key, obj];
    }];
    
    if ([string hasPrefix:@"&"]) {
        string = (NSMutableString *)[string substringFromIndex:1];
    }
    
    return [string dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
}

- (NSURLRequest *)request {
    NSMutableURLRequest *result = [NSMutableURLRequest new];
    result.URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", @"http://104.236.125.245/newLogic.php/", [self postMethod]]];
    result.HTTPMethod = @"POST";
    result.HTTPBody = [self postData];
    
    return result;
}

#pragma mark -
#pragma mark NSURLSessionDataDelegate

- (void)        URLSession:(NSURLSession *)session
              downloadTask:(NSURLSessionDownloadTask *)downloadTask
 didFinishDownloadingToURL:(NSURL *)location
{
    NSData *data = [NSData dataWithContentsOfFile:location.path];
    NSError *parseError = nil;
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];

    BOOL success = [self parseResult:nil];
    
    TENRequestModel *model = self.model;
    model.requestCount += 1;
    
    model.state = success ? PDTModelLoaded : PDTModelDidFailLoad;
    
    
    if (model.requestCount % 10 == 0) {
        UILocalNotification* locNot = [[UILocalNotification alloc] init];
        locNot.fireDate = [NSDate dateWithTimeIntervalSinceNow:0];
        locNot.alertBody = [NSString stringWithFormat:@"still alive! - %lu", model.requestCount];
        locNot.timeZone = [NSTimeZone defaultTimeZone];
        [[UIApplication sharedApplication] scheduleLocalNotification:locNot];
    }
    
    

    
}


- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler
{
    BOOL success = [self parseResult:nil];
    
    TENRequestModel *model = self.model;
    model.requestCount += 1;
    
    model.state = success ? PDTModelLoaded : PDTModelDidFailLoad;

}

/* Notification that a data task has become a download task.  No
 * future messages will be sent to the data task.
 */
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
didBecomeDownloadTask:(NSURLSessionDownloadTask *)downloadTask
{
    
}

/*
 * Notification that a data task has become a bidirectional stream
 * task.  No future messages will be sent to the data task.  The newly
 * created streamTask will carry the original request and response as
 * properties.
 *
 * For requests that were pipelined, the stream object will only allow
 * reading, and the object will immediately issue a
 * -URLSession:writeClosedForStream:.  Pipelining can be disabled for
 * all requests in a session, or by the NSURLRequest
 * HTTPShouldUsePipelining property.
 *
 * The underlying connection is no longer considered part of the HTTP
 * connection cache and won't count against the total number of
 * connections per host.
 */
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
didBecomeStreamTask:(NSURLSessionStreamTask *)streamTask
{
    
}

/* Sent when data is available for the delegate to consume.  It is
 * assumed that the delegate will retain and not copy the data.  As
 * the data may be discontiguous, you should use
 * [NSData enumerateByteRangesUsingBlock:] to access it.
 */
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data
{
    
}

/* Invoke the completion routine with a valid NSCachedURLResponse to
 * allow the resulting data to be cached, or pass nil to prevent
 * caching. Note that there is no guarantee that caching will be
 * attempted for a given resource, and you should not rely on this
 * message to receive the resource data.
 */
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
 willCacheResponse:(NSCachedURLResponse *)proposedResponse
 completionHandler:(void (^)(NSCachedURLResponse * __nullable cachedResponse))completionHandler
{
    
}


@end
