//
//  KoutuViewController.m
//  FaceRecognitionDemo
//
//  Created by 彭新凯 on 2021/5/19.
//

#import "KoutuViewController.h"
#import "HudManager.h"
#import "HttpTool.h"
#import <FaceRecognitionDemo-Swift.h>
#import <SDWebImage.h>
#import <Masonry.h>
#include <math.h>
#import "TencentCloudAPI3.h"
#import "UIImage+JDImage.h"
#import "QSJCroppableView.h"

#define pi 3.14159265358979323846
#define degreesToRadian(x) (pi * x / 180.0)
#define radiansToDegrees(x) (180.0 * x / pi)

@interface KoutuViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIImageView *featureImageView;
@property (strong, nonatomic) UIView *faceView;
@property (strong, nonatomic) UIImageView *faceImageView;
@property (strong, nonatomic) QSJCroppableView *qsjCroppableView;
@end

@implementation KoutuViewController
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.hidden = YES;

}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:@"http://img.jj20.com/up/allimg/1113/061120115231/200611115231-1-1200.jpg"]];
    //https://img.pconline.com.cn/images/upload/upc/tx/photoblog/1511/15/c4/15263501_1447552697312_mthumb.jpg
    //http://pic1.win4000.com/wallpaper/7/54279ea403f67.jpg
    [self.featureImageView sd_setImageWithURL:[NSURL URLWithString:@"http://pic1.win4000.com/wallpaper/7/54279ea403f67.jpg"] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
//        CGSize size = image.size;
//        CGFloat w = size.width;
//        CGFloat H = size.height;
//        self.featureImageView.frame = CGRectMake(0, CGRectGetMaxY(self.imageView.frame), w,H);
//        [self.featureImageView mas_updateConstraints:^(MASConstraintMaker *make) {
//            make.size.mas_equalTo(CGSizeMake(w, H));
//        }];
        CGRect rect = [self frameForImage:image inImageViewAspectFit:self.featureImageView];
        NSLog(@"height:%f----width:%f",rect.size.height,rect.size.width);
        UIView *faceView = [[UIView alloc] initWithFrame:rect];
        faceView.backgroundColor = [UIColor clearColor];
        [self.featureImageView addSubview:faceView];
        self.faceView = faceView;
    }];
    
    CGRect rect1 = CGRectMake(0, 0, self.imageView.image.size.width, self.imageView.image.size.height);
    CGRect rect2 = self.imageView.frame;
    [QSJCroppableView scaleRespectAspectFromRect1:rect1 toRect2:rect2];
    
    [self setUpQSJCroppableView];
}

- (void)setUpQSJCroppableView
{
    [self.qsjCroppableView removeFromSuperview];
    self.qsjCroppableView = [[QSJCroppableView alloc] initWithImageView:self.imageView];
    [self.view addSubview:self.qsjCroppableView];
}

-(CGRect)frameForImage:(UIImage*)image inImageViewAspectFit:(UIImageView*)imageView
{
    float imageRatio = image.size.width / image.size.height;

    float viewRatio = imageView.frame.size.width / imageView.frame.size.height;

    if(imageRatio < viewRatio)
    {
        float scale = imageView.frame.size.height / image.size.height;

        float width = scale * image.size.width;

        float topLeftX = (imageView.frame.size.width - width) * 0.5;

        return CGRectMake(topLeftX, 0, width, imageView.frame.size.height);
    }
    else
    {
        float scale = imageView.frame.size.width / image.size.width;

        float height = scale * image.size.height;

        float topLeftY = (imageView.frame.size.height - height) * 0.5;

        return CGRectMake(0, topLeftY, imageView.frame.size.width, height);
    }
}

