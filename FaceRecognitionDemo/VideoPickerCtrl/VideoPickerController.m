//
//  VideoPickerController.m
//  videoClip
//
//  Created by db J on 2021/2/24.
//

#import "VideoPickerController.h"
//#import "ImageEmjoClipViewController.h"
#import "PickerCell.h"
#import "CellFlowLayout.h"
//#import "HudManager.h"
//#import "SettingManager.h"
//#import "CameraCtrl.h"
//#import "NewVideoCutCtrl.h"
#import "UIViewController+Utils.h"
#import "IWCheckImageHaveFace.h"
#import "ShowImageViewController.h"
#import "HudManager.h"
#import "ScreeningPeopleViewController.h"

#define KSTA_H ({CGFloat statusBarHeight = 0;if (@available(iOS 13.0, *)) {statusBarHeight = [UIApplication sharedApplication].windows.firstObject.windowScene.statusBarManager.statusBarFrame.size.height;} else {statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;}(statusBarHeight);})//动态获取状态栏高度
#define kSafeAreaNavTopHeight 44//导航栏一直固定的，变的是状态栏

@interface VideoPickerController ()<UICollectionViewDelegateFlowLayout, UICollectionViewDataSource>

@property (nonatomic, strong) NSMutableArray *pickerModels, *selectedIndexs;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *navaHeightLayout;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *tipsBtn1;
@property (weak, nonatomic) IBOutlet UIButton *tipsBtn2;

@end

@implementation VideoPickerController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.navaHeightLayout.constant = kSafeAreaNavTopHeight+KSTA_H;
    
    [self.view addSubview:self.collectionView];
    if (self.type) {
        self.titleLabel.text = @"照片表情";
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.hidden = YES;
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self initPickerData];
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (self.pickerModels.count == 0) {
                self.tipsBtn1.hidden = NO;
                self.tipsBtn2.hidden = NO;
            }else{
                self.tipsBtn1.hidden = YES;
                self.tipsBtn2.hidden = YES;
                //相册数据获取完成
                [self.collectionView reloadData];
            }
            
        });
    });
}
- (IBAction)clickBackBtn:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - get
- (NSMutableArray *)pickerModels {
    
    if (!_pickerModels) {
        _pickerModels = [NSMutableArray array];
    }
    return _pickerModels;
}

- (NSMutableArray *)selectedIndexs {
    if (!_selectedIndexs) {
        _selectedIndexs = [NSMutableArray array];
    }
    return _selectedIndexs;
}

- (UICollectionView *)collectionView{
    if (!_collectionView) {
        
        CellFlowLayout *configLayout = [[CellFlowLayout alloc]init];
        configLayout.kCollectionViewWidth = ([UIScreen mainScreen].bounds.size.width-60)/3;
        configLayout.kCollectionViewHeight = 100;
        configLayout.kCollectionminimumLineSpacing = 15;
        configLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
        configLayout.sectionInset = UIEdgeInsetsMake(10, 15, 10, 15);

        _collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, kSafeAreaNavTopHeight+KSTA_H, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-(kSafeAreaNavTopHeight+KSTA_H)) collectionViewLayout:configLayout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.showsVerticalScrollIndicator = NO;//隐藏滚动条
        _collectionView.backgroundColor = [UIColor clearColor];
        [_collectionView registerNib:[UINib nibWithNibName:@"PickerCell" bundle:nil] forCellWithReuseIdentifier:@"PickerCell"];

    }
    return _collectionView;
}

