//
//  HttpTool.m
//  camerademo
//
//  Created by 贾大兵 on 2020/3/19.
//  Copyright © 2020 sunuo. All rights reserved.
//

#import "HttpTool.h"
#import "AFNetworking.h"

static AFHTTPSessionManager *sessionManager;
// 网络状态，初始值-1：未知网络状态
static NSInteger networkStatus = -1;

@implementation HttpTool

+ (void)load{
    sessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:@""]];
}

+ (void)GET:(NSString *)URLString Parameters:(id)parameters Success:(void (^)(id data))success Failure:(void (^)(NSError *error))failure{
    
    [self GET:URLString Animated:NO Parameters:parameters Success:success Failure:failure];
}

+ (void)POST:(NSString *)URLString Parameters:(id)parameters Success:(void (^)(id data))success Failure:(void (^)(NSError *error))failure{
    
    [self POST:URLString Animated:YES Parameters:parameters Success:success Failure:failure];
}

+ (void)DELETE:(NSString *)URLString Parameters:(id)parameters Success:(void (^)(id data))success Failure:(void (^)(NSError *error))failure{
    [self DELETE:URLString Animated:YES Parameters:parameters Success:success Failure:failure];
}

#pragma mark - 带Loading的网络请求
+ (void)GET:(NSString *)URLString Animated:(BOOL)animated Parameters:(id )parameters Success:(void (^)(id data))success Failure:(void (^)(NSError *))failure{

    sessionManager.responseSerializer.acceptableContentTypes=[NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html",@"text/xml",nil];
    
    sessionManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    sessionManager.requestSerializer = [AFJSONRequestSerializer serializer];
    sessionManager.requestSerializer.timeoutInterval = 20.0;
    [self setupHeaderField];
    
    NSMutableDictionary * mDic = [NSMutableDictionary dictionaryWithDictionary:parameters];
    
    if (![[mDic objectForKey:@"timeoutInterval"] isEqual:[NSNull null]]) {
        sessionManager.requestSerializer.timeoutInterval = [[mDic objectForKey:@"timeoutInterval"] intValue];
    }
//    [mDic setValue:[NSString stringWithFormat:@"%@",@"3.0.0"] forKey:@"vvDoutGif"];

    NSLog(@"开始GET请求:%@\n 参数-------%@",URLString,mDic);
    
    [sessionManager GET:URLString parameters:mDic headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
//        //如果是用户登录的情况下
//        if ([URLString isEqual:URL_Login_Three]) {
//            NSString *xTSessionID = nil;
//            if (task) {
//                NSHTTPURLResponse *response = (NSHTTPURLResponse *)[task response];
//                xTSessionID = [[response allHeaderFields] valueForKey:@"X-Transmission-Session-Id"];
//                [userDataUtil saveSession:xTSessionID];
//                NSLog(@"response = %@", response);
//            }
//        }

        if (success) {
            id result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves|NSJSONReadingAllowFragments|NSJSONReadingMutableContainers error:nil];
            success(result);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (animated) {

        }
        
        NSString * errorstr = [error.userInfo objectForKey:@"NSLocalizedDescription"];
        
        if([errorstr rangeOfString:@"Request failed: unauthorized (401)"].location==NSNotFound){
        }
        
        NSLog(@"请求失败:%@",error);
        failure(error);
    }];

}

