//
//  ViewController.m
//  FaceRecognitionDemo
//
//  Created by 彭新凯 on 2021/5/10.
//

#import "ViewController.h"
#import "VideoPickerController.h"
#import "SystemUtils.h"
#import "KoutuViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    UIButton *bt = [UIButton buttonWithType:UIButtonTypeCustom];
    [bt setTitle:@"相册" forState:UIControlStateNormal];
    [bt setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    [bt addTarget:self action:@selector(nextPage) forControlEvents:UIControlEventTouchUpInside];
    bt.frame = CGRectMake(0, 0, 50, 50);
    bt.center = self.view.center;
    [self.view addSubview:bt];
    
    UIButton *bt1 = [UIButton buttonWithType:UIButtonTypeCustom];
    [bt1 setTitle:@"扣图人脸" forState:UIControlStateNormal];
    [bt1 setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [bt1 addTarget:self action:@selector(koutuPage) forControlEvents:UIControlEventTouchUpInside];
    bt1.frame = CGRectMake(bt.frame.origin.x, CGRectGetMaxY(bt.frame)+20, 100, 50);
    [self.view addSubview:bt1];
}

- (void)nextPage {
    [self requestAlbumAuth];
}

- (void)koutuPage {
    KoutuViewController *imgCtrl = [[KoutuViewController alloc] init];
    [self.navigationController pushViewController:imgCtrl animated:YES];
}

- (void)requestAlbumAuth {
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        if (status == PHAuthorizationStatusAuthorized) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                //允许
                VideoPickerController *imgCtrl = [[VideoPickerController alloc] init];
                imgCtrl.type = YES;
                [self.navigationController pushViewController:imgCtrl animated:YES];
            });
            
            
        }else if (status == PHAuthorizationStatusDenied || status == PHAuthorizationStatusRestricted) {
            //不允许
            [SystemUtils asyncPushAuthAlert:@"请求相机权限"];
        }
    }];
}

@end
