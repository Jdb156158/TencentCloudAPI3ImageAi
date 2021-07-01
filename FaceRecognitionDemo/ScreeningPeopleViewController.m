//
//  ScreeningPeopleViewController.m
//  FaceRecognitionDemo
//
//  Created by 彭新凯 on 2021/5/13.
//

#import "ScreeningPeopleViewController.h"
#import "ScreeningPeopleCollectionViewCell.h"
#import <Photos/Photos.h>
#import "HudManager.h"
#import "IWCheckImageHaveFace.h"

@interface ScreeningPeopleViewController ()<UICollectionViewDelegate,UICollectionViewDataSource>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *resultModels;
@property (nonatomic, assign) NSInteger searchIndex;
@property (nonatomic, assign) NSInteger currentImgIndex;

@property (weak, nonatomic) IBOutlet UIImageView *selectImageOne;
@property (weak, nonatomic) IBOutlet UIImageView *selectImageTwo;
@property (weak, nonatomic) IBOutlet UIImageView *selectImagethree;

@end

@implementation ScreeningPeopleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.searchIndex = 0;
    self.currentImgIndex = 0;
    [self setCollectionView];
    [self searchPeople];
}

- (void)searchPeople {
    self.resultModels = [NSMutableArray array];
    [self.collectionView reloadData];
    if (self.searchIndex >= self.pickerModels.count) {
        return;
    }
    [HudManager showLoading];
    dispatch_queue_t queue = dispatch_queue_create("com.jzsec.GCDtest", DISPATCH_QUEUE_CONCURRENT);

    [self searchPeopleCore:queue];
//    [HudManager showLoading];
//    dispatch_queue_t queue = dispatch_queue_create("com.jzsec.GCDtest", DISPATCH_QUEUE_CONCURRENT);
//
//     dispatch_async(queue, ^{
//         for (NSInteger i=self.searchIndex; i<self.pickerModels.count; i++) {
//             PHAsset *asset = self.pickerModels[i];
//             if ([IWCheckImageHaveFace checkHaveFaceWithImage:[self imageURL:asset targetSize:CGSizeMake(600, 600)]]) {
//                 NSLog(@"有人脸");
//                 [self.resultModels addObject:asset];
//             } else {
//                 NSLog(@"无人脸");
//             }
//             self.searchIndex ++;
//             if (self.resultModels.count == 9) {
//                 dispatch_async(dispatch_get_main_queue(), ^{
//                     [HudManager hideLoading];
//                     [self.collectionView reloadData];
//                 });
//                 break;
//             }
//         }
//     });
}

- (void)searchPeopleCore:(dispatch_queue_t)queue {
     dispatch_async(queue, ^{
         for (NSInteger i=self.searchIndex; i<self.pickerModels.count; i++) {
             PHAsset *asset = self.pickerModels[i];
             if ([IWCheckImageHaveFace checkHaveFaceWithImage:[self imageURL:asset targetSize:CGSizeMake(600, 600)]]) {
                 NSLog(@"有人脸");
                 [self.resultModels addObject:asset];
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [self.collectionView reloadData];
                 });
                 self.searchIndex ++;
                 break;
             } else {
                 NSLog(@"无人脸");
                 self.searchIndex ++;
             }
         }
         if (self.resultModels.count >= 9) {
             dispatch_async(dispatch_get_main_queue(), ^{
                 [HudManager hideLoading];
                 [self.collectionView reloadData];
             });
         } else {
             [self searchPeopleCore:queue];
         }
     });
}

- (IBAction)huanyipiAction:(id)sender {
    [self searchPeople];
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

- (void)setCollectionView {
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    [_collectionView registerNib:[UINib nibWithNibName:@"ScreeningPeopleCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"ScreeningPeopleCollectionViewCell"];
}

#pragma mark - collectiondelegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.resultModels.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    ScreeningPeopleCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ScreeningPeopleCollectionViewCell" forIndexPath:indexPath];
    PHAsset *asset = self.resultModels[indexPath.row];
    cell.imageView.image = [self imageURL:asset targetSize:CGSizeMake(300, 300)];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(([UIScreen mainScreen].bounds.size.width-60)/3, ([UIScreen mainScreen].bounds.size.width-60)/3);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    PHAsset *asset = self.resultModels[indexPath.row];
    if (self.currentImgIndex == 0) {
        self.selectImageOne.image = [self imageURL:asset targetSize:CGSizeMake(asset.pixelWidth, asset.pixelHeight)];
        self.currentImgIndex = 1;
    } else if (self.currentImgIndex == 1) {
        self.selectImageTwo.image = [self imageURL:asset targetSize:CGSizeMake(asset.pixelWidth, asset.pixelHeight)];
        self.currentImgIndex = 2;
    } else if (self.currentImgIndex == 2) {
        self.selectImagethree.image = [self imageURL:asset targetSize:CGSizeMake(asset.pixelWidth, asset.pixelHeight)];
        self.currentImgIndex = 0;
    }
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
