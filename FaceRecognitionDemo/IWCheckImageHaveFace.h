//
//  IWCheckImageHaveFace.h
//  FaceRecognitionDemo
//
//  Created by 彭新凯 on 2021/5/10.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
NS_ASSUME_NONNULL_BEGIN

@interface IWCheckImageHaveFace : NSObject
+ (UIImage *)sampleBufferToImage:(CMSampleBufferRef)sampleBuffer;
 
/// 检测图片上是否有人脸
+ (BOOL)checkHaveFaceWithImage:(UIImage *)resultImage;
/// 图片方向调整
+ (UIImage *)fixOrientation:(UIImage *)aImage;
@end

NS_ASSUME_NONNULL_END