#pragma mark -跳转到相机
- (IBAction)jumpCamera:(id)sender {
    
//    EVENT(@"paizhao");
//
//    __weak typeof(self) weakSelf = self;
//    [SystemUtils requestCameraAuth:^(bool isAllowed) {
//        if (isAllowed) {
//            [weakSelf asyncPushRecordCtrl];
//        }else {
//            [weakSelf asyncPushAuthAlert:@"请求相机权限"];
//        }
//    }];
//    NSInteger count = 0;
//    for (PHAsset *asset in [self.pickerModels subarrayWithRange:NSMakeRange(0, 100)]) {
//        if ([IWCheckImageHaveFace checkHaveFaceWithImage:[self imageURL:asset targetSize:CGSizeMake(300, 300)]]) {
//            NSLog(@"有人脸");
//            count ++;
//        } else {
//            NSLog(@"无人脸");
//        }
//    }
//    self.titleLabel.text = [NSString stringWithFormat:@"检测到%ld张人脸",count];
    
    ScreeningPeopleViewController *vc = [[ScreeningPeopleViewController alloc] init];
    vc.pickerModels = self.pickerModels;
    [self.navigationController pushViewController:vc animated:YES];
}



- (void)asyncPushRecordCtrl {
//    dispatch_async(dispatch_get_main_queue(), ^{
//        CameraCtrl *next = [[CameraCtrl alloc] init];
//        next.type = self.type;
//        [self.navigationController pushViewController:next animated:YES];
//    });
}

- (void)asyncPushAuthAlert:(NSString *)authName {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:authName message:@"下一步操作需要此权限" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okBtn = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil];
        UIAlertAction *go = [UIAlertAction actionWithTitle:@"设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        }];
        
        [alert addAction:okBtn];
        [alert addAction:go];
        [[UIViewController currentViewController] presentViewController:alert animated:YES completion:nil];
    });
}

#pragma mark - data
- (void)initPickerData {
    //刷新前清空一下
    [self.pickerModels removeAllObjects];
    
    PHFetchResult<PHAssetCollection *> *assetCollections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    for (PHAssetCollection *assetCollection in assetCollections) {
        [self enumerateAssetsInAssetCollection:assetCollection original:NO];
    }
    PHAssetCollection *cameraRoll = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil].lastObject;
    [self enumerateAssetsInAssetCollection:cameraRoll original:NO];

}

//细分照片类型
- (void)enumerateAssetsInAssetCollection:(PHAssetCollection *)assetCollection original:(BOOL)original{

    PHFetchOptions *fetchOption = [[PHFetchOptions alloc] init];
    fetchOption.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
    
    PHFetchResult<PHAsset *> *assets = [PHAsset fetchAssetsInAssetCollection:assetCollection options:fetchOption];
    for (PHAsset *asset in assets) {
        BOOL isLivePhoto, isVideo, isBurst, isPhoto;
        BOOL isNotLivePhoto;
        BOOL isGIF = NO;
        if ([[asset valueForKey:@"filename"] hasSuffix:@"GIF"] ||
            [[asset valueForKey:@"filename"] hasSuffix:@"gif"]) {
            isGIF = YES;
        }else {
            isGIF = NO;
        }
        if (@available(iOS 9.1, *)){
            isLivePhoto = (asset.mediaSubtypes == PHAssetMediaSubtypePhotoLive || asset.mediaSubtypes == 520);    //livephot 属于 照片细分type
            if (asset.mediaSubtypes == PHAssetMediaSubtypePhotoLive || asset.mediaSubtypes == 520) {
                isNotLivePhoto = NO;
            }else{
                isNotLivePhoto = YES;
            }
        }else {
            isLivePhoto = NO;
            isNotLivePhoto = YES;
        }
        isBurst = asset.representsBurst;
        isVideo = (asset.mediaType == PHAssetMediaTypeVideo);
        isPhoto = (asset.mediaType == PHAssetMediaTypeImage) && isNotLivePhoto && !isGIF;
        
        //按条件添加
        if (isLivePhoto) {
        }
        if (isVideo && self.type == 0) {
            [self.pickerModels addObject:asset];
            continue;
        }
        if (isBurst) {
        }
        if (isPhoto && self.type == 1) {
            [self.pickerModels addObject:asset];
            continue;
        }
        if (isGIF) {
        }
    }
}

