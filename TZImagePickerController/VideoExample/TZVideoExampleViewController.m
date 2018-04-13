//
//  TZVideoExampleViewController.m
//  TZImagePickerController
//
//  Created by mac on 11/4/18.
//  Copyright © 2018年 谭真. All rights reserved.
//

#import "TZVideoExampleViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>
#import "TZImageManager.h"
#import "YDPhotoDisplayViewController.h"

@interface TZVideoExampleViewController ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) UIButton *saveVideoBtn;
@property (nonatomic, strong) UIButton *openAlbumBtn;

@end

@implementation TZVideoExampleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [ UIColor grayColor];
    
    _openAlbumBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _openAlbumBtn.frame = CGRectMake(100.f, 100.f, 100.f, 40.f);
    [self.view addSubview:_openAlbumBtn];
    [_openAlbumBtn addTarget:self action:@selector(onOpenAction:) forControlEvents:UIControlEventTouchUpInside];
    _openAlbumBtn.backgroundColor = [UIColor blueColor];
    [_openAlbumBtn setTitle:@"选择视频" forState:UIControlStateNormal];
    
    _saveVideoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _saveVideoBtn.frame = CGRectMake(100.f, 150.f, 100.f, 40.f);
    [self.view addSubview:_saveVideoBtn];
    [_saveVideoBtn addTarget:self action:@selector(onSaveAction:) forControlEvents:UIControlEventTouchUpInside];
    _saveVideoBtn.titleLabel.textColor = [UIColor purpleColor];
    _saveVideoBtn.backgroundColor = [UIColor redColor];
    [_saveVideoBtn setTitle:@"保存视频" forState:UIControlStateNormal];
}

- (void)onSaveAction:(UIButton *)sender {
    NSMutableArray *videoArray = [NSMutableArray array];

    NSArray<NSString *> *movs = [[NSBundle mainBundle] pathsForResourcesOfType:@"mp4" inDirectory:nil];
    [videoArray addObjectsFromArray:movs];
    for (NSString * item in videoArray) {
        if ([item hasSuffix:@"video.mp4"]) {
            if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(item)) {
                UISaveVideoAtPathToSavedPhotosAlbum(item, self, nil, NULL);
            }
        }
    }
}

- (void)onOpenAction:(UIButton *)sender {
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) return;
    UIImagePickerController *ipc = [[UIImagePickerController alloc] init];
    ipc.videoMaximumDuration = 0.1;
    ipc.view.backgroundColor = [UIColor grayColor];
    ipc.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    ipc.delegate = self;
    ipc.mediaTypes = @[(NSString *)kUTTypeMovie];
    ipc.videoQuality = UIImagePickerControllerQualityTypeHigh;
    [self presentViewController:ipc animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    NSLog(@"full iamge: %@",info);
    if ([mediaType isEqualToString:(NSString *)kUTTypeMovie]) {
        NSURL *url = info[UIImagePickerControllerMediaURL];
        [picker dismissViewControllerAnimated:YES completion:nil];
        if (@available(iOS 11.0, *)) {
            PHAsset *asset = [info objectForKey:UIImagePickerControllerPHAsset];
            TZAssetModel *currentItem = [TZAssetModel modelWithAsset:asset type:TZAssetModelMediaTypeVideo];
            YDPhotoDisplayViewController *vc =[YDPhotoDisplayViewController new];
            vc.currentAsset = currentItem;
            [self.navigationController pushViewController:vc animated:YES];
        } else {
            // Fallback on earlier versions
        }
        
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