- (IBAction)koutuAction:(id)sender {
    [HudManager showLoading];
    
    // 以下内容，需要从云api中获取
    // 1、初始化，只需要初始化一次
    NSString *SECRET_ID = @"AKIDPdaHhqjLgla8RTEiwsXv1rRkmZ5KI0Rb";
    NSString *SECRET_KEY = @"uXu1rQjlcQyF3av2sRjlZ6MM5XhaKvIO";
    NSString *HOST = @"bda.tencentcloudapi.com";
    NSString *SERVICE = @"bda";
    NSString *VERSION = @"2020-03-24";
    [[TencentCloudAPI3 TC] setConfig:@{
        @"SECRET_ID": SECRET_ID,
        @"SECRET_KEY": SECRET_KEY,
        @"HOST": HOST,
        @"SERVICE": SERVICE,
        @"VERSION": VERSION
    }];
    // 2、构造数据
    NSDictionary *getTokenParams = @{
        @"action": @"SegmentCustomizedPortraitPic", // action是接口的Action
        @"data": @{ // data里面是真正的数据
                @"Url": @"http://img.jj20.com/up/allimg/1113/061120115231/200611115231-1-1200.jpg",
                @"SegmentationOptions": @{
                        @"Head":@YES
                }
        }
    };
    
    // 3、获取token示例
    [[TencentCloudAPI3 TC] getResult:getTokenParams success:^(NSDictionary *responseObject){
        [HudManager hideLoading];
        NSLog(@"responseObject");
        NSLog(@"%@", responseObject);
        dispatch_async(dispatch_get_main_queue(), ^{
            UIImage *resultImage = [self decodeBase64ToImage:[responseObject[@"Response"] objectForKey:@"PortraitImage"]];
            self.imageView.image = [resultImage grayImage];
        });
        
    } failure:^(NSError *error){
        [HudManager hideLoading];
        NSLog(@"error");
        NSLog(@"%@", error.localizedDescription);
    }];

    /*
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
    }];*/
}

- (IBAction)fanhuiAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)shibieActio:(id)sender {
    JunVisionTool *visionTool = [[JunVisionTool alloc] init];

//    [visionTool staticFaceFuncWithFaceImage:self.featureImageView.image cleanView:self.faceView];
    [visionTool staticFaceFuncWithFaceImage:self.featureImageView.image cleanView:self.faceView completeBack:^(CGRect rect) {
        NSLog(@"origin----%f",rect.origin.x);
        UIImageView *faceImageView = [[UIImageView alloc] initWithFrame:CGRectMake(rect.origin.x-5, rect.origin.y, rect.size.width+20, rect.size.height+20)];
        faceImageView.backgroundColor = [UIColor clearColor];
        faceImageView.image = [self cutAlphaZero:self.imageView.image];
        faceImageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.featureImageView addSubview:faceImageView];
        self.faceImageView = faceImageView;
    }];
    
    [visionTool faceFeatureWithFaceImage:self.featureImageView.image cleanView:self.faceView completeBack:^(NSArray<NSValue * > * pointArr) {
        CGPoint firstPoint = pointArr.firstObject.CGPointValue;
        CGPoint lastPoint = pointArr.lastObject.CGPointValue;

        CGFloat angle = [self angleBetweenPoints:firstPoint second:lastPoint];
        NSLog(@"angle-%f----%f",angle,M_PI/6);
//        self.faceImageView.transform = CGAffineTransformMakeRotation(-M_PI/6);
        dispatch_async(dispatch_get_main_queue(), ^{
            CGFloat rotation = -(angle/100);
            if (angle > 0) {
                rotation = ((90-angle)/100);
            }
            self.faceImageView.transform = CGAffineTransformMakeRotation(rotation);
        });
    }];
}

- (IBAction)clickResetBtn:(id)sender {
    
    [self setUpQSJCroppableView];
    
}
- (IBAction)clickOkBtn:(id)sender {
    
    UIImage *croppedImage = [self.qsjCroppableView deleteBackgroundOfImage:self.imageView];
    self.imageView.image = croppedImage;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [self setUpQSJCroppableView];
        
    });
    
}

- (CGFloat)distanceBetweenPoints:(CGPoint)first second:(CGPoint)second {
    CGFloat deltaX = second.x - first.x;
    CGFloat deltaY = second.y - first.y;
    return sqrt(deltaX*deltaX + deltaY*deltaY);
}

- (CGFloat)angleBetweenPoints:(CGPoint)first second:(CGPoint)second {
    CGFloat height = second.y - first.y;
    CGFloat width = first.x - second.x;
    CGFloat rads = atan(height/width);
    return radiansToDegrees(rads);
}