#pragma mark - collectiondelegate


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return self.pickerModels.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    //PickerCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([PickerCell class]) forIndexPath:indexPath];
    
    PickerCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PickerCell" forIndexPath:indexPath];
    
    if (indexPath.item <= self.pickerModels.count - 1) {
        PHAsset *asset = self.pickerModels[indexPath.item];
        [cell setPickerPHAsset:asset index:indexPath.item];
    }
    if (self.type == 1) {
        cell.bottomView.hidden = YES;
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    
    if (indexPath.item >= self.pickerModels.count) {
        NSLog(@"数组越界");
        return;
    }
    
    PHAsset *asset = self.pickerModels[indexPath.row];
    
    if (self.type == 0) {
        //视频
        [self videoTouched:asset];
    }else{
        //图片
        UIImage *selectImg = [self imageURL:asset targetSize:CGSizeMake(asset.pixelWidth, asset.pixelHeight)];
        ShowImageViewController *vc = [[ShowImageViewController alloc] init];
        vc.selectimg = selectImg;
        [self.navigationController pushViewController:vc animated:YES];
    }
    
    
}

#pragma mark -  选择单张图片
- (UIImage *)imageURL:(PHAsset *)phAsset targetSize:(CGSize)targetSize {
    __block UIImage *image = nil;
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.synchronous = YES;
    options.networkAccessAllowed = YES;
    PHImageManager *manager = [PHImageManager defaultManager];
    [manager requestImageForAsset:phAsset targetSize:targetSize contentMode:PHImageContentModeDefault options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        image = result;
    }];
    return image;
}

- (void)videoTouched:(PHAsset *)asset {
//    [HudManager showLoading];
//
//    __weak typeof(self) weakSelf = self;
//    PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
//    options.networkAccessAllowed = YES;
//    [[PHImageManager defaultManager] requestAVAssetForVideo:asset options:options resultHandler:^(AVAsset * _Nullable avasset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
//        __block BOOL needCut = asset.duration*[SettingManager shareManager].videoExractFPS > PIXEL_VIDEOGIF_SEGEMENT_NUMBER;
//        float interval = needCut ? 1.0f : [SettingManager shareManager].floatFps;
//
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//            [GifUtils imgsWithVideoAsset:avasset withTimeInterval:interval withTimeRange:kCMTimeRangeZero completion:^(NSMutableArray *images) {
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    [HudManager hideLoading];
//                    if (images.count > 0) {
//                        if (needCut) {
//                            //需要裁剪大小
//                            [weakSelf asyncPushVideoCutCtrl:avasset withImages:images];
//                        } else {
//                            //不需要裁剪直接编辑
//                            [weakSelf asyncPushGifEditCtrl:images type:GifFromVideo];
//                        }
//                    }else {
//                        [HudManager showWord:NSLocalizedString(@"get_imgs_fail", nil)];
//                    }
//                });
//            }];
//        });
//    }];
}

#pragma mark - 弹出视频长度裁剪界面
- (void)asyncPushVideoCutCtrl:(AVAsset *)avasset withImages:(NSArray *)thumbImgs {
    
//    dispatch_async(dispatch_get_main_queue(), ^{
//        NewVideoCutCtrl *videCutView = [[NewVideoCutCtrl alloc] init];
//        videCutView.originalAsset = avasset;
//        videCutView.thumbImgs = thumbImgs;
//        [self.navigationController pushViewController:videCutView animated:YES];
//    });
    
}

#pragma mark - 弹出Gif编辑页面
//- (void)asyncPushGifEditCtrl:(NSMutableArray *)imgs type:(GifType)gifType {
//    dispatch_async(dispatch_get_main_queue(), ^{
//        GifEditCtrl *next = [[GifEditCtrl alloc] init];
//        next.originImages = imgs;
//        next.gifType = gifType;
//        [self.navigationController pushViewController:next animated:YES];
//    });
//}

@end
