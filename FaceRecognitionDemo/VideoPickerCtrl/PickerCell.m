//
//  PickerCell.m
//  videoClip
//
//  Created by db J on 2021/2/24.
//

#import "PickerCell.h"
@interface PickerCell ()

@property (assign, nonatomic) PHImageRequestID requestID, videoRequestID;
@property (weak, nonatomic) IBOutlet UIImageView *icloudImageView;

@end

@implementation PickerCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setPickerPHAsset:(PHAsset *)asset  index:(NSInteger)index {
    [self initCoverImg:asset index:index];
    [self initTimeLabel:asset index:index];
}

#pragma mark - 非公开
- (void)initCoverImg:(PHAsset *)asset index:(NSInteger)index {
    
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.resizeMode   = PHImageRequestOptionsResizeModeExact;
    options.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;
    options.synchronous = NO;
    options.networkAccessAllowed = YES;
    [self.coverImg setImage:nil];
    
    NSInteger magicIndex = index + 100;
    if (self.coverImg.tag != magicIndex) {
        [[PHImageManager defaultManager] cancelImageRequest:self.requestID];
    }
    
    self.coverImg.tag = magicIndex;
    CGSize size = [self sizeMaxWidth:300.f withAsset:asset];
    self.requestID = [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:size contentMode:PHImageContentModeDefault options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        
        BOOL downloadFinined = (![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey]);
        if (downloadFinined && result) {
            //有数据
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.coverImg.tag != magicIndex) {
                    return;
                }
                [self.coverImg setImage:result];
                self.icloudImageView.hidden = YES;
            });
        }
        
        // Download image from iCloud / 从iCloud下载图片
        if ([info objectForKey:PHImageResultIsInCloudKey] && !result) {
            PHImageRequestOptions *option = [[PHImageRequestOptions alloc]init];
            option.networkAccessAllowed = YES;
            option.resizeMode = PHImageRequestOptionsResizeModeFast;
            [[PHImageManager defaultManager] requestImageDataForAsset:asset options:option resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
                UIImage *resultImage = [UIImage imageWithData:imageData scale:0.1];
                dispatch_async(dispatch_get_main_queue(), ^{
                    //获取到了iCloud的图片
                    [self.coverImg setImage:resultImage];
                    self.icloudImageView.hidden = NO;
                });
                
            }];
        }
        
        
    }];
}

- (void)initTimeLabel:(PHAsset *)asset index:(NSInteger)index {
    PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
    options.networkAccessAllowed = YES;
    NSInteger newIndex = index + 200;
    if (self.videoTimeLabel.tag != newIndex) {
        [[PHImageManager defaultManager] cancelImageRequest:self.videoRequestID];
    }
    self.videoTimeLabel.tag = newIndex;
    self.videoRequestID = [[PHImageManager defaultManager] requestAVAssetForVideo:asset options:options resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
        float videoLength = (float)asset.duration.value / asset.duration.timescale;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.videoTimeLabel.tag != newIndex) {
                return;
            }
            self.videoTimeLabel.text = [NSString stringWithFormat:@"%lds", (long)videoLength];
        });
    }];
}

- (CGSize)sizeMaxWidth:(float)maxWidth withAsset:(PHAsset *)asset {
    
    float scale = 1.0f;
    CGSize resultSize;
    if (asset.pixelWidth > asset.pixelHeight) {
        //原图 宽>高
        if (maxWidth > asset.pixelWidth) {
            scale = 1.0f;
        }else {
            scale = asset.pixelWidth / maxWidth;
        }
    }else {
        //原图 宽<=高
        if (maxWidth > asset.pixelHeight) {
            scale = 1.0f;
        }else {
            scale = asset.pixelHeight / maxWidth;
        }
    }
    resultSize = CGSizeMake(asset.pixelWidth/scale, asset.pixelHeight/scale);
    
//    NSLog(@"--------------------------");
//    NSLog(@"资源size%@， 缩小倍数%02f", NSStringFromCGSize(resultSize), (float)scale);
//    NSLog(@"--------------------------");
    return resultSize;
}

@end