- (CGFloat)angleBetweenLines:(CGPoint)line1Start line1End:(CGPoint)line1End line2Start:(CGPoint)line2Start line2End:(CGPoint)line2End  {
    CGFloat a = line1End.x - line1Start.x;
    CGFloat b = line1End.y - line1Start.y;
    CGFloat c = line2End.x - line2Start.x;
    CGFloat d = line2End.y - line2Start.y;

    CGFloat rads = acos(((a*c) + (b*d)) / ((sqrt(a*a + b*b)) * (sqrt(c*c + d*d))));

    return radiansToDegrees(rads);
}


- (UIImage *)decodeBase64ToImage:(NSString *)strEncodeData {
  NSData *data = [[NSData alloc]initWithBase64EncodedString:strEncodeData options:NSDataBase64DecodingIgnoreUnknownCharacters];
    return [UIImage imageWithData:data];
}

#pragma mark - 裁剪掉周围的透明部分
- (UIImage*)cutAlphaZero:(UIImage*)image {
    
    CGImageRef cgimage = [image CGImage];
    
    size_t width = CGImageGetWidth(cgimage); // 图片宽度
    size_t height = CGImageGetHeight(cgimage); // 图片高度
    
    unsigned char *data = calloc(width * height * 4, sizeof(unsigned char)); // 取图片首地址
    size_t bitsPerComponent = 8; // r g b a 每个component bits数目
    size_t bytesPerRow = width * 4; // 一张图片每行字节数目 (每个像素点包含r g b a 四个字节)
    CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB(); // 创建rgb颜色空间
    
    CGContextRef context = CGBitmapContextCreate(data, width,height,bitsPerComponent,bytesPerRow,space,kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), cgimage);
    int top = 0;  // 上边框透明高度
    int left = 0; // 左边框透明高度
    int right = 0; // 右边框透明高度
    int bottom = 0; // 底边框透明高度
    
    for (size_t row = 0; row < height; row++) {
        BOOL find = false;
        for (size_t col = 0; col < width; col++) {
            size_t pixelIndex = (row * width + col) * 4;
            //            int red = data[pixelIndex];
            //            int green = data[pixelIndex+1];
            //            int blue = data[pixelIndex + 2];
            int alpha = data[pixelIndex + 3];
            if (alpha != 0) {
                find = YES;
                break;
            }
        }
        if (find) {
            break;
        }
        top ++;
    }
    
    for (size_t col = 0; col < width; col++) {
        BOOL find = false;
        for (size_t row = 0; row < height; row++) {
            size_t pixelIndex = (row * width + col) * 4;
            
            int alpha = data[pixelIndex + 3];
            if (alpha != 0) {
                find = YES;
                break;
            }
        }
        if (find) {
            break;
        }
        left ++;
    }
    
    for (size_t col = width - 1; col > 0; col--) {
        BOOL find = false;
        for (size_t row = 0; row < height; row++) {
            size_t pixelIndex = (row * width + col) * 4;
            
            int alpha = data[pixelIndex + 3];
            if (alpha != 0) {
                find = YES;
                break;
            }
        }
        if (find) {
            break;
        }
        right ++;
    }
    
    for (size_t row = height - 1; row > 0; row--) {
        BOOL find = false;
        for (size_t col = 0; col < width; col++) {
            size_t pixelIndex = (row * width + col) * 4;
            int alpha = data[pixelIndex + 3];
            if (alpha != 0) {
                find = YES;
                break;
            }
        }
        if (find) {
            break;
        }
        bottom ++;
    }
    

    CGFloat scale = image.scale;
    CGImageRef newImageRef = CGImageCreateWithImageInRect(cgimage, CGRectMake(left * scale, top *scale, (image.size.width - left - right)*scale, (image.size.height - top - bottom)*scale));
    UIImage *newImage = [UIImage imageWithCGImage:newImageRef];
    // 释放
    CGImageRelease(cgimage);
    CGContextRelease(context);
    CGColorSpaceRelease(space);
    return  newImage;
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