+ (void)POST:(NSString *)URLString Animated:(BOOL)animated Parameters:(id)parameters Success:(void (^)(id data))success Failure:(void (^)(NSError *))failure{
    
    sessionManager.responseSerializer.acceptableContentTypes=[NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html",@"text/xml",@"application/x-www-form-urlencoded", nil];
    
    sessionManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    sessionManager.requestSerializer = [AFHTTPRequestSerializer serializer];
    sessionManager.requestSerializer.timeoutInterval = 10.0;
    [sessionManager.requestSerializer setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    [self setupHeaderField];
    
    sessionManager.securityPolicy.allowInvalidCertificates = YES;
    //也不验证域名一致性
    sessionManager.securityPolicy.validatesDomainName = NO;
    //关闭缓存避免干扰测试
    sessionManager.requestSerializer.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    
    NSMutableDictionary * mDic = [NSMutableDictionary dictionaryWithDictionary:parameters];
//    [mDic setValue:[NSString stringWithFormat:@"%@",@"3.0.0"] forKey:@"vvDoutGif"];
    
    //NSLog(@"开始POST请求:%@\n 参数-------%@",URLString,mDic);
    [sessionManager POST:URLString parameters:mDic headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
//        //如果是用户登录的情况下
//        if ([URLString isEqual:URL_Login_Three]) {
//            NSString *xTSessionID = nil;
//            if (task) {
//                NSHTTPURLResponse *response = (NSHTTPURLResponse *)[task response];
//                xTSessionID = [[response allHeaderFields] valueForKey:@"X-Transmission-Session-Id"];
//                [userDataUtil saveSession:xTSessionID];
//                NSLog(@"response = %@", response);
//            }
//        }
        
        
        id result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves|NSJSONReadingAllowFragments|NSJSONReadingMutableContainers error:nil];
        
        if (success) {
            success(result);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {

        NSString * errorstr = [error.userInfo objectForKey:@"NSLocalizedDescription"];
        
        if([errorstr rangeOfString:@"Request failed: unauthorized (401)"].location==NSNotFound){
            
            
        }
        
        failure(error);
    }];

}

+ (void)DELETE:(NSString *)URLString Animated:(BOOL)animated Parameters:(id)parameters Success:(void (^)(id data))success Failure:(void (^)(NSError *))failure{
    
    sessionManager.responseSerializer.acceptableContentTypes=[NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html",@"text/xml",@"application/x-www-form-urlencoded", nil];
    
    sessionManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    sessionManager.requestSerializer = [AFHTTPRequestSerializer serializer];
    sessionManager.requestSerializer.timeoutInterval = 10.0;
    [sessionManager.requestSerializer setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    [self setupHeaderField];
    
    sessionManager.securityPolicy.allowInvalidCertificates = YES;
    //也不验证域名一致性
    sessionManager.securityPolicy.validatesDomainName = NO;
    //关闭缓存避免干扰测试
    sessionManager.requestSerializer.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    
    NSMutableDictionary * mDic = [NSMutableDictionary dictionaryWithDictionary:parameters];
    [mDic setValue:[NSString stringWithFormat:@"%@",@"3.0.0"] forKey:@"vvDoutGif"];
    
    //NSLog(@"开始POST请求:%@\n 参数-------%@",URLString,mDic);
    [sessionManager DELETE:URLString parameters:mDic headers:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        //如果是用户登录的情况下
//        if ([URLString isEqual:URL_Login_Three]) {
//            NSString *xTSessionID = nil;
//            if (task) {
//                NSHTTPURLResponse *response = (NSHTTPURLResponse *)[task response];
//                xTSessionID = [[response allHeaderFields] valueForKey:@"X-Transmission-Session-Id"];
//                [userDataUtil saveSession:xTSessionID];
//                NSLog(@"response = %@", response);
//            }
//        }
        
        
        id result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves|NSJSONReadingAllowFragments|NSJSONReadingMutableContainers error:nil];
        
        if (success) {
            success(result);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSString * errorstr = [error.userInfo objectForKey:@"NSLocalizedDescription"];
        
        if([errorstr rangeOfString:@"Request failed: unauthorized (401)"].location==NSNotFound){
            
            
        }
        
        failure(error);
    }];

}

/**
 *  设置请求头
 */
+ (void)setupTengxunHeaderField {
    [sessionManager.requestSerializer setValue:@"2020-03-24" forHTTPHeaderField:@"X-TC-Version"];
    [sessionManager.requestSerializer setValue:@"SegmentCustomizedPortraitPic" forHTTPHeaderField:@"X-TC-Action"];
    
    [sessionManager.requestSerializer setValue:@"ap-shanghai" forHTTPHeaderField:@"X-TC-Region"];
    
    NSDate *datenow = [NSDate date];//现在时间
    NSTimeInterval interval = [datenow timeIntervalSince1970];//13位的*1000
    NSString *timeSp = [NSString stringWithFormat:@"%.0f",interval];
    [sessionManager.requestSerializer setValue:timeSp forHTTPHeaderField:@"X-TC-Timestamp"];
    

    [sessionManager.requestSerializer setValue:@"TC3-HMAC-SHA256 Credential=AKIDPdaHhqjLgla8RTEiwsXv1rRkmZ5KI0Rb/2021-05-18/bda/tc3_request, SignedHeaders=content-type;host, Signature=f1cac4fb6fd4a2b0294fe2d52a31bb6ae4237110118cb7c7af8e55b20d085bc6" forHTTPHeaderField:@"Authorization"];

}

/**
 *  设置请求头
 */
+ (void)setupHeaderField{
//    UserBean *bean = [userDataUtil user];
//    NSString *session = [userDataUtil session];
//    NSLog(@"session = %@", session);
//    if (bean && session) {
//        [sessionManager.requestSerializer setValue:session forHTTPHeaderField:@"X-Transmission-Session-Id"];
//    }
//    [sessionManager.requestSerializer setValue:AppVersionInfo forHTTPHeaderField:@"D-Compatible-Info"];
}

+ (void)POSTWithImage:(UIImage *)image SeverFileName:(NSString *)name  url:(NSString *)URLString Parameters:(id)parameters Success:(void (^)(id data))success Failed:(void (^)(NSError *error))failed{
    
    sessionManager.responseSerializer = [AFJSONResponseSerializer serializer];
    sessionManager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    [sessionManager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    sessionManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",//     application/x-www-form-urlencoded  application/json
                                                         @"text/html",
                                                         @"image/jpeg",
                                                         @"image/png",
                                                         @"application/octet-stream",
                                                         @"text/json",
                                                         @"application/x-www-form-urlencoded",
                                                         nil];
        
    [self setupHeaderField];

        
    NSMutableDictionary * mDic = [NSMutableDictionary dictionaryWithDictionary:parameters];
    
    [sessionManager POST:URLString parameters:mDic headers:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        [formData appendPartWithFileData:UIImageJPEGRepresentation(image, 1.0) name:name fileName:@"avatar.png" mimeType:@"image/png"];
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (success) {
            success(responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSString * errorstr = [error.userInfo objectForKey:@"NSLocalizedDescription"];
        
        if([errorstr rangeOfString:@"Request failed: unauthorized (401)"].location==NSNotFound){
            
        }
        
        failed(error);
    }];
}

#pragma mark -- 网络判断 --
+ (void)checkNetworkLinkStatus{
    //1.创建网络状态监测管理者
    AFNetworkReachabilityManager *reachability = [AFNetworkReachabilityManager sharedManager];
    //2.监听改变
    [reachability setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        /*
         AFNetworkReachabilityStatusUnknown          = -1,
         AFNetworkReachabilityStatusNotReachable     = 0,
         AFNetworkReachabilityStatusReachableViaWWAN = 1,
         AFNetworkReachabilityStatusReachableViaWiFi = 2,
         */
        networkStatus = status;
        switch (status) {
            case AFNetworkReachabilityStatusUnknown:
                NSLog(@"未知");
                break;
            case AFNetworkReachabilityStatusNotReachable:
                NSLog(@"没有网络");
                break;
            case AFNetworkReachabilityStatusReachableViaWWAN:
                NSLog(@"3G|4G");
                break;
            case AFNetworkReachabilityStatusReachableViaWiFi:
                NSLog(@"WiFi");
                break;
            default:
                break;
        }
    }];
    [reachability startMonitoring];
}

/*
 AFNetworkReachabilityStatusUnknown          = -1, 未知网络
 AFNetworkReachabilityStatusNotReachable     = 0,  无网络
 AFNetworkReachabilityStatusReachableViaWWAN = 1,  手机网络
 AFNetworkReachabilityStatusReachableViaWiFi = 2,  Wifi
 */
+ (NSInteger)theNetworkStatus{
    // 调用完checkNetworkLinkStatus,才可以调用此方法
    return networkStatus;
}

@end
