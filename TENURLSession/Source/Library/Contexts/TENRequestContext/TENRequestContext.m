//
//  TENRequestContext.m
//  TENURLSession
//
//  Created by 444ten on 3/7/16.
//  Copyright © 2016 444ten. All rights reserved.
//

#import "TENRequestContext.h"

#import "PDTMacro.h"
#import "PDTModel.h"

typedef void (^PDTBaseUrlCompletionHandler)(NSData *data, NSURLResponse *response, NSError *error);

@interface TENRequestContext ()
@property (nonatomic, strong)   NSURLSessionDataTask    *sessionDataTask;

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

- (NSURLSessionDataTask *)sessionDataTask {
    if (nil == _sessionDataTask) {
        _sessionDataTask = [[NSURLSession sharedSession] dataTaskWithRequest:[self request]
                                                           completionHandler:[self completionHandler]];
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
    NSLog(@"...");
    
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
        
        PDTModel *model = self.model;
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

@end
