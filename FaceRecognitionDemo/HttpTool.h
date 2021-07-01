//
//  HttpTool.h
//  camerademo
//
//  Created by 贾大兵 on 2020/3/19.
//  Copyright © 2020 sunuo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface HttpTool : NSObject
+ (void)POST:(NSString *)URLString Parameters:(id)parameters Success:(void (^)(id data))success Failure:(void (^)(NSError *error))failure;

+ (void)GET:(NSString *)URLString Parameters:(id)parameters Success:(void (^)(id data))success Failure:(void (^)(NSError *error))failure;

+ (void)DELETE:(NSString *)URLString Parameters:(id)parameters Success:(void (^)(id data))success Failure:(void (^)(NSError *error))failure;

+ (void)POSTWithImage:(UIImage *)image SeverFileName:(NSString *)name url:(NSString *)URLString Parameters:(id)parameters Success:(void (^)(id data))success Failed:(void (^)(NSError *error))failed;


/**
 监听网络状态,程序启动执行一次即可
 */
+(void) checkNetworkLinkStatus;


/**
 *  读取当前网络状态
 *
 *  @return -1:未知, 0:无网络, 1:2G|3G|4G, 2:WIFI
 */
+ (NSInteger)theNetworkStatus;

+ (void)setupTengxunHeaderField;
@end

NS_ASSUME_NONNULL_END
