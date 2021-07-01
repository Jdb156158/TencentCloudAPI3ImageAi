//
//  ShowImageViewController.m
//  FaceRecognitionDemo
//
//  Created by 彭新凯 on 2021/5/10.
//

#import "ShowImageViewController.h"
#import "HttpTool.h"
#import "HudManager.h"
#include <CommonCrypto/CommonDigest.h>
#include <CommonCrypto/CommonHMAC.h>
#import "base64.h"
#import <FaceRecognitionDemo-Swift.h>

@interface ShowImageViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (nonatomic, copy) NSString *accessToken;
@property (nonatomic, strong) NSMutableDictionary *pramDic;


@end

@implementation ShowImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.imageView.image = self.selectimg;
//    [self loadToken];
//    [self getSign];
}

- (void)loadToken {
    [HttpTool POST:@"https://aip.baidubce.com/oauth/2.0/token" Parameters:@{@"grant_type":@"client_credentials",@"client_id":@"mUdfOormmoswmTOhE4gfgrSQ",@"client_secret":@"VG1hz1VIjy2FwXTjtA4s3L1A3oA7l21D"} Success:^(id  _Nonnull data) {
        self.accessToken = [data objectForKey:@"access_token"];
    } Failure:^(NSError * _Nonnull error) {

    }];
    NSDate *datenow = [NSDate date];//现在时间
    NSTimeInterval interval = [datenow timeIntervalSince1970];//13位的*1000
    NSString *timeSp = [NSString stringWithFormat:@"%.0f",interval];
    NSData *data = UIImageJPEGRepresentation(self.selectimg, 0.3f);
    NSString *encodedImageStr = [data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    [HttpTool GET:@"https://cvm.tencentcloudapi.com/?Action=DescribeInstances&InstanceIds.0=ins-09dx96dg&Limit=20&Nonce=11886&Offset=0&Region=ap-guangzhou&SecretId=AKIDPdaHhqjLgla8RTEiwsXv1rRkmZ5KI0Rb&Timestamp=1465185768&Version=2017-03-12" Parameters:@{} Success:^(id  _Nonnull data) {
//        self.accessToken = [data objectForKey:@"access_token"];
    } Failure:^(NSError * _Nonnull error) {
        
    }];
}

- (IBAction)koutuAction:(id)sender {
    NSData *data = UIImageJPEGRepresentation(self.selectimg, 0.3f);
    NSString *encodedImageStr = [data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    [HudManager showLoading];
    
    [HttpTool POST:@"https://aip.baidubce.com/rest/2.0/image-classify/v1/body_seg" Parameters:@{@"access_token":self.accessToken,@"image":encodedImageStr} Success:^(id  _Nonnull data) {
        [HudManager hideLoading];
        if ([data isKindOfClass:[NSError class]]) {
            [HudManager showWord:@"抠图出错"];
        } else {
            if ([data objectForKey:@"error_msg"]) {
                [HudManager showWord:[data objectForKey:@"error_msg"]];
            } else {
                self.imageView.image = [self decodeBase64ToImage:[data objectForKey:@"foreground"]];
            }
        }
    } Failure:^(NSError * _Nonnull error) {
        [HudManager hideLoading];
        [HudManager showWord:@"抠图出错"];
    }];
//    [HttpTool setupTengxunHeaderField];//,@"SegmentationOptions":[self gs_jsonStringCompactFormatForDictionary:@{@"Head":[NSNumber numberWithBool:true]}]
//    NSDate *datenow = [NSDate date];//现在时间
//    NSTimeInterval interval = [datenow timeIntervalSince1970];//13位的*1000
//    NSString *timeSp = [NSString stringWithFormat:@"%.0f",interval];
//    NSDictionary *pram = @{@"Action":@"SegmentCustomizedPortraitPic",
//                           @"Language":@"zh-CN",
//                           @"Nonce":@"3928",
//                           @"Region" : @"ap-shanghai",
//                           @"SecretId":@"AKIDPdaHhqjLgla8RTEiwsXv1rRkmZ5KI0Rb",
//                           @"SegmentationOptions.Head":@"TRUE",
//                           @"Signature":@"uFGcZ%2Bdyg0652KEqFB%2FZF%2FSMUO0%3D",
//                           @"Timestamp":timeSp,
//                           @"Url" : @"https://ai.bdstatic.com/file/F64EFEFF3630474BA1F681544539C9FE",
//                           @"Version" : @"2020-03-24",
//                           @"Image":encodedImageStr
//    };
//    self.pramDic[@"Signature"] = [self getSign];
//    [HttpTool POST:@"https://bda.tencentcloudapi.com" Parameters:self.pramDic Success:^(id  _Nonnull data) {
//        [HudManager hideLoading];
////        if ([data isKindOfClass:[NSError class]]) {
////            [HudManager showWord:@"抠图出错"];
////        } else {
////            if ([data objectForKey:@"error_msg"]) {
////                [HudManager showWord:[data objectForKey:@"error_msg"]];
////            } else {
////                self.imageView.image = [self decodeBase64ToImage:[data objectForKey:@"foreground"]];
////            }
////        }
//    } Failure:^(NSError * _Nonnull error) {
//        [HudManager hideLoading];
//        [HudManager showWord:@"抠图出错"];
//    }];
    TranslateViewModel *model = [[TranslateViewModel alloc] init];
    NSDictionary *pram = [model createPublicParam_V1WithImageStr:@"http://img.jj20.com/up/allimg/1113/061120115231/200611115231-1-1200.jpg"];
    NSString *getUrl = pram[@"getUrl"];
    NSString *signature = pram[@"Signature"];

    NSString *resultUrl = [getUrl substringFromIndex:3];
    NSLog(@"pram-----%@",resultUrl);
    [HttpTool GET:[NSString stringWithFormat:@"https://%@&Signature=%@",resultUrl,signature] Parameters:@{} Success:^(id  _Nonnull data) {
        [HudManager hideLoading];
        self.imageView.image = [self decodeBase64ToImage:[data[@"Response"] objectForKey:@"PortraitImage"]];
    } Failure:^(NSError * _Nonnull error) {
        [HudManager hideLoading];
    }];
}

- (NSString *)getSign {
    NSMutableDictionary *pramDic = [NSMutableDictionary dictionary];
    [pramDic setValue:@"SegmentCustomizedPortraitPic" forKey:@"Action"];
    [pramDic setValue:@"zh-CN" forKey:@"Language"];
    [pramDic setValue:@"ap-shanghai" forKey:@"Region"];
    [pramDic setValue:[NSNumber numberWithInt:rand()].stringValue forKey:@"Nonce"];
    [pramDic setValue:@"AKIDPdaHhqjLgla8RTEiwsXv1rRkmZ5KI0Rb" forKey:@"SecretId"];
    [pramDic setValue:@"TRUE" forKey:@"SegmentationOptions.Head"];
    NSDate *datenow = [NSDate date];//现在时间
    NSTimeInterval interval = [datenow timeIntervalSince1970];//13位的*1000
    NSString *timeSp = [NSString stringWithFormat:@"%.0f",interval];
    [pramDic setValue:timeSp forKey:@"Timestamp"];
    NSData *data = UIImageJPEGRepresentation(self.selectimg, 0.3f);
    NSString *encodedImageStr = [data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    [pramDic setValue:[self URLEncodedString:@"http://b.zol-img.com.cn/desk/bizhi/image/1/1680x1050/1349289433496.jpg"] forKey:@"Url"];
    
    [pramDic setValue:@"2020-03-24" forKey:@"Version"];
    
    NSString *signStr = @"POSTbda.tencentcloudapi.com/?";
    NSArray *sortKeyArray = [self sortedDictionary:pramDic];
    self.pramDic = pramDic;
    for (NSString *key in sortKeyArray) {
        NSString *value = pramDic[key];
        signStr = [NSString stringWithFormat:@"%@%@=%@&",signStr,key,value];
    }
    signStr = [signStr substringToIndex:signStr.length-1];
//    NSString *rSignStr = [self hmacsha1:signStr key:@"uXu1rQjlcQyF3av2sRjlZ6MM5XhaKvIO"];
    NSString *rSignStr = [self hmacSha1:@"uXu1rQjlcQyF3av2sRjlZ6MM5XhaKvIO" text:signStr];

    rSignStr = [self URLEncodedString:[self base64EncodeString:rSignStr]];
    NSLog(@"signStr:%@",rSignStr);
    return rSignStr;
}

- (NSString *)URLEncodedString:(NSString *)signStr
{
   // CharactersToBeEscaped = @":/?&=;+!@#$()~',*";
   // CharactersToLeaveUnescaped = @"[].";

   NSString *unencodedString = signStr;
   NSString *encodedString = (NSString *)
   CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                             (CFStringRef)unencodedString,
                                                             NULL,
                                                             (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                             kCFStringEncodingUTF8));

   return encodedString;
}


- (NSString *)base64EncodeString:(NSString *)string {
    
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    
    return [data base64EncodedStringWithOptions:0];
    
}

/**
 对字典(Key-Value)排序 区分大小写

 @param dict 要排序的字典
 */
- (NSArray *)sortedDictionary:(NSDictionary *)dict{

    //将所有的key放进数组
    NSArray *allKeyArray = [dict allKeys];

    //序列化器对数组进行排序的block 返回值为排序后的数组
    NSArray *afterSortKeyArray = [allKeyArray sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        NSComparisonResult resuest = [obj1 compare:obj2];
        return resuest;
    }];
    NSLog(@"afterSortKeyArray:%@",afterSortKeyArray);

     //通过排列的key值获取value
     NSMutableArray *valueArray = [NSMutableArray array];
     for (NSString *sortsing in afterSortKeyArray) {
         NSString *valueString = [dict objectForKey:sortsing];
         [valueArray addObject:valueString];
     }
     NSLog(@"valueArray:%@",valueArray);
    NSMutableDictionary *pramDic = [NSMutableDictionary dictionary];

    for (NSString *key in afterSortKeyArray) {
        //处理字典的键值
        [pramDic setValue:dict[key] forKey:key];
    }
    return afterSortKeyArray;
 }

- (NSString *)hmacsha1:(NSString *)text key:(NSString *)secret {
    NSData *secretData = [secret dataUsingEncoding:NSUTF8StringEncoding];
    NSData *clearTextData = [text dataUsingEncoding:NSUTF8StringEncoding];
    unsigned char result[20];
    CCHmac(kCCHmacAlgSHA1, [secretData bytes], [secretData length], [clearTextData bytes], [clearTextData length], result);
    char base64Result[32];
    size_t theResultLength = 32;
    Base64EncodeData(result, 20, base64Result, &theResultLength,YES);
    NSData *theData = [NSData dataWithBytes:base64Result length:theResultLength];
    NSString *base64EncodedResult = [[NSString alloc] initWithData:theData encoding:NSASCIIStringEncoding];
    return base64EncodedResult;
}


- (NSString *)hmacSha1:(NSString*)key text:(NSString*)text {
    
    const char *cKey  = [key cStringUsingEncoding:NSUTF8StringEncoding];
    
    
    
    const char *cData = [text cStringUsingEncoding:NSUTF8StringEncoding];
    
    
    
    uint8_t cHMAC[CC_SHA1_DIGEST_LENGTH];
    
    
    
    CCHmac(kCCHmacAlgSHA1, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    
    
    //NSData *HMAC = [[NSData alloc] initWithBytes:cHMAC length:CC_SHA1_DIGEST_LENGTH];
    
    
    
    NSString *hash;
    
    
    NSMutableString * output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    
    
    
    for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", cHMAC[i]];
    
    
    
    hash = output;
    
    
    
    return hash;
    
    
}

- (NSString *)gs_jsonStringCompactFormatForDictionary:(NSDictionary *)dicJson {
    if (![dicJson isKindOfClass:[NSDictionary class]] || ![NSJSONSerialization isValidJSONObject:dicJson]) {

        return nil;

    }

    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dicJson options:0 error:nil];

    NSString *strJson = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];

    return strJson;
}


- (UIImage *)decodeBase64ToImage:(NSString *)strEncodeData {
  NSData *data = [[NSData alloc]initWithBase64EncodedString:strEncodeData options:NSDataBase64DecodingIgnoreUnknownCharacters];
    return [UIImage imageWithData:data];
}

- (NSString *)encodeToBase64String:(UIImage *)image {
    return [UIImagePNGRepresentation(image) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
