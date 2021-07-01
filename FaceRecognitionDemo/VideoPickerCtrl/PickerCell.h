//
//  PickerCell.h
//  videoClip
//
//  Created by db J on 2021/2/24.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
NS_ASSUME_NONNULL_BEGIN

@interface PickerCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *coverImg;
@property (weak, nonatomic) IBOutlet UILabel *videoTimeLabel;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UIImageView *vodieIcon;

- (void)setPickerPHAsset:(PHAsset *)asset  index:(NSInteger)index;
@end

NS_ASSUME_NONNULL_END
